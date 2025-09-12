"""
RAG API (separate module)
- Efficient ingestion into Chroma per workspace collection
- Hybrid retrieval (semantic + keyword) with query expansion via LLaMA
- Conversational memory using LangChain ConversationBufferMemory
"""

from __future__ import annotations

from flask import Blueprint, request, jsonify
import re
from typing import Dict, List, Any, Tuple
import numpy as np
import chromadb

# Optional LangChain memory (lightweight usage)
try:
    from langchain.memory import ChatMessageHistory, ConversationBufferMemory
    from langchain.chains import ConversationalRetrievalChain  # noqa: F401 (documented import)
    import chainlit as cl  # noqa: F401 (documented import)
except Exception:  # pragma: no cover
    ChatMessageHistory = None
    ConversationBufferMemory = None

rag_bp = Blueprint('rag', __name__, url_prefix='/rag')

# Injected clients/models
_llama_client = None
_chroma_client: chromadb.PersistentClient | None = None
_sentence_model = None

# In-memory conversation store: {(workspace_id, chat_id): ConversationBufferMemory}
_memories: Dict[Tuple[str, str], Any] = {}

# Job description storage per workspace
_job_descriptions: Dict[str, str] = {}


def init_rag_blueprint(app, llama_client, chroma_client, sentence_model):
    global _llama_client, _chroma_client, _sentence_model
    _llama_client = llama_client
    _chroma_client = chroma_client
    _sentence_model = sentence_model
    app.register_blueprint(rag_bp)


def _collection_name(workspace_id: str) -> str:
    return f"resumes_{workspace_id}"


def _get_or_create_collection(name: str):
    assert _chroma_client is not None, "Chroma client not initialized"
    try:
        return _chroma_client.get_or_create_collection(name=name)
    except Exception:
        return _chroma_client.create_collection(name=name)


def _chunk_text(text: str, chunk_size: int = 800, overlap: int = 120) -> List[str]:
    if not text:
        return []
    # Normalize whitespace to improve embedding quality on short resumes
    normalized = re.sub(r"\s+", " ", text).strip()
    if not normalized:
        return []
    chunks: List[str] = []
    start = 0
    length = len(normalized)
    while start < length:
        end = min(start + chunk_size, length)
        chunk = normalized[start:end]
        chunks.append(chunk)
        if end == length:
            break
        start = max(end - overlap, 0)
    return chunks


def _embed_texts(texts: List[str]) -> List[List[float]]:
    assert _sentence_model is not None, "Sentence model not loaded"
    if not texts:
        return []
    embs = _sentence_model.encode(texts)
    return [e.tolist() if hasattr(e, 'tolist') else list(e) for e in embs]


def _expand_query(query: str) -> List[str]:
    expansions: List[str] = []
    try:
        if _llama_client:
            prompt = (
                "Generate 3 short semantic query expansions (comma-separated) for searching a resume.\n"
                f"Query: {query}\nReturn only expansions separated by commas."
            )
            completion = _llama_client.chat.completions.create(
                model="meta/llama3-70b-instruct",
                messages=[{"role": "user", "content": prompt}],
                temperature=0.2,
                max_tokens=150,
                stream=False,
            )
            text = completion.choices[0].message.content.strip()
            expansions = [q.strip() for q in text.split(',') if q.strip()]
    except Exception:
        expansions = []

    if not expansions:
        # Simple keyword-based expansion fallback
        words = re.findall(r"[A-Za-z0-9_#\+\.\-]+", query)
        key = " ".join(words[:6])
        expansions = [query, key]
    else:
        expansions = [query] + expansions
    return expansions[:4]


def _keyword_score(text: str, query_terms: List[str]) -> float:
    text_low = text.lower()
    score = 0
    for t in query_terms:
        if t and t in text_low:
            score += 1
    return float(score)


@rag_bp.route('/ingest', methods=['POST'])
def rag_ingest():
    data = request.get_json() or {}
    workspace_id = data.get('workspace_id', '').strip()
    resumes: List[Dict[str, Any]] = data.get('resumes', [])
    if not workspace_id or not resumes:
        return jsonify({'error': 'workspace_id and resumes are required'}), 400

    col = _get_or_create_collection(_collection_name(workspace_id))

    total_chunks = 0
    try:
        ids: List[str] = []
        docs: List[str] = []
        metas: List[Dict[str, Any]] = []

        for r in resumes:
            rid = r.get('id') or r.get('resume_id')
            text = r.get('text', '')
            if not rid or not text:
                continue
            # Chunk and deduplicate identical chunks (short resumes sometimes repeat headers)
            chunks = _chunk_text(text)
            seen: set[str] = set()
            unique_chunks = []
            for ch in chunks:
                key = ch[:200]
                if key in seen:
                    continue
                seen.add(key)
                unique_chunks.append(ch)
            chunks = unique_chunks
            for idx, ch in enumerate(chunks):
                ids.append(f"{rid}::c{idx}")
                docs.append(ch)
                metas.append({
                    'resume_id': rid,
                    'candidate': r.get('candidate', ''),
                    'email': r.get('email', ''),
                    'skills': ', '.join(r.get('skills', [])) if isinstance(r.get('skills'), list) else str(r.get('skills', '')),
                    'experience': r.get('experience', ''),
                    'rank': r.get('rank', 0),
                    'chunk_idx': idx,
                })
            total_chunks += len(chunks)

        embeddings = _embed_texts(docs)
        if ids:
            col.add(ids=ids, documents=docs, metadatas=metas, embeddings=embeddings)

        return jsonify({'success': True, 'workspace_id': workspace_id, 'chunks_added': total_chunks})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@rag_bp.route('/stats', methods=['POST'])
def rag_stats():
    data = request.get_json() or {}
    workspace_id = data.get('workspace_id', '').strip()
    resume_id = data.get('resume_id', '').strip()
    if not workspace_id:
        return jsonify({'error': 'workspace_id is required'}), 400
    col = _get_or_create_collection(_collection_name(workspace_id))
    try:
        where = {'resume_id': resume_id} if resume_id else None
        qr = col.get(where=where, include=["documents", "metadatas"])  # some builds error on ids
        docs = (qr or {}).get('documents', [])
        sample = docs[:2] if isinstance(docs, list) else []
        return jsonify({
            'success': True,
            'workspace_id': workspace_id,
            'resume_id': resume_id or None,
            'chunks_count': len(docs) if isinstance(docs, list) else 0,
            'sample_snippets': sample,
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@rag_bp.route('/store-jd', methods=['POST'])
def rag_store_jd():
    """Store job description for a workspace to use as context in queries"""
    data = request.get_json() or {}
    workspace_id = data.get('workspace_id', '').strip()
    job_description = data.get('job_description', '').strip()
    
    if not workspace_id or not job_description:
        return jsonify({'error': 'workspace_id and job_description are required'}), 400
    
    global _job_descriptions
    _job_descriptions[workspace_id] = job_description
    
    return jsonify({
        'success': True,
        'workspace_id': workspace_id,
        'message': 'Job description stored successfully'
    })


@rag_bp.route('/suggest', methods=['POST'])
def rag_suggest():
    data = request.get_json() or {}
    workspace_id = data.get('workspace_id', '').strip()
    resume_id = data.get('resume_id', '').strip()
    if not workspace_id or not resume_id:
        return jsonify({'error': 'workspace_id and resume_id are required'}), 400

    questions: List[str] = []
    try:
        if _llama_client:
            # Get candidate info for context
            col = _get_or_create_collection(_collection_name(workspace_id))
            where = {'resume_id': resume_id}
            qr = col.get(where=where, include=["documents", "metadatas"])
            docs = (qr or {}).get('documents', [])
            metas = (qr or {}).get('metadatas', [])
            
            candidate_context = ""
            if metas and len(metas) > 0:
                meta = metas[0]
                candidate_name = meta.get('candidate', 'This candidate')
                candidate_skills = meta.get('skills', '')
                candidate_experience = meta.get('experience', '')
                
                candidate_context = f"Candidate: {candidate_name}"
                if candidate_skills:
                    candidate_context += f"\nSkills: {candidate_skills}"
                if candidate_experience:
                    candidate_context += f"\nExperience: {candidate_experience}"
                if docs:
                    candidate_context += f"\nResume snippet: {docs[0][:200]}..."
                candidate_context += "\n\n"
            
            prompt = (
                f"{candidate_context}"
                "As an HR assistant, generate 4 intelligent, specific questions that would help evaluate this candidate for a technical role.\n\n"
                "Focus on:\n"
                "- Technical competency and project depth\n"
                "- Problem-solving abilities and achievements\n"
                "- Cultural fit and communication skills\n"
                "- Potential red flags or areas of concern\n\n"
                "Make questions specific, actionable, and tailored to what you can see in their background.\n"
                "Return only the 4 questions, separated by commas."
            )
            completion = _llama_client.chat.completions.create(
                model="meta/llama3-70b-instruct",
                messages=[{"role": "user", "content": prompt}],
                temperature=0.4,
                max_tokens=200,
                stream=False,
            )
            text = completion.choices[0].message.content.strip()
            questions = [q.strip() for q in text.split(',') if q.strip()]
    except Exception as e:
        print(f"Suggest questions error: {e}")
        questions = []

    if not questions:
        questions = [
            "What are this candidate's strongest technical skills and how do they apply to our role?",
            "What specific projects or achievements demonstrate their problem-solving abilities?",
            "How well does their experience align with our team's needs and company culture?",
            "Are there any gaps in their background that we should address in the interview?",
        ]

    return jsonify({'success': True, 'workspace_id': workspace_id, 'resume_id': resume_id, 'questions': questions[:4]})


@rag_bp.route('/query', methods=['POST'])
def rag_query():
    data = request.get_json() or {}
    workspace_id = data.get('workspace_id', '').strip()
    message = data.get('message', '').strip()
    resume_id = data.get('resume_id', '').strip() or None
    k = int(data.get('k', 5))
    chat_id = (data.get('chat_id') or (resume_id or 'global')).strip()

    if not workspace_id or not message:
        return jsonify({'error': 'workspace_id and message are required'}), 400

    col = _get_or_create_collection(_collection_name(workspace_id))

    # Memory
    mem_key = (workspace_id, chat_id)
    memory = None
    if ConversationBufferMemory and ChatMessageHistory:
        memory = _memories.get(mem_key)
        if memory is None:
            memory = ConversationBufferMemory(memory_key='history', return_messages=True)
            _memories[mem_key] = memory
        # Save user message
        try:
            memory.chat_memory.add_user_message(message)
        except Exception:
            pass

    # Query expansion
    expansions = _expand_query(message)
    query_terms = [t.lower() for t in re.findall(r"[A-Za-z0-9_#\+\.\-]+", " ".join(expansions))]

    # Vector retrieval for each expansion, optionally constrained to resume_id
    results: List[Tuple[str, str, Dict[str, Any], float]] = []  # (id, doc, meta, score)

    try:
        for q in expansions:
            emb = _embed_texts([q])[0]

            # 1) Try constrained to resume_id if provided
            for where_filter in ([{'resume_id': resume_id}] if resume_id else [None]):
                qr = col.query(
                    query_embeddings=[emb],
                    n_results=k,
                    where=where_filter,
                )
                docs = qr.get('documents', [[]])[0]
                metas = qr.get('metadatas', [[]])[0]
                ids_list = qr.get('ids', [[]])
                ids = ids_list[0] if isinstance(ids_list, list) and ids_list else [None] * len(docs)
                dists = qr.get('distances', [[]])[0] if 'distances' in qr else [0.0] * len(docs)
                for i in range(len(docs)):
                    doc = docs[i]
                    meta = metas[i] if i < len(metas) else {}
                    meta = meta or {}
                    chunk_id = (
                        ids[i]
                        if i < len(ids) and ids[i]
                        else f"{meta.get('resume_id', '')}::c{meta.get('chunk_idx', i)}"
                    )
                    dist = float(dists[i]) if i < len(dists) else 0.0
                    sim = 1.0 / (1.0 + dist)
                    keyscore = _keyword_score(doc.lower(), query_terms)
                    hybrid = 0.7 * sim + 0.3 * (keyscore / max(1.0, len(query_terms)))
                    results.append((chunk_id, doc, meta, hybrid))

            # 2) If nothing yet, broaden across workspace
            if not results:
                qr = col.query(
                    query_embeddings=[emb],
                    n_results=max(k, 8),
                )
                docs = qr.get('documents', [[]])[0]
                metas = qr.get('metadatas', [[]])[0]
                ids_list = qr.get('ids', [[]])
                ids = ids_list[0] if isinstance(ids_list, list) and ids_list else [None] * len(docs)
                dists = qr.get('distances', [[]])[0] if 'distances' in qr else [0.0] * len(docs)
                for i in range(len(docs)):
                    doc = docs[i]
                    meta = metas[i] if i < len(metas) else {}
                    meta = meta or {}
                    chunk_id = (
                        ids[i]
                        if i < len(ids) and ids[i]
                        else f"{meta.get('resume_id', '')}::c{meta.get('chunk_idx', i)}"
                    )
                    dist = float(dists[i]) if i < len(dists) else 0.0
                    sim = 1.0 / (1.0 + dist)
                    keyscore = _keyword_score(doc.lower(), query_terms)
                    hybrid = 0.7 * sim + 0.3 * (keyscore / max(1.0, len(query_terms)))
                    results.append((chunk_id, doc, meta, hybrid))

            # 3) Keyword contains fallback on top term if still empty
            if not results and query_terms:
                try:
                    qr = col.query(
                        query_embeddings=[emb],
                        n_results=max(k, 8),
                        where_document={"$contains": query_terms[0]},
                    )
                    docs = qr.get('documents', [[]])[0]
                    metas = qr.get('metadatas', [[]])[0]
                    ids_list = qr.get('ids', [[]])
                    ids = ids_list[0] if isinstance(ids_list, list) and ids_list else [None] * len(docs)
                    dists = qr.get('distances', [[]])[0] if 'distances' in qr else [0.0] * len(docs)
                    for i in range(len(docs)):
                        doc = docs[i]
                        meta = metas[i] if i < len(metas) else {}
                        meta = meta or {}
                        chunk_id = (
                            ids[i]
                            if i < len(ids) and ids[i]
                            else f"{meta.get('resume_id', '')}::c{meta.get('chunk_idx', i)}"
                        )
                        dist = float(dists[i]) if i < len(dists) else 0.0
                        sim = 1.0 / (1.0 + dist)
                        keyscore = _keyword_score(doc.lower(), query_terms)
                        hybrid = 0.7 * sim + 0.3 * (keyscore / max(1.0, len(query_terms)))
                        results.append((chunk_id, doc, meta, hybrid))
                except Exception:
                    pass
    except Exception as e:
        return jsonify({'error': f'retrieval_failed: {e}'}), 500

    # Deduplicate by chunk id, keep best score
    best: Dict[str, Tuple[str, Dict[str, Any], float]] = {}
    for cid, doc, meta, score in results:
        prev = best.get(cid)
        if prev is None or score > prev[2]:
            best[cid] = (doc, meta, score)

    # Top-K by score
    ranked = sorted(best.items(), key=lambda x: x[1][2], reverse=True)[:k]
    contexts = [item[1][0] for item in ranked]
    snippets = [
        {
            'id': item[0],  # cid
            'text': item[1][0],  # doc
            'score': float(round(float(item[1][2]), 4)),  # score
            'metadata': item[1][1],  # meta
        }
        for item in ranked
    ]

    # Synthesize answer
    answer = None
    try:
        if _llama_client and contexts:
            # Extract candidate info from metadata for context
            candidate_info = ""
            if snippets:
                meta = snippets[0].get('metadata', {})
                candidate_name = meta.get('candidate', 'This candidate')
                candidate_email = meta.get('email', '')
                candidate_skills = meta.get('skills', '')
                candidate_experience = meta.get('experience', '')
                
                candidate_info = f"Candidate: {candidate_name}"
                if candidate_email:
                    candidate_info += f" ({candidate_email})"
                if candidate_skills:
                    candidate_info += f"\nKey Skills: {candidate_skills}"
                if candidate_experience:
                    candidate_info += f"\nExperience: {candidate_experience}"
                candidate_info += "\n\n"
            
            # Get job description context
            jd_context = ""
            if workspace_id in _job_descriptions:
                jd = _job_descriptions[workspace_id]
                jd_context = f"JOB DESCRIPTION:\n{jd}\n\n"
            
            prompt = (
                "You are an intelligent HR hiring assistant. Your role is to help HR professionals make informed decisions about candidates.\n\n"
                "Guidelines for your responses:\n"
                "- Be conversational, professional, and helpful\n"
                "- Provide actionable insights for HR decision-making\n"
                "- Highlight strengths, potential concerns, and recommendations\n"
                "- Use specific examples from the resume when available\n"
                "- Compare candidate qualifications against the job requirements\n"
                "- Be honest about limitations in the information\n"
                "- Structure your response clearly with bullet points or sections when helpful\n"
                "- End with a brief recommendation or next steps when appropriate\n\n"
                f"{jd_context}"
                f"{candidate_info}"
                f"HR Question: {message}\n\n"
                "Resume Content:\n" + "\n---\n".join(contexts[:5]) + "\n\n"
                "Please provide a comprehensive, HR-focused response that helps evaluate this candidate against the job requirements:"
            )
            completion = _llama_client.chat.completions.create(
                model="meta/llama3-70b-instruct",
                messages=[{"role": "user", "content": prompt}],
                temperature=0.3,
                max_tokens=600,
                stream=False,
            )
            answer = completion.choices[0].message.content.strip()
    except Exception as e:
        print(f"LLM error: {e}")
        answer = None

    if not answer:
        # Enhanced fallback answer with JD context
        if contexts:
            # Get candidate info for context
            candidate_info = ""
            if snippets:
                meta = snippets[0].get('metadata', {})
                candidate_name = meta.get('candidate', 'This candidate')
                candidate_skills = meta.get('skills', '')
                candidate_experience = meta.get('experience', '')
                
                candidate_info = f"**Candidate:** {candidate_name}"
                if candidate_skills:
                    candidate_info += f"\n**Skills:** {candidate_skills}"
                if candidate_experience:
                    candidate_info += f"\n**Experience:** {candidate_experience}"
                candidate_info += "\n\n"
            
            # Get JD context
            jd_context = ""
            if workspace_id in _job_descriptions:
                jd = _job_descriptions[workspace_id]
                jd_context = f"**Job Requirements:** {jd[:300]}{'...' if len(jd) > 300 else ''}\n\n"
            
            # Create a helpful fallback response
            resume_snippet = contexts[0][:300] if contexts else ''
            answer = f"{jd_context}{candidate_info}**Resume Summary:** {resume_snippet}{'...' if len(resume_snippet) == 300 else ''}\n\n**Analysis:** Based on the available information, I can see this candidate's background. For a more detailed evaluation, please ask specific questions about their technical skills, project experience, or how they might fit the role requirements."
        else:
            answer = "I don't have enough information about this candidate to provide a helpful response. Could you try asking a more specific question about their skills, experience, or qualifications?"

    # Save AI response to memory
    if memory is not None:
        try:
            memory.chat_memory.add_ai_message(answer)
        except Exception:
            pass

    return jsonify({
        'success': True,
        'workspace_id': workspace_id,
        'resume_id': resume_id,
        'chat_id': chat_id,
        'answer': answer,
        'snippets': snippets,
    })



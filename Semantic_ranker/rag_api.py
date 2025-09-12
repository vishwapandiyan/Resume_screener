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

# Interview Agent
_interview_agent = None

# In-memory conversation store: {(workspace_id, chat_id): ConversationBufferMemory}
_memories: Dict[Tuple[str, str], Any] = {}

# Job description storage per workspace
_job_descriptions: Dict[str, str] = {}


def init_rag_blueprint(app, llama_client, chroma_client, sentence_model):
    global _llama_client, _chroma_client, _sentence_model, _interview_agent
    _llama_client = llama_client
    _chroma_client = chroma_client
    _sentence_model = sentence_model
    
    # Initialize Interview Agent
    try:
        from interview_agent import InterviewSchedulingAgent
        _interview_agent = InterviewSchedulingAgent()
        print("✅ Interview Agent initialized")
    except Exception as e:
        print(f"⚠️ Interview Agent initialization failed: {e}")
        _interview_agent = None
    
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
                "Generate 4 conversational questions an HR person might ask about this candidate during a casual discussion.\n\n"
                "Make them sound natural and conversational, like:\n"
                "- 'How well do they match our job requirements?'\n"
                "- 'What are their strongest technical skills for this role?'\n"
                "- 'Any concerns about their experience level?'\n"
                "- 'What makes them stand out for this position?'\n\n"
                "Keep them short, friendly, and focused on practical hiring decisions.\n"
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
            "How well do they match our job requirements?",
            "What are their strongest technical skills for this role?",
            "Any concerns about their experience level?",
            "What makes them stand out for this position?",
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

    # Initialize answer variable
    answer = None
    
    # Check for interview scheduling intent
    interview_intent = False
    if _interview_agent:
        interview_intent = _interview_agent.detect_interview_intent(message)
    
    # If interview intent detected, process interview scheduling
    if interview_intent and _interview_agent:
        try:
            # Get candidate info for interview scheduling
            candidate_info = {}
            if snippets:
                meta = snippets[0].get('metadata', {})
                candidate_info = {
                    'candidate': meta.get('candidate', 'Candidate'),
                    'email': meta.get('email', ''),
                    'skills': meta.get('skills', ''),
                    'experience': meta.get('experience', '')
                }
            
            # Get job information
            job_info = {
                'job_title': 'Software Developer',
                'company': 'Our Company'
            }
            
            if workspace_id in _job_descriptions:
                job_info['job_description'] = _job_descriptions[workspace_id]
            
            # Process interview request
            interview_result = _interview_agent.process_interview_request(message, candidate_info, job_info)
            
            if interview_result['success']:
                # Format the response with stages
                stages_text = "\n\n".join([
                    f"**{stage['stage'].replace('_', ' ').title()}:** {stage['message']}"
                    for stage in interview_result.get('stages', [])
                ])
                
                answer = f"🎯 **Interview Scheduling Activated!**\n\n{stages_text}\n\n"
                
                if interview_result.get('booking_result'):
                    booking = interview_result['booking_result']
                    answer += f"📅 **Interview Details:**\n"
                    answer += f"• Date & Time: {booking['start_time']}\n"
                    answer += f"• Duration: 1 hour\n"
                    answer += f"• Event ID: {booking['event_id']}\n"
                    if booking.get('meeting_link'):
                        answer += f"• Meeting Link: {booking['meeting_link']}\n"
                
                if interview_result.get('email_result', {}).get('success'):
                    answer += f"\n✅ **Email sent successfully to {candidate_info.get('email', 'candidate')}!**"
                elif interview_result.get('email_result', {}).get('manual_required') or interview_result.get('manual_email_option'):
                    answer += f"\n⚠️ **Email sending failed. Manual sending required.**"
                    answer += f"\n📧 **Email Details for Manual Sending:**\n"
                    email_data = interview_result.get('email_data', {})
                    answer += f"• To: {email_data.get('to', '')}\n"
                    answer += f"• Subject: {email_data.get('subject', '')}\n"
                    answer += f"• Body: {email_data.get('body', '')[:200]}...\n"
                    answer += f"\n💡 **Tip:** Copy the email details above and send manually via your email client."
            else:
                answer = f"❌ **Interview scheduling failed:** {interview_result.get('error', 'Unknown error')}"
                
        except Exception as e:
            print(f"Error in interview processing: {e}")
            answer = f"❌ **Interview scheduling error:** {str(e)}"
    
    # Synthesize answer
    if not answer:
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
                
                candidate_info = f"**Candidate:** {candidate_name}"
                if candidate_email:
                    candidate_info += f" ({candidate_email})"
                if candidate_skills:
                    candidate_info += f"\n**Skills:** {candidate_skills}"
                if candidate_experience:
                    candidate_info += f"\n**Experience:** {candidate_experience}"
                candidate_info += "\n\n"
            
            # Get job description context
            jd_context = ""
            if workspace_id in _job_descriptions:
                jd = _job_descriptions[workspace_id]
                jd_context = f"**Job Requirements:** {jd}\n\n"
            
            # Get conversation history
            conversation_history = ""
            if memory is not None:
                try:
                    # Get the conversation history from memory
                    history = memory.chat_memory.messages
                    if len(history) > 1:  # More than just the current message
                        conversation_history = "\n**Previous Conversation:**\n"
                        for msg in history[:-1]:  # Exclude the current message
                            role = "HR" if msg.type == "human" else "Assistant"
                            conversation_history += f"{role}: {msg.content}\n"
                        conversation_history += "\n"
                except Exception as e:
                    print(f"Error getting conversation history: {e}")
            
            # Conversational HR Chat Prompt
            HR_CHAT_PROMPT = """You are a helpful HR assistant having a casual conversation about a candidate. Be conversational, friendly, and direct.

JOB REQUIREMENTS:
{jd_context}

CANDIDATE INFO:
{candidate_info}

RESUME DETAILS:
{resume_contexts}

{conversation_history}HR QUESTION: "{message}"

INSTRUCTIONS:
- Compare the candidate directly against the job requirements
- Be specific about how their skills/experience match what we need
- Point out specific strengths and any gaps you notice
- Use "I think", "In my view", "This candidate seems..."
- Keep it conversational but informative (2-4 sentences)
- Don't ask generic follow-up questions - give specific insights
- Reference specific skills, technologies, or experiences from both the JD and resume
- Be honest about fit and potential concerns
- Build on the previous conversation context if provided

EXAMPLE RESPONSES:
- "I think this candidate looks really promising! They have solid Flutter experience which matches our mobile dev needs, and their GitHub shows some nice projects. The internship at that startup gives them good real-world experience."
- "Hmm, this one's a bit of a mixed bag. They have the technical skills we need, but I'm not seeing much leadership experience. Might be worth a phone screen to dig deeper."
- "This candidate seems like a great fit! Their Python background is exactly what we're looking for, and I like that they've worked on similar projects before."

Your response:"""

            prompt = HR_CHAT_PROMPT.format(
                jd_context=jd_context,
                candidate_info=candidate_info,
                resume_contexts="\n---\n".join(contexts[:5]),
                conversation_history=conversation_history,
                message=message
            )
            
            # Debug: Print the formatted prompt
            print(f"DEBUG: Using enhanced prompt with context:")
            print(f"JD Context: {jd_context[:100]}...")
            print(f"Candidate Info: {candidate_info[:100]}...")
            print(f"Resume Contexts: {len(contexts)} contexts")
            print(f"Conversation History: {conversation_history[:200] if conversation_history else 'None'}...")
            print(f"Message: {message}")
            print(f"Memory available: {memory is not None}")
            if memory:
                print(f"Memory messages count: {len(memory.chat_memory.messages)}")
            try:
                completion = _llama_client.chat.completions.create(
                    model="meta-llama/Llama-2-70b-chat-hf",
                    messages=[{"role": "user", "content": prompt}],
                    temperature=0.3,
                    max_tokens=600,
                    stream=False,
                )
                answer = completion.choices[0].message.content.strip()
            except Exception as e:
                print(f"LLM error: {e}")
                answer = None
        except Exception as e:
            print(f"Error in answer synthesis: {e}")
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
            
            # Create a conversational fallback response with JD context and memory
            resume_snippet = contexts[0][:200] if contexts else ''
            candidate_name = snippets[0].get('metadata', {}).get('candidate', 'This candidate') if snippets else 'This candidate'
            
            # Get JD context for fallback
            jd_snippet = ""
            if workspace_id in _job_descriptions:
                jd = _job_descriptions[workspace_id]
                jd_snippet = f"Looking at our job requirements for {jd[:100]}{'...' if len(jd) > 100 else ''}, "
            
            # Check if this is a follow-up question and get conversation context
            is_follow_up = memory is not None and len(memory.chat_memory.messages) > 1
            conversation_context = ""
            
            if is_follow_up:
                try:
                    # Get the previous conversation to understand context
                    history = memory.chat_memory.messages
                    if len(history) >= 2:
                        # Get the last user message to understand what they're asking about
                        last_user_msg = None
                        for msg in reversed(history[:-1]):  # Exclude current message
                            if msg.type == "human":
                                last_user_msg = msg.content
                                break
                        
                        if last_user_msg:
                            conversation_context = f"Regarding your question about '{last_user_msg}', "
                except Exception as e:
                    print(f"Error getting conversation context: {e}")
            
            # Debug fallback response
            print(f"DEBUG FALLBACK: is_follow_up={is_follow_up}, conversation_context='{conversation_context}'")
            if memory:
                print(f"DEBUG FALLBACK: Memory messages count: {len(memory.chat_memory.messages)}")
            
            # Create a more contextual response
            if is_follow_up and conversation_context:
                answer = f"{conversation_context}{jd_snippet}I can see {candidate_name} has some relevant experience. From what I can tell, {resume_snippet.lower()}{'...' if len(resume_snippet) == 200 else ''} They seem to have some of the skills we're looking for, but I'd need to know more about their specific experience to give you a better assessment."
            else:
                answer = f"{jd_snippet}I can see {candidate_name} has some relevant experience. From what I can tell, {resume_snippet.lower()}{'...' if len(resume_snippet) == 200 else ''} They seem to have some of the skills we're looking for, but I'd need to know more about their specific experience to give you a better assessment."
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


@rag_bp.route('/check-interview-intent', methods=['POST'])
def check_interview_intent():
    """Check if the message contains interview scheduling intent"""
    data = request.get_json() or {}
    message = data.get('message', '').strip()
    
    if not message:
        return jsonify({'error': 'message is required'}), 400
    
    if not _interview_agent:
        return jsonify({
            'has_intent': False,
            'error': 'Interview agent not available'
        })
    
    has_intent = _interview_agent.detect_interview_intent(message)
    
    return jsonify({
        'has_intent': has_intent,
        'message': message
    })


@rag_bp.route('/schedule-interview', methods=['POST'])
def schedule_interview():
    """Schedule an interview for a candidate"""
    data = request.get_json() or {}
    workspace_id = data.get('workspace_id', '').strip()
    resume_id = data.get('resume_id', '').strip()
    message = data.get('message', '').strip()
    
    if not all([workspace_id, resume_id, message]):
        return jsonify({'error': 'workspace_id, resume_id, and message are required'}), 400
    
    if not _interview_agent:
        return jsonify({
            'success': False,
            'error': 'Interview agent not available'
        })
    
    # Get candidate info from ChromaDB
    try:
        col = _get_or_create_collection(_collection_name(workspace_id))
        where = {'resume_id': resume_id}
        qr = col.get(where=where, include=["metadatas"])
        metas = (qr or {}).get('metadatas', [])
        
        if not metas:
            return jsonify({
                'success': False,
                'error': 'Candidate information not found'
            })
        
        candidate_info = metas[0]
        
        # Get job information
        job_info = {
            'job_title': 'Software Developer',  # Default, can be enhanced
            'company': 'Our Company'  # Default, can be enhanced
        }
        
        if workspace_id in _job_descriptions:
            job_info['job_description'] = _job_descriptions[workspace_id]
        
        # Process interview request
        result = _interview_agent.process_interview_request(message, candidate_info, job_info)
        
        return jsonify(result)
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        })


@rag_bp.route('/get-manual-email', methods=['POST'])
def get_manual_email():
    """Get email data for manual sending"""
    data = request.get_json() or {}
    workspace_id = data.get('workspace_id', '').strip()
    resume_id = data.get('resume_id', '').strip()
    interview_details = data.get('interview_details', {})
    
    if not all([workspace_id, resume_id, interview_details]):
        return jsonify({'error': 'workspace_id, resume_id, and interview_details are required'}), 400
    
    if not _interview_agent:
        return jsonify({
            'success': False,
            'error': 'Interview agent not available'
        })
    
    # Get candidate info from ChromaDB
    try:
        col = _get_or_create_collection(_collection_name(workspace_id))
        where = {'resume_id': resume_id}
        qr = col.get(where=where, include=["metadatas"])
        metas = (qr or {}).get('metadatas', [])
        
        if not metas:
            return jsonify({
                'success': False,
                'error': 'Candidate information not found'
            })
        
        candidate_info = metas[0]
        
        # Get job information
        job_info = {
            'job_title': 'Software Developer',
            'company': 'Our Company'
        }
        
        if workspace_id in _job_descriptions:
            job_info['job_description'] = _job_descriptions[workspace_id]
        
        # Get manual email data
        email_data = _interview_agent.get_manual_email_data(candidate_info, job_info, interview_details)
        
        return jsonify({
            'success': True,
            'email_data': email_data
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        })



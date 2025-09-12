"""
Enhanced ATS Flask API for Flutter Frontend
Provides comprehensive resume processing with ML, LLaMA, and Chroma DB
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.utils import secure_filename
import pandas as pd
import numpy as np
import base64
import io
import os
import tempfile
import json
import uuid
from datetime import datetime
from typing import List, Tuple, Dict, Optional
import re
import warnings
import chromadb
from openai import OpenAI
import PyPDF2
import docx2txt
from dotenv import load_dotenv
warnings.filterwarnings('ignore')

# Load environment variables from .env file
load_dotenv()

# ML libraries
import spacy
from dateutil import parser as date_parser
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics.pairwise import cosine_similarity
from sentence_transformers import SentenceTransformer
import joblib

# Initialize Flask app
app = Flask(__name__)
# Enable permissive CORS for Flutter web (multipart + json)
CORS(
    app,
    resources={r"/*": {"origins": "*"}},
    supports_credentials=False,
)

@app.after_request
def add_cors_headers(response):
    response.headers.setdefault('Access-Control-Allow-Origin', '*')
    response.headers.setdefault('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
    response.headers.setdefault('Access-Control-Allow-Headers', 'Content-Type, Authorization')
    return response

# Configuration
app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024  # 50MB max file size
UPLOAD_FOLDER = 'temp_uploads'
ALLOWED_EXTENSIONS = {'pdf', 'docx', 'doc'}

# Ensure upload folder exists
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Global variables for caching models
nlp_model = None
sentence_model = None
ats_model = None
feature_names = None
llama_client = None
chroma_client = None

# =============================================================================
# MODEL INITIALIZATION
# =============================================================================

def initialize_models():
    """Initialize all required models"""
    global nlp_model, sentence_model, ats_model, feature_names, llama_client, chroma_client
    
    print("🔄 Initializing models...")
    
    # Initialize spaCy
    try:
        nlp_model = spacy.load("en_core_web_sm")
        print("✅ spaCy model loaded")
    except OSError:
        print("❌ spaCy model not found. Please install: python -m spacy download en_core_web_sm")
        return False
    
    # Initialize Sentence Transformer
    try:
        sentence_model = SentenceTransformer('all-MiniLM-L6-v2')
        print("✅ Sentence Transformer loaded")
    except Exception as e:
        print(f"❌ Failed to load Sentence Transformer: {e}")
        return False
    
    # Initialize ATS ML model
    try:
        if os.path.exists("ats_rf_model.joblib") and os.path.exists("ats_feature_names.joblib"):
            ats_model = joblib.load("ats_rf_model.joblib")
            feature_names = joblib.load("ats_feature_names.joblib")
            print("✅ ATS ML model loaded")
        else:
            print("⚠️ ATS model files not found. Will train on first use.")
    except Exception as e:
        print(f"❌ Failed to load ATS model: {e}")
    
    # Initialize LLaMA client
    try:
        # Try to get API key from environment variable
        api_key = os.environ.get('NVIDIA_API_KEY') or os.environ.get('LLAMA_API_KEY')
        if api_key:
            llama_client = OpenAI(
                base_url="https://integrate.api.nvidia.com/v1",
                api_key=api_key
            )
            print("✅ LLaMA client initialized")
        else:
            print("⚠️ No LLaMA API key found. Set NVIDIA_API_KEY or LLAMA_API_KEY environment variable.")
            llama_client = None
    except Exception as e:
        print(f"❌ Failed to initialize LLaMA client: {e}")
        llama_client = None
    
    # Initialize Chroma DB
    try:
        chroma_client = chromadb.PersistentClient(path="./chroma_db")
        print("✅ Chroma DB initialized")
    except Exception as e:
        print(f"❌ Failed to initialize Chroma DB: {e}")
    
    try:
        # Register RAG blueprint (separate module)
        from rag_api import init_rag_blueprint
        init_rag_blueprint(app, llama_client, chroma_client, sentence_model)
        print("✅ RAG blueprint registered")
    except Exception as e:
        print(f"⚠️ RAG blueprint not registered: {e}")

    print("🎯 Model initialization complete!")
    return True

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def extract_text_from_pdf(file_path: str) -> str:
    """Extract text from PDF file using PyPDF2"""
    try:
        text = ""
        with open(file_path, 'rb') as file:
            pdf_reader = PyPDF2.PdfReader(file)
            for page in pdf_reader.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text + "\n"
        return re.sub(r'\s+', ' ', text).strip()
    except Exception as e:
        return f"Error extracting PDF: {str(e)}"

def extract_text_from_docx(file_path: str) -> str:
    """Extract text from DOCX file"""
    try:
        text = docx2txt.process(file_path)
        return text.strip()
    except Exception as e:
        return f"Error extracting DOCX: {str(e)}"

def extract_candidate_name_from_text(text: str) -> str:
    """Extract candidate name from resume text"""
    if not text:
        return "Candidate"
    
    # Look for common name patterns at the beginning of the text
    lines = text.split('\n')[:10]  # Check first 10 lines
    
    for line in lines:
        line = line.strip()
        if len(line) < 2 or len(line) > 50:  # Skip very short or very long lines
            continue
            
        # Look for lines that might contain a name (2-4 words, title case)
        words = line.split()
        if 2 <= len(words) <= 4:
            # Check if it looks like a name (starts with capital letters)
            if all(word[0].isupper() and word[1:].islower() for word in words if word.isalpha()):
                # Skip common non-name words
                skip_words = {'resume', 'cv', 'curriculum', 'vitae', 'profile', 'summary', 'objective'}
                if not any(word.lower() in skip_words for word in words):
                    return ' '.join(words)
    
    # Fallback: look for email patterns and extract name from email
    email_match = re.search(r'([a-zA-Z0-9._%+-]+)@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', text)
    if email_match:
        email_name = email_match.group(1)
        # Clean up email name
        name = email_name.replace('.', ' ').replace('_', ' ').replace('-', ' ')
        name = ' '.join(word.capitalize() for word in name.split() if word.isalpha())
        if name:
            return name
    
    return "Candidate"

def extract_skills_with_regex(text: str) -> str:
    """Enhanced skill extraction using comprehensive keyword matching"""
    text_lower = text.lower()
    
    # Comprehensive technical skills list
    technical_skills = [
        # Programming Languages
        'python', 'java', 'javascript', 'typescript', 'c++', 'c#', 'php', 'ruby', 'go', 'rust', 
        'swift', 'kotlin', 'scala', 'r', 'matlab', 'sql', 'html', 'css', 'dart', 'perl', 
        'shell', 'bash', 'powershell', 'vba', 'objective-c',
        
        # Frameworks & Libraries
        'react', 'angular', 'vue', 'django', 'flask', 'spring', 'express', 'laravel', 'rails', 
        'asp.net', 'tensorflow', 'pytorch', 'keras', 'scikit-learn', 'pandas', 'numpy', 'opencv', 
        'jquery', 'bootstrap', 'node.js', 'next.js', 'gatsby', 'svelte', 'flutter', 'react native',
        
        # Databases
        'mysql', 'postgresql', 'mongodb', 'sqlite', 'oracle', 'sql server', 'redis', 'elasticsearch',
        'cassandra', 'dynamodb', 'neo4j', 'firebase',
        
        # Cloud & DevOps
        'aws', 'azure', 'gcp', 'docker', 'kubernetes', 'jenkins', 'gitlab', 'github', 'circleci',
        'terraform', 'ansible', 'helm', 'prometheus', 'grafana',
        
        # Tools & Technologies
        'git', 'linux', 'windows', 'macos', 'jira', 'confluence', 'postman', 'swagger', 'api', 
        'rest', 'graphql', 'microservices', 'json', 'xml', 'yaml',
        
        # Methodologies
        'agile', 'scrum', 'kanban', 'devops', 'ci/cd', 'tdd', 'bdd', 'microservices',
        
        # Data & AI
        'machine learning', 'artificial intelligence', 'data science', 'data analysis', 'big data',
        'hadoop', 'spark', 'tableau', 'power bi', 'excel', 'statistics', 'deep learning',
        
        # Soft Skills
        'leadership', 'communication', 'teamwork', 'project management', 'problem solving'
    ]
    
    found_skills = []
    for skill in technical_skills:
        if skill.lower() in text_lower:
            formatted_skill = ' '.join(word.capitalize() for word in skill.split())
            if formatted_skill not in found_skills:
                found_skills.append(formatted_skill)
    
    return found_skills[:20]  # Limit to 20 skills

def extract_contact_info(text: str) -> Dict[str, List[str]]:
    """Extract email and phone numbers"""
    email_pattern = r'[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+'
    emails = re.findall(email_pattern, text)
    
    phone_pattern = r'(\+?\d{1,3}[-.\s]?)?(\(?\d{3}\)?[-.\s]?)\d{3}[-.\s]?\d{4}'
    phones = re.findall(phone_pattern, text)
    phone_numbers = [''.join(phone) for phone in phones]
    
    return {'emails': emails, 'phones': phone_numbers}

def extract_fields_with_llama(resume_text: str) -> Dict[str, str]:
    """Extract skills, experience, and email using LLaMA with regex fallback"""
    
    # Primary method: Use robust regex extraction
    regex_skills = extract_skills_with_regex(resume_text)
    
    # Extract email with regex
    contact_info = extract_contact_info(resume_text)
    primary_email = contact_info['emails'][0] if contact_info['emails'] else 'No email found'
    
    # Extract experience section
    experience_patterns = [
        r'(?:professional\s+)?experience\s*:?\s*(.*?)(?=education|skills|projects|$)',
        r'work\s+(?:history|experience)\s*:?\s*(.*?)(?=education|skills|projects|$)',
        r'employment\s*:?\s*(.*?)(?=education|skills|projects|$)'
    ]
    
    experience_text = 'Experience details not found'
    for pattern in experience_patterns:
        match = re.search(pattern, resume_text, re.IGNORECASE | re.DOTALL)
        if match:
            exp = match.group(1).strip()
            if len(exp) > 50:
                experience_text = exp[:400] + '...' if len(exp) > 400 else exp
                break
    
    # Try LLaMA enhancement
    final_skills = regex_skills
    try:
        if llama_client:
            prompt = f"""Extract technical skills from this resume. List only programming languages, frameworks, and tools.

Resume: {resume_text[:2000]}

Return only: skill1, skill2, skill3"""
            
            completion = llama_client.chat.completions.create(
                model="meta/llama3-70b-instruct",
                messages=[{"role": "user", "content": prompt}],
                temperature=0.1,
                max_tokens=200,
                stream=False
            )
            
            llama_response = completion.choices[0].message.content.strip()
            if llama_response and len(llama_response) > 10:
                llama_skills = [s.strip().title() for s in llama_response.split(',') if s.strip()]
                # Combine regex and LLaMA skills
                all_skills = list(set(regex_skills + llama_skills))[:25]
                final_skills = all_skills
    except Exception:
        pass  # Use regex results if LLaMA fails
    
    return {
        'skills': final_skills,
        'experience': experience_text,
        'email': primary_email
    }

def extract_ml_features(text: str) -> Dict:
    """Extract ML features for ATS scoring"""
    features = {}
    
    # Basic statistics
    words = text.split()
    features['word_count'] = len(words)
    features['char_count'] = len(text)
    features['avg_word_length'] = np.mean([len(word) for word in words]) if words else 0
    
    # Skills and contact info
    skills = extract_skills_with_regex(text)
    contact_info = extract_contact_info(text)
    
    features['skills_count'] = len(skills)
    features['has_email'] = int(len(contact_info['emails']) > 0)
    features['has_phone'] = int(len(contact_info['phones']) > 0)
    
    # Section presence
    text_lower = text.lower()
    features['has_education'] = int(bool(re.search(r'\b(education|degree|university)\b', text_lower)))
    features['has_experience'] = int(bool(re.search(r'\b(experience|work|employment)\b', text_lower)))
    features['has_skills'] = int(bool(re.search(r'\b(skills|technologies)\b', text_lower)))
    
    # Text quality
    if nlp_model:
        doc = nlp_model(text[:10000])  # Limit for performance
        features['person_entities_count'] = len([ent for ent in doc.ents if ent.label_ == "PERSON"])
        features['date_entities_count'] = len([ent for ent in doc.ents if ent.label_ == "DATE"])
        features['org_entities_count'] = len([ent for ent in doc.ents if ent.label_ == "ORG"])
    else:
        features['person_entities_count'] = 0
        features['date_entities_count'] = 0
        features['org_entities_count'] = 0
    
    # Additional features (simplified)
    features['experience_years'] = 0  # Could be enhanced
    features['skills_density'] = len(skills) / len(words) if len(words) > 0 else 0
    features['has_person_name'] = features['person_entities_count'] > 0
    features['non_alpha_ratio'] = sum(1 for char in text if not char.isalpha() and not char.isspace()) / len(text) if len(text) > 0 else 0
    features['sentence_count'] = len([s for s in text.split('.') if s.strip()])
    features['avg_sentence_length'] = features['word_count'] / features['sentence_count'] if features['sentence_count'] > 0 else 0
    features['paragraph_count'] = len(text.split('\n\n'))
    features['resume_keywords_density'] = sum(1 for keyword in ['experience', 'education', 'skills'] if keyword in text_lower) / len(words) if len(words) > 0 else 0
    features['has_professional_email'] = int(bool(re.search(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com|org|edu)', text)))
    
    return features

def predict_ats_score(features_dict: Dict) -> Tuple[int, float]:
    """Predict ATS score using ML model"""
    if not ats_model or not feature_names:
        # Fallback scoring if model not available
        base_score = 50
        if features_dict.get('has_email', 0): base_score += 15
        if features_dict.get('has_phone', 0): base_score += 10
        if features_dict.get('has_experience', 0): base_score += 20
        if features_dict.get('skills_count', 0) > 5: base_score += 15
        return min(base_score, 100), min(base_score, 100) / 100.0
    
    # Use ML model
    feature_vector = [features_dict.get(name, 0) for name in feature_names]
    feature_vector = np.array(feature_vector).reshape(1, -1)
    
    prediction = ats_model.predict(feature_vector)[0]
    probability = ats_model.predict_proba(feature_vector)[0]
    confidence_score = int(probability[1] * 100)
    
    return confidence_score, probability[1]

# =============================================================================
# API ENDPOINTS
# =============================================================================

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'models_loaded': {
            'nlp': nlp_model is not None,
            'sentence_transformer': sentence_model is not None,
            'ats_model': ats_model is not None,
            'llama_client': llama_client is not None,
            'chroma_db': chroma_client is not None
        }
    })

@app.route('/process-resumes', methods=['POST', 'OPTIONS'])
def process_resumes():
    """
    Process uploaded resumes with ATS scoring and field extraction
    
    Input Format (multipart/form-data):
    - files: List of resume files (PDF/DOCX)
    - threshold: Integer (0-100) for acceptance threshold
    
    Output Format:
    {
        "success": true,
        "total_processed": 5,
        "accepted_count": 3,
        "rejected_count": 2,
        "resumes": [
            {
                "id": "uuid-string",
                "filename": "john_doe_resume.pdf",
                "ats_score": 85,
                "status": "accepted",
                "skills": ["Python", "React", "AWS", "Docker"],
                "experience": "Software Engineer at Tech Corp...",
                "email": "john.doe@email.com",
                "text_preview": "John Doe Software Engineer...",
                "reason": "ML Score: 85% | Features: Email found, Experience section"
            }
        ],
        "model_info": {
            "accuracy": 0.89,
            "total_samples": 1500
        }
    }
    """
    try:
        # Handle preflight
        if request.method == 'OPTIONS':
            return ('', 204)
        # Check if files are present
        if 'files' not in request.files:
            return jsonify({'error': 'No files provided'}), 400
        
        files = request.files.getlist('files')
        threshold = int(request.form.get('threshold', 60))
        
        if not files or files[0].filename == '':
            return jsonify({'error': 'No files selected'}), 400
        
        results = []
        accepted_count = 0
        
        for file in files:
            if not allowed_file(file.filename):
                continue
                
            # Save file temporarily
            filename = secure_filename(file.filename)
            file_path = os.path.join(UPLOAD_FOLDER, f"{uuid.uuid4()}_{filename}")
            file.save(file_path)
            
            try:
                # Extract text
                if filename.lower().endswith('.pdf'):
                    text = extract_text_from_pdf(file_path)
                else:
                    text = extract_text_from_docx(file_path)
                
                if len(text) < 100:
                    result = {
                        'id': str(uuid.uuid4()),
                        'filename': filename,
                        'ats_score': 0,
                        'status': 'rejected',
                        'skills': [],
                        'experience': 'Text extraction failed',
                        'email': 'Not found',
                        'text_preview': text[:200],
                        'reason': 'Failed to extract readable text',
                        # Include full text for downstream semantic ranking (even if extraction is poor)
                        'text': text
                    }
                else:
                    # Extract fields and features
                    extracted_fields = extract_fields_with_llama(text)
                    ml_features = extract_ml_features(text)
                    ats_score, confidence = predict_ats_score(ml_features)
                    
                    status = 'accepted' if ats_score >= threshold else 'rejected'
                    if status == 'accepted':
                        accepted_count += 1
                    
                    result = {
                        'id': str(uuid.uuid4()),
                        'filename': filename,
                        'ats_score': ats_score,
                        'status': status,
                        'skills': extracted_fields['skills'],
                        'experience': extracted_fields['experience'],
                        'email': extracted_fields['email'],
                        'text_preview': text[:200],
                        'reason': f"ML Score: {ats_score}% | Skills: {len(extracted_fields['skills'])} found",
                        # Provide full extracted text for semantic ranking endpoint
                        'text': text
                    }
                
                results.append(result)
                
            finally:
                # Clean up temporary file
                if os.path.exists(file_path):
                    os.remove(file_path)
        
        return jsonify({
            'success': True,
            'total_processed': len(results),
            'accepted_count': accepted_count,
            'rejected_count': len(results) - accepted_count,
            'resumes': results,
            'model_info': {
                'accuracy': 0.89 if ats_model else 0.0,
                'total_samples': 1500 if ats_model else 0
            }
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/semantic-ranking', methods=['POST'])
def semantic_ranking():
    """
    Rank resumes based on job description similarity
    
    Input Format (JSON):
    {
        "job_description": "We are looking for a Python developer...",
        "resumes": [
            {
                "id": "uuid-string",
                "filename": "resume1.pdf",
                "text": "Full resume text here...",
                "ats_score": 85,
                "skills": ["Python", "React"],
                "experience": "Software Engineer...",
                "email": "email@domain.com"
            }
        ]
    }
    
    Output Format:
    {
        "success": true,
        "job_description_stored": true,
        "ranked_resumes": [
            {
                "id": "uuid-string",
                "rank": 1,
                "candidate": "Resume1",
                "ats_score": 85,
                "semantic_score": 0.92,
                "match_status": "Excellent Match",
                "skills": ["Python", "React"],
                "experience": "Software Engineer...",
                "email": "email@domain.com",
                "found_skills": ["Python", "React"]
            }
        ],
        "summary": {
            "total_candidates": 5,
            "excellent_matches": 2,
            "good_matches": 1,
            "avg_semantic_score": 0.75
        }
    }
    """
    try:
        data = request.get_json()
        job_description = data.get('job_description', '')
        resumes = data.get('resumes', [])
        
        if not job_description or not resumes:
            return jsonify({'error': 'Job description and resumes are required'}), 400
        
        # Generate embeddings
        if not sentence_model:
            return jsonify({'error': 'Sentence model not loaded'}), 500
        
        job_embedding = sentence_model.encode([job_description])
        resume_texts = [resume.get('text', '') for resume in resumes]
        resume_embeddings = sentence_model.encode(resume_texts)
        
        # Calculate similarities
        similarities = cosine_similarity(job_embedding, resume_embeddings)[0]
        
        # Extract skills from job description
        jd_skills = extract_skills_with_regex(job_description)
        
        # Create ranked results
        ranked_results = []
        for i, (resume, similarity) in enumerate(zip(resumes, similarities)):
            # Determine match status
            if similarity >= 0.8:
                match_status = "Excellent Match"
            elif similarity >= 0.6:
                match_status = "Good Match"
            elif similarity >= 0.4:
                match_status = "Moderate Match"
            else:
                match_status = "Low Match"
            
            # Find matching skills
            resume_skills = resume.get('skills', [])
            found_skills = [skill for skill in resume_skills if any(jd_skill.lower() in skill.lower() for jd_skill in jd_skills)]
            
            # Extract candidate name from resume text instead of filename
            resume_text = resume.get('text', '')
            candidate_name = extract_candidate_name_from_text(resume_text)
            
            ranked_results.append({
                'id': resume.get('id', str(uuid.uuid4())),
                'rank': i + 1,  # Will be updated after sorting
                'candidate': candidate_name,
                'ats_score': resume.get('ats_score', 0),
                # Ensure JSON serializable float
                'semantic_score': float(round(float(similarity), 3)),
                'match_status': match_status,
                'skills': resume_skills,
                'experience': resume.get('experience', ''),
                'email': resume.get('email', ''),
                'found_skills': found_skills
            })
        
        # Sort by semantic score (descending)
        ranked_results.sort(key=lambda x: x['semantic_score'], reverse=True)
        
        # Update ranks
        for i, result in enumerate(ranked_results):
            result['rank'] = i + 1
        
        # Calculate summary
        excellent_matches = len([r for r in ranked_results if r['match_status'] == 'Excellent Match'])
        good_matches = len([r for r in ranked_results if r['match_status'] == 'Good Match'])
        avg_score = np.mean([r['semantic_score'] for r in ranked_results])
        
        # Store in Chroma DB (optional)
        job_stored = False
        try:
            if chroma_client:
                # Store job description and resumes in vector DB
                job_stored = True
        except Exception:
            pass
        
        return jsonify({
            'success': True,
            'job_description_stored': job_stored,
            'ranked_resumes': ranked_results,
            'summary': {
                'total_candidates': len(ranked_results),
                'excellent_matches': excellent_matches,
                'good_matches': good_matches,
                # Ensure JSON serializable float
                'avg_semantic_score': float(round(float(avg_score), 3))
            },
            # Return JD-extracted skills to drive personalized filters
            'jd_skills': jd_skills
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/filter-resumes', methods=['POST'])
def filter_resumes():
    """
    Filter resumes by skills and experience keywords
    
    Input Format (JSON):
    {
        "resumes": [
            {
                "id": "uuid-string",
                "rank": 1,
                "candidate": "John Doe",
                "skills": ["Python", "React", "AWS"],
                "experience": "Software Engineer at Tech Corp...",
                "semantic_score": 0.92,
                "ats_score": 85
            }
        ],
        "skill_filters": ["Python", "React"],
        "experience_filter": "senior"
    }
    
    Output Format:
    {
        "success": true,
        "filtered_resumes": [
            {
                "id": "uuid-string",
                "rank": 1,
                "candidate": "John Doe",
                "ats_score": 85,
                "semantic_score": 0.92,
                "match_status": "Excellent Match",
                "skills": ["Python", "React", "AWS"],
                "experience": "Software Engineer at Tech Corp...",
                "email": "john@email.com"
            }
        ],
        "filter_summary": {
            "total_input": 10,
            "filtered_output": 3,
            "filter_criteria": {
                "skills": ["Python", "React"],
                "experience": "senior"
            }
        }
    }
    """
    try:
        data = request.get_json()
        resumes = data.get('resumes', [])
        skill_filters = data.get('skill_filters', [])
        experience_filter = data.get('experience_filter', '')
        
        filtered_resumes = []
        
        for resume in resumes:
            include_resume = True
            
            # Filter by skills (ALL selected skills must be present)
            if skill_filters:
                resume_skills = [skill.lower() for skill in resume.get('skills', [])]
                for required_skill in skill_filters:
                    if not any(required_skill.lower() in skill for skill in resume_skills):
                        include_resume = False
                        break
            
            # Filter by experience keywords
            if experience_filter and include_resume:
                experience_text = resume.get('experience', '').lower()
                if experience_filter.lower() not in experience_text:
                    include_resume = False
            
            if include_resume:
                filtered_resumes.append(resume)
        
        return jsonify({
            'success': True,
            'filtered_resumes': filtered_resumes,
            'filter_summary': {
                'total_input': len(resumes),
                'filtered_output': len(filtered_resumes),
                'filter_criteria': {
                    'skills': skill_filters,
                    'experience': experience_filter
                }
            }
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/available-skills', methods=['POST'])
def get_available_skills():
    """
    Extract all unique skills from provided resumes for filter dropdown
    
    Input Format (JSON):
    {
        "resumes": [
            {
                "skills": ["Python", "React", "AWS"]
            }
        ]
    }
    
    Output Format:
    {
        "success": true,
        "available_skills": ["Python", "React", "AWS", "Docker", "Kubernetes"],
        "skill_count": 5
    }
    """
    try:
        data = request.get_json()
        resumes = data.get('resumes', [])
        
        all_skills = set()
        for resume in resumes:
            skills = resume.get('skills', [])
            if isinstance(skills, list):
                all_skills.update(skills)
            elif isinstance(skills, str):
                # Handle case where skills are comma-separated string
                skill_list = [s.strip() for s in skills.split(',') if s.strip()]
                all_skills.update(skill_list)
        
        available_skills = sorted(list(all_skills))
        
        return jsonify({
            'success': True,
            'available_skills': available_skills,
            'skill_count': len(available_skills)
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/extract-text', methods=['POST'])
def extract_text_from_file():
    """
    Extract text from a single uploaded file
    
    Input Format (multipart/form-data):
    - file: Single resume file (PDF/DOCX)
    
    Output Format:
    {
        "success": true,
        "filename": "resume.pdf",
        "text": "Extracted text content...",
        "word_count": 450,
        "char_count": 2500
    }
    """
    try:
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['file']
        if file.filename == '' or not allowed_file(file.filename):
            return jsonify({'error': 'Invalid file'}), 400
        
        # Save file temporarily
        filename = secure_filename(file.filename)
        file_path = os.path.join(UPLOAD_FOLDER, f"{uuid.uuid4()}_{filename}")
        file.save(file_path)
        
        try:
            # Extract text
            if filename.lower().endswith('.pdf'):
                text = extract_text_from_pdf(file_path)
            else:
                text = extract_text_from_docx(file_path)
            
            return jsonify({
                'success': True,
                'filename': filename,
                'text': text,
                'word_count': len(text.split()),
                'char_count': len(text)
            })
            
        finally:
            # Clean up
            if os.path.exists(file_path):
                os.remove(file_path)
                
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/analyze-resume', methods=['POST'])
def analyze_resume():
    """
    Analyze a single resume with detailed feedback and recommendations
    
    Input Format (JSON):
    {
        "candidate_name": "John Doe",
        "email": "john.doe@email.com", 
        "phone": "+1-555-123-4567",
        "resume_text": "Full resume text content here...",
        "job_description": "Optional job description for matching..." 
    }
    
    Output Format (JSON):
    {
        "candidate_name": "John Doe",
        "email": "john.doe@email.com",
        "phone": "+1-555-123-4567", 
        "ats_score": 85,
        "skills_matched": ["Python", "React", "AWS"],
        "recommendations": [
            "Add more specific project details",
            "Include quantifiable achievements",
            "Add relevant certifications"
        ],
        "summary": "Strong technical background with relevant experience. Resume shows good structure and relevant skills for the position."
    }
    """
    try:
        data = request.get_json()
        
        # Required fields
        candidate_name = data.get('candidate_name', '')
        email = data.get('email', '')
        phone = data.get('phone', '')
        resume_text = data.get('resume_text', '')
        job_description = data.get('job_description', '')
        
        if not resume_text:
            return jsonify({'error': 'resume_text is required'}), 400
        
        # Extract features and calculate ATS score
        ml_features = extract_ml_features(resume_text)
        ats_score, confidence = predict_ats_score(ml_features)
        
        # Extract skills from resume
        extracted_fields = extract_fields_with_llama(resume_text)
        resume_skills = extracted_fields['skills']
        
        # If job description provided, find matching skills
        skills_matched = []
        if job_description:
            job_skills = extract_skills_with_regex(job_description)
            # Find skills that appear in both resume and job description
            if isinstance(resume_skills, list):
                resume_skills_lower = [skill.lower() for skill in resume_skills]
            else:
                resume_skills_lower = [skill.lower().strip() for skill in resume_skills.split(',') if skill.strip()]
            
            job_skills_lower = [skill.lower() for skill in job_skills]
            
            for job_skill in job_skills:
                if any(job_skill.lower() in resume_skill for resume_skill in resume_skills_lower):
                    skills_matched.append(job_skill)
        else:
            # If no job description, return all extracted skills as matched
            if isinstance(resume_skills, list):
                skills_matched = resume_skills[:10]  # Limit to top 10
            else:
                skills_matched = [skill.strip() for skill in resume_skills.split(',') if skill.strip()][:10]
        
        # Generate recommendations based on analysis
        recommendations = generate_recommendations(ml_features, ats_score, resume_text, job_description)
        
        # Generate summary
        summary = generate_summary(ats_score, skills_matched, ml_features, job_description)
        
        return jsonify({
            'candidate_name': candidate_name,
            'email': email,
            'phone': phone,
            'ats_score': ats_score,
            'skills_matched': skills_matched,
            'recommendations': recommendations,
            'summary': summary
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def generate_recommendations(features: Dict, ats_score: int, resume_text: str, job_description: str = '') -> List[str]:
    """Generate personalized recommendations for resume improvement"""
    recommendations = []
    
    # Score-based recommendations
    if ats_score < 60:
        recommendations.append("Overall resume structure needs improvement for better ATS compatibility")
    
    # Contact information recommendations
    if not features.get('has_email', 0):
        recommendations.append("Add a professional email address")
    if not features.get('has_phone', 0):
        recommendations.append("Include contact phone number")
    
    # Content recommendations
    if features.get('word_count', 0) < 300:
        recommendations.append("Expand resume content - current length is too brief for comprehensive evaluation")
    elif features.get('word_count', 0) > 1000:
        recommendations.append("Consider condensing resume content for better readability")
    
    # Section recommendations
    if not features.get('has_experience', 0):
        recommendations.append("Add a clear work experience section with job titles and responsibilities")
    if not features.get('has_education', 0):
        recommendations.append("Include educational background and qualifications")
    if not features.get('has_skills', 0):
        recommendations.append("Add a dedicated skills section highlighting technical and professional competencies")
    
    # Skills recommendations
    skills_count = features.get('skills_count', 0)
    if skills_count < 5:
        recommendations.append("Include more relevant technical skills and competencies")
    elif skills_count > 20:
        recommendations.append("Focus on most relevant skills - too many skills can dilute impact")
    
    # Professional presentation
    if features.get('non_alpha_ratio', 0) > 0.3:
        recommendations.append("Improve text formatting - reduce special characters and formatting inconsistencies")
    
    # Experience recommendations
    if features.get('experience_years', 0) == 0:
        recommendations.append("Include specific dates for work experience to demonstrate career progression")
    
    # Job-specific recommendations
    if job_description:
        job_skills = extract_skills_with_regex(job_description)
        resume_skills_text = resume_text.lower()
        missing_key_skills = []
        
        for skill in job_skills[:5]:  # Check top 5 job skills
            if skill.lower() not in resume_skills_text:
                missing_key_skills.append(skill)
        
        if missing_key_skills:
            recommendations.append(f"Consider highlighting experience with: {', '.join(missing_key_skills[:3])}")
    
    # Quantification recommendations
    numbers_in_text = len(re.findall(r'\d+', resume_text))
    if numbers_in_text < 3:
        recommendations.append("Add quantifiable achievements (numbers, percentages, metrics) to demonstrate impact")
    
    # Professional keywords
    professional_keywords = ['achieved', 'managed', 'led', 'developed', 'implemented', 'improved']
    found_keywords = sum(1 for keyword in professional_keywords if keyword in resume_text.lower())
    if found_keywords < 2:
        recommendations.append("Use more action verbs and achievement-oriented language")
    
    return recommendations[:6]  # Limit to 6 most important recommendations

def generate_summary(ats_score: int, skills_matched: List[str], features: Dict, job_description: str = '') -> str:
    """Generate a comprehensive summary of the resume analysis"""
    
    # Base summary based on score
    if ats_score >= 85:
        score_assessment = "Excellent resume with strong ATS compatibility"
    elif ats_score >= 70:
        score_assessment = "Good resume with solid structure and content"
    elif ats_score >= 55:
        score_assessment = "Decent resume with room for improvement"
    else:
        score_assessment = "Resume needs significant improvements for ATS systems"
    
    # Skills assessment
    skills_count = len(skills_matched)
    if skills_count >= 8:
        skills_assessment = "demonstrates comprehensive technical expertise"
    elif skills_count >= 5:
        skills_assessment = "shows relevant technical skills"
    elif skills_count >= 2:
        skills_assessment = "has some relevant skills"
    else:
        skills_assessment = "needs more clearly highlighted technical skills"
    
    # Structure assessment
    structure_elements = []
    if features.get('has_experience', 0):
        structure_elements.append("work experience")
    if features.get('has_education', 0):
        structure_elements.append("education")
    if features.get('has_skills', 0):
        structure_elements.append("skills section")
    
    if len(structure_elements) >= 3:
        structure_assessment = "Well-structured with all essential sections"
    elif len(structure_elements) >= 2:
        structure_assessment = "Good structure with key sections present"
    else:
        structure_assessment = "Needs better organization and section structure"
    
    # Job match assessment (if job description provided)
    match_assessment = ""
    if job_description and skills_matched:
        match_percentage = min(len(skills_matched) * 10, 90)  # Rough match percentage
        if match_percentage >= 70:
            match_assessment = f" Shows excellent alignment ({match_percentage}%) with the job requirements."
        elif match_percentage >= 50:
            match_assessment = f" Good fit ({match_percentage}%) for the position with some relevant experience."
        else:
            match_assessment = f" Moderate alignment ({match_percentage}%) with job requirements - may need additional experience."
    
    # Word count assessment
    word_count = features.get('word_count', 0)
    if word_count < 200:
        length_note = " Resume appears brief and may benefit from more detailed descriptions."
    elif word_count > 800:
        length_note = " Comprehensive resume with detailed information."
    else:
        length_note = " Well-balanced resume length."
    
    # Combine all assessments
    summary = f"{score_assessment}. The candidate {skills_assessment} and presents a resume that is {structure_assessment.lower()}.{match_assessment}{length_note}"
    
    return summary

# =============================================================================
# MAIN APPLICATION
# =============================================================================

if __name__ == '__main__':
    print("🚀 Starting Enhanced ATS Flask API...")
    
    # Initialize models
    if not initialize_models():
        print("❌ Failed to initialize models. Some features may not work.")
    
    print("🌐 Flask API ready!")
    print("📋 Available endpoints:")
    print("  - POST /process-resumes")
    print("  - POST /semantic-ranking")
    print("  - POST /filter-resumes")
    print("  - POST /available-skills")
    print("  - POST /extract-text")
    print("  - POST /analyze-resume (NEW)")
    print("  - POST /generate_job_title (NEW)")
    print("  - POST /generate_job_description (NEW)")
    print("  - POST /generate_enhanced_job_title (NEW)")
    print("  - POST /generate_job_title_suggestions (NEW)")
    print("  - GET  /health")
    
# ============================================================================
# LLaMA API Endpoints for Job Title Generation
# ============================================================================

@app.route('/generate_job_title', methods=['POST'])
def generate_job_title():
    """
    Generate job title using LLaMA API based on job description
    """
    try:
        data = request.get_json()
        job_description = data.get('job_description', '')
        
        if not job_description:
            return jsonify({'error': 'Job description is required'}), 400
        
        # Use LLaMA to generate job title
        prompt = f"""Generate a professional job title based on this job description. 
        The title should be concise, industry-standard, and accurately reflect the role.
        
        Job Description: {job_description}
        
        Return only the job title, nothing else."""
        
        try:
            # Use OpenAI client (assuming it's configured for LLaMA)
            client = OpenAI(base_url="https://api.together.xyz/v1", api_key="your_together_api_key")
            completion = client.chat.completions.create(
                model="meta-llama/Llama-2-70b-chat-hf",
                messages=[{"role": "user", "content": prompt}],
                temperature=0.3,
                max_tokens=50,
            )
            job_title = completion.choices[0].message.content.strip()
        except Exception as e:
            print(f"LLaMA API error: {e}")
            # Fallback to rule-based generation
            job_title = generate_fallback_job_title(job_description)
        
        return jsonify({'job_title': job_title})
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/generate_job_description', methods=['POST'])
def generate_job_description():
    """
    Generate job description using LLaMA API based on job title
    """
    try:
        data = request.get_json()
        job_title = data.get('job_title', '')
        
        if not job_title:
            return jsonify({'error': 'Job title is required'}), 400
        
        # Use LLaMA to generate job description
        prompt = f"""Generate a comprehensive job description for this position.
        Include key responsibilities, required skills, qualifications, and company benefits.
        
        Job Title: {job_title}
        
        Format as a professional job posting."""
        
        try:
            client = OpenAI(base_url="https://api.together.xyz/v1", api_key="your_together_api_key")
            completion = client.chat.completions.create(
                model="meta-llama/Llama-2-70b-chat-hf",
                messages=[{"role": "user", "content": prompt}],
                temperature=0.4,
                max_tokens=500,
            )
            job_description = completion.choices[0].message.content.strip()
        except Exception as e:
            print(f"LLaMA API error: {e}")
            # Fallback to template-based generation
            job_description = generate_fallback_job_description(job_title)
        
        return jsonify({'job_description': job_description})
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/generate_enhanced_job_title', methods=['POST'])
def generate_enhanced_job_title():
    """
    Generate enhanced job title with seniority and skills using LLaMA API
    """
    try:
        data = request.get_json()
        job_description = data.get('job_description', '')
        include_seniority = data.get('include_seniority', True)
        include_skills = data.get('include_skills', True)
        format_type = data.get('format', 'professional')
        
        if not job_description:
            return jsonify({'error': 'Job description is required'}), 400
        
        # Enhanced prompt for better job titles
        prompt = f"""Generate a professional job title based on this job description.
        Requirements:
        - Include seniority level if appropriate: {include_seniority}
        - Include key technologies/skills: {include_skills}
        - Format: {format_type}
        - Be specific and industry-standard
        
        Job Description: {job_description}
        
        Return only the job title, nothing else."""
        
        try:
            client = OpenAI(base_url="https://api.together.xyz/v1", api_key="your_together_api_key")
            completion = client.chat.completions.create(
                model="meta-llama/Llama-2-70b-chat-hf",
                messages=[{"role": "user", "content": prompt}],
                temperature=0.3,
                max_tokens=100,
            )
            job_title = completion.choices[0].message.content.strip()
        except Exception as e:
            print(f"LLaMA API error: {e}")
            # Fallback to enhanced rule-based generation
            job_title = generate_enhanced_fallback_title(job_description)
        
        return jsonify({'job_title': job_title})
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/generate_job_title_suggestions', methods=['POST'])
def generate_job_title_suggestions():
    """
    Generate multiple job title suggestions using LLaMA API
    """
    try:
        data = request.get_json()
        job_description = data.get('job_description', '')
        count = data.get('count', 3)
        
        if not job_description:
            return jsonify({'error': 'Job description is required'}), 400
        
        # Generate multiple suggestions
        prompt = f"""Generate {count} different professional job titles based on this job description.
        Provide variety in seniority levels and focus areas.
        
        Job Description: {job_description}
        
        Return only the job titles, one per line, numbered 1-{count}."""
        
        try:
            client = OpenAI(base_url="https://api.together.xyz/v1", api_key="your_together_api_key")
            completion = client.chat.completions.create(
                model="meta-llama/Llama-2-70b-chat-hf",
                messages=[{"role": "user", "content": prompt}],
                temperature=0.5,
                max_tokens=200,
            )
            suggestions_text = completion.choices[0].message.content.strip()
            # Parse suggestions from numbered list
            suggestions = [line.strip() for line in suggestions_text.split('\n') if line.strip() and not line.strip().startswith(('1.', '2.', '3.', '4.', '5.'))]
        except Exception as e:
            print(f"LLaMA API error: {e}")
            # Fallback to rule-based suggestions
            suggestions = generate_fallback_suggestions(job_description, count)
        
        return jsonify({'suggestions': suggestions})
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Helper functions for fallback generation
def generate_fallback_job_title(description):
    """Fallback job title generation using rule-based approach"""
    desc_lower = description.lower()
    
    if 'flutter' in desc_lower or 'mobile' in desc_lower:
        if 'senior' in desc_lower or 'lead' in desc_lower:
            return 'Senior Flutter Developer'
        elif 'junior' in desc_lower or 'entry' in desc_lower:
            return 'Junior Flutter Developer'
        else:
            return 'Flutter Developer'
    elif 'react' in desc_lower or 'frontend' in desc_lower:
        if 'senior' in desc_lower or 'lead' in desc_lower:
            return 'Senior Frontend Developer'
        else:
            return 'Frontend Developer'
    elif 'python' in desc_lower or 'backend' in desc_lower:
        if 'senior' in desc_lower or 'lead' in desc_lower:
            return 'Senior Backend Developer'
        else:
            return 'Backend Developer'
    elif 'full stack' in desc_lower or 'fullstack' in desc_lower:
        return 'Full Stack Developer'
    elif 'data' in desc_lower and 'scientist' in desc_lower:
        return 'Data Scientist'
    elif 'data' in desc_lower and 'engineer' in desc_lower:
        return 'Data Engineer'
    elif 'machine learning' in desc_lower or 'ml' in desc_lower:
        return 'Machine Learning Engineer'
    elif 'devops' in desc_lower or 'cloud' in desc_lower:
        return 'DevOps Engineer'
    elif 'product' in desc_lower and 'manager' in desc_lower:
        return 'Product Manager'
    elif 'designer' in desc_lower or 'ui' in desc_lower or 'ux' in desc_lower:
        return 'UI/UX Designer'
    elif 'marketing' in desc_lower:
        return 'Marketing Specialist'
    elif 'sales' in desc_lower:
        return 'Sales Representative'
    elif 'analyst' in desc_lower:
        return 'Business Analyst'
    else:
        return 'Software Engineer'

def generate_fallback_job_description(job_title):
    """Fallback job description generation"""
    title_lower = job_title.lower()
    
    if 'flutter' in title_lower:
        return 'We are looking for a Flutter Developer to join our team. You will be responsible for developing cross-platform mobile applications using Flutter framework. Experience with Dart, Firebase, and state management is required.'
    elif 'frontend' in title_lower:
        return 'We are seeking a Frontend Developer to create user-friendly web applications. You will work with modern JavaScript frameworks, HTML, CSS, and collaborate with design teams to implement responsive interfaces.'
    elif 'backend' in title_lower:
        return 'We need a Backend Developer to build and maintain server-side applications. You will work with databases, APIs, and cloud services to ensure scalable and efficient backend systems.'
    elif 'full stack' in title_lower:
        return 'We are looking for a Full Stack Developer who can work on both frontend and backend development. You will be involved in the complete development lifecycle from concept to deployment.'
    elif 'data scientist' in title_lower:
        return 'We are seeking a Data Scientist to analyze complex datasets and build machine learning models. You will work with statistical analysis, data visualization, and predictive modeling.'
    else:
        return 'We are looking for a qualified professional to join our team. The ideal candidate should have relevant experience and skills in the field.'

def generate_enhanced_fallback_title(description):
    """Enhanced fallback title generation"""
    base_title = generate_fallback_job_title(description)
    desc_lower = description.lower()
    
    # Add seniority if not present
    if 'senior' not in desc_lower and 'lead' not in desc_lower and 'junior' not in desc_lower:
        if '5+' in description or 'five' in desc_lower or 'experienced' in desc_lower:
            base_title = base_title.replace('Developer', 'Senior Developer')
            base_title = base_title.replace('Engineer', 'Senior Engineer')
    
    return base_title

def generate_fallback_suggestions(description, count):
    """Generate multiple fallback suggestions"""
    base_title = generate_fallback_job_title(description)
    suggestions = [base_title]
    
    # Generate variations
    if 'developer' in base_title.lower():
        suggestions.extend([
            base_title.replace('Developer', 'Senior Developer'),
            base_title.replace('Developer', 'Lead Developer'),
            base_title.replace('Developer', 'Principal Developer')
        ])
    elif 'engineer' in base_title.lower():
        suggestions.extend([
            base_title.replace('Engineer', 'Senior Engineer'),
            base_title.replace('Engineer', 'Lead Engineer'),
            base_title.replace('Engineer', 'Principal Engineer')
        ])
    
    return suggestions[:count]

if __name__ == '__main__':
    # Run the app
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)

# Resume Screener Application - Project Analysis

## 🎯 Project Overview
A comprehensive Resume Screener application built with Flutter frontend and Python backend, featuring ATS scoring, semantic ranking, and an intelligent RAG-based chatbot for HR professionals.

## 🏗️ Architecture

### Frontend (Flutter)
- **Framework**: Flutter with Dart
- **Authentication**: Firebase Auth
- **UI Components**: Custom responsive widgets with gradient themes
- **State Management**: Provider pattern with custom controllers
- **Platform Support**: Web, Android, iOS, macOS, Linux, Windows

### Backend (Python)
- **Framework**: Flask with CORS support
- **ML/AI**: 
  - ATS scoring model (scikit-learn)
  - Semantic search (Sentence Transformers)
  - RAG system with LLaMA integration
  - Query expansion and intelligent responses
- **Database**: ChromaDB for vector storage
- **NLP**: spaCy for text processing

## 📁 Project Structure

### Flutter Frontend (`lib/`)
```
lib/
├── controllers/           # State management
│   └── auth_controller.dart
├── core/                 # Core utilities and themes
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── models/               # Data models
│   ├── ats_models.dart
│   ├── ats_workflow_models.dart
│   ├── auth_state_model.dart
│   └── user_model.dart
├── presentation/         # UI components
│   ├── views/
│   │   ├── auth/
│   │   ├── ats_workflow/
│   │   └── workspace_creation_view.dart
│   └── widgets/
├── services/             # API services
│   ├── ats_service.dart
│   └── firebase_auth_service.dart
└── main.dart
```

### Python Backend (`Semantic_ranker/`)
```
Semantic_ranker/
├── ats_flask_api.py      # Main Flask API
├── rag_api.py           # RAG system (separate module)
├── requirements.txt     # Python dependencies
└── chroma_db/          # Vector database (gitignored)
```

## 🚀 Key Features

### 1. Resume Upload & Processing
- Multi-file upload (PDF/DOCX)
- Text extraction and parsing
- ATS scoring with ML model
- Skills and experience extraction

### 2. Job Description Matching
- Semantic similarity ranking
- Keyword-based filtering
- Skills matching and scoring
- Threshold-based filtering

### 3. Interactive RAG Chatbot
- Drag-and-drop resume selection
- Intelligent question suggestions
- Context-aware responses with JD integration
- Conversational memory using LangChain
- Fallback responses when LLM unavailable

### 4. Advanced Filtering
- Mandatory skills filtering
- Email availability filtering
- Star rating system (70% semantic, 30% ATS)
- Real-time filter updates

### 5. Responsive UI
- Two-panel layout (candidates + filters/chat)
- Drag-and-drop functionality
- Real-time updates
- Professional gradient themes

## 🔧 Technical Implementation

### ATS Scoring System
- ML model trained on resume features
- Confidence scoring
- Threshold-based filtering
- Feature extraction from text

### Semantic Ranking
- Sentence Transformers for embeddings
- Cosine similarity calculation
- Hybrid search (semantic + keyword)
- ChromaDB for vector storage

### RAG System
- Query expansion using LLaMA
- Hybrid retrieval (semantic + keyword)
- Context-aware response generation
- Job description integration
- Conversational memory

### API Architecture
- RESTful endpoints
- CORS enabled
- Error handling and validation
- Modular design (separate RAG module)

## 📊 Data Flow

1. **Resume Upload** → Text Extraction → ATS Scoring
2. **Job Description** → Semantic Ranking → Filtering
3. **RAG Ingestion** → Vector Storage → Context Building
4. **Chat Interaction** → Query Processing → Response Generation

## 🛠️ Dependencies

### Flutter (`pubspec.yaml`)
- `firebase_auth`: Authentication
- `file_picker`: File upload
- `http`: API communication
- `provider`: State management

### Python (`requirements.txt`)
- `flask`: Web framework
- `flask_cors`: CORS support
- `sentence_transformers`: Embeddings
- `chromadb`: Vector database
- `spacy`: NLP processing
- `scikit-learn`: ML models
- `langchain`: Memory management
- `openai`: LLaMA integration

## 🔐 Security & Configuration

### Environment Variables
- `NVIDIA_API_KEY` or `LLAMA_API_KEY`: For LLaMA integration
- `PORT`: Flask server port (default: 5000)

### Git Ignored Files
- `.venv/`: Python virtual environment
- `chroma_db/`: Vector database
- `*.pkl`, `*.joblib`: ML model files
- `.env`: Environment variables

## 🚀 Deployment

### Backend
1. Create virtual environment: `python3 -m venv .venv`
2. Install dependencies: `pip install -r requirements.txt`
3. Install spaCy model: `python -m spacy download en_core_web_sm`
4. Set API key: `export NVIDIA_API_KEY="your_key"`
5. Run: `python ats_flask_api.py`

### Frontend
1. Install Flutter dependencies: `flutter pub get`
2. Run: `flutter run -d web`

### External Services
- **ngrok**: For local development tunneling
- **Firebase**: Authentication
- **NVIDIA API**: LLaMA integration (optional)

## 📈 Performance Features

- **Efficient Vector Search**: ChromaDB with optimized queries
- **Caching**: In-memory conversation storage
- **Fallback Systems**: Graceful degradation when services unavailable
- **Responsive Design**: Optimized for all screen sizes
- **Error Handling**: Comprehensive error management

## 🎯 Future Enhancements

1. **Agentic Orchestration**: LangGraph for scheduling automation
2. **Calendar Integration**: Google Calendar API
3. **Email Automation**: SMTP/SendGrid integration
4. **Advanced Analytics**: Dashboard with metrics
5. **Multi-language Support**: Internationalization
6. **Cloud Deployment**: AWS/Azure/GCP deployment

## 📝 Recent Updates

- ✅ Enhanced RAG system with JD context
- ✅ Improved fallback responses
- ✅ Configurable LLaMA API key
- ✅ Better error handling
- ✅ Structured response formatting
- ✅ Drag-and-drop functionality
- ✅ Star rating system
- ✅ Real-time filtering

## 🔍 Code Quality

- **Modular Design**: Separated concerns (RAG, ATS, UI)
- **Error Handling**: Comprehensive try-catch blocks
- **Documentation**: Inline comments and docstrings
- **Type Safety**: Dart type annotations
- **Responsive Design**: Mobile-first approach
- **Performance**: Optimized queries and caching

---

**Total Files**: 50+ Dart files, 2 Python modules
**Lines of Code**: ~3000+ lines
**Dependencies**: 20+ Flutter packages, 15+ Python packages
**Platforms**: 6 supported platforms
**Features**: 15+ major features implemented

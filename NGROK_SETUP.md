# Ngrok Setup for Resume Screener

## Current Configuration

The Resume Screener application is configured to use the following ngrok URL:
- **API Endpoint**: `https://1ac54b164b07.ngrok-free.app`

## Updated Files

The following files have been updated to use the new ngrok URL:

### Flutter App Configuration
1. **`lib/services/ats_service.dart`** - Updated AtsService baseUrl
2. **`lib/models/ats_models.dart`** - Updated AtsConfig baseUrl

### Backend Configuration
3. **`Semantic_ranker/config.py`** - Added NGROK_URL configuration

## How It Works

### Flutter App
The Flutter app uses the ngrok URL as the base URL for all API calls to the Flask backend. The configuration supports:

- **Environment Variable Override**: Set `ATS_BASE_URL` environment variable to override the default
- **Constructor Override**: Pass a custom baseUrl when creating AtsService instance
- **Default Fallback**: Uses the configured ngrok URL if no override is provided

### Backend API
The Flask API runs on port 5000 and is accessible through the ngrok tunnel. The API includes:

- Health check endpoint: `GET /health`
- Resume processing: `POST /process-resumes`
- Resume analysis: `POST /analyze-resume`
- Text extraction: `POST /extract-text`
- RAG endpoints for AI-powered features

## Testing the Setup

### 1. Start the Flask API
```bash
cd Semantic_ranker
python ats_flask_api.py
```

You should see:
```
🚀 Starting Enhanced ATS Flask API...
✅ LLaMA client initialized with API key
✅ Chroma DB initialized
✅ All models loaded successfully
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://[::1]:5000
```

### 2. Test the API Endpoint
```bash
curl https://1ac54b164b07.ngrok-free.app/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-XX XX:XX:XX",
  "version": "1.0.0"
}
```

### 3. Run the Flutter App
```bash
flutter run
```

The Flutter app will automatically connect to the ngrok URL for API calls.

## Updating the Ngrok URL

If you need to change the ngrok URL, update these files:

1. **`lib/services/ats_service.dart`** - Line 12: Update defaultValue
2. **`lib/models/ats_models.dart`** - Line 91: Update defaultValue  
3. **`Semantic_ranker/config.py`** - Line 15: Update NGROK_URL

## Environment Variable Override

You can override the ngrok URL using environment variables:

### For Flutter Development
```bash
# Windows
set ATS_BASE_URL=https://your-new-ngrok-url.ngrok-free.app
flutter run

# Linux/Mac
export ATS_BASE_URL=https://your-new-ngrok-url.ngrok-free.app
flutter run
```

### For Production Build
```bash
flutter build web --dart-define=ATS_BASE_URL=https://your-new-ngrok-url.ngrok-free.app
```

## Troubleshooting

### Common Issues

1. **Connection Refused**: Make sure the Flask API is running and ngrok is active
2. **CORS Errors**: The Flask API has CORS enabled for all origins
3. **API Key Issues**: Ensure the LLaMA API key is properly configured
4. **Ngrok Tunnel Down**: Restart ngrok and update the URL in the configuration files

### Health Check
Always test the health endpoint first:
```bash
curl https://1ac54b164b07.ngrok-free.app/health
```

## Security Notes

- The ngrok URL is publicly accessible
- Consider using ngrok authentication for production
- The Flask API has CORS enabled for development
- API keys are stored in configuration files (not recommended for production)


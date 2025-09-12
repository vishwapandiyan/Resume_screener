# API Key Setup for Resume Screener

## LLaMA API Key Configuration

The Resume Screener application requires a LLaMA API key to function properly. Here are the different ways to set it up:

### Method 1: Using the Configuration File (Recommended)
The API key is already configured in `Semantic_ranker/config.py`. The application will automatically use this key if no environment variable is set.

### Method 2: Environment Variables

#### For Windows (Command Prompt):
```cmd
set NVIDIA_API_KEY=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
set LLAMA_API_KEY=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
```

#### For Windows (PowerShell):
```powershell
$env:NVIDIA_API_KEY = "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"
$env:LLAMA_API_KEY = "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"
```

#### For Linux/Mac:
```bash
export NVIDIA_API_KEY="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"
export LLAMA_API_KEY="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"
```

### Method 3: Using the Provided Scripts

#### Windows Batch Script:
Run `set_api_key.bat` to set the environment variables for the current session.

#### PowerShell Script:
Run `set_api_key.ps1` to set the environment variables for the current PowerShell session.

### Verification

After setting up the API key, run the Flask API:
```bash
cd Semantic_ranker
python ats_flask_api.py
```

You should see:
```
✅ LLaMA client initialized with API key
```

If you see:
```
⚠️ No LLaMA API key found...
```

Then the API key is not properly configured. Check the configuration file or environment variables.

## Ngrok URL Configuration

The application is configured to use the ngrok URL: `https://1ac54b164b07.ngrok-free.app`

### Updated Files
- `lib/services/ats_service.dart` - Flutter service configuration
- `lib/models/ats_models.dart` - Flutter model configuration  
- `Semantic_ranker/config.py` - Backend configuration

### Testing the Setup
1. Start the Flask API: `cd Semantic_ranker && python ats_flask_api.py`
2. Test the endpoint: `curl https://1ac54b164b07.ngrok-free.app/health`
3. Run the Flutter app: `flutter run`

For detailed ngrok setup instructions, see `NGROK_SETUP.md`.

## Security Note

The API key is sensitive information. Make sure not to commit it to version control or share it publicly. The configuration file approach is convenient for development, but for production, use environment variables.

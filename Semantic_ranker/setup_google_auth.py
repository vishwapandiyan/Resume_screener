"""
Google API Authentication Setup Script
This script helps set up proper authentication for Google Calendar and Gmail APIs
"""

import os
import pickle
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials

SCOPES = [
    'https://www.googleapis.com/auth/calendar'
]

def setup_authentication():
    """Set up Google API authentication with proper scopes"""
    print("🔐 Setting up Google API Authentication")
    print("=" * 50)
    
    # Paths
    token_path = '../Google-Calender-Agent/token.pickle'
    credentials_path = '../Google-Calender-Agent/oauth2_credentials.json'
    
    # Check if credentials file exists
    if not os.path.exists(credentials_path):
        print(f"❌ Credentials file not found: {credentials_path}")
        print("Please ensure oauth2_credentials.json is in the Google-Calender-Agent folder")
        return False
    
    creds = None
    
    # Load existing token if available
    if os.path.exists(token_path):
        print("📁 Loading existing token...")
        with open(token_path, 'rb') as token_file:
            creds = pickle.load(token_file)
    
    # Check if credentials are valid and have required scopes
    if creds and creds.valid and creds.has_scopes(SCOPES):
        print("✅ Valid credentials found with required scopes!")
        return True
    
    # If credentials are expired, try to refresh
    if creds and creds.expired and creds.refresh_token:
        print("🔄 Refreshing expired credentials...")
        try:
            creds.refresh(Request())
            print("✅ Credentials refreshed successfully!")
        except Exception as e:
            print(f"❌ Failed to refresh credentials: {e}")
            creds = None
    
    # If no valid credentials, start OAuth flow
    if not creds or not creds.valid:
        print("🚀 Starting OAuth flow...")
        print("This will open a browser window for authentication.")
        print("Make sure to grant all requested permissions.")
        
        try:
            flow = InstalledAppFlow.from_client_secrets_file(
                credentials_path, SCOPES)
            creds = flow.run_local_server(port=0)
            print("✅ OAuth flow completed successfully!")
        except Exception as e:
            print(f"❌ OAuth flow failed: {e}")
            return False
    
    # Save credentials
    try:
        with open(token_path, 'wb') as token_file:
            pickle.dump(creds, token_file)
        print(f"💾 Credentials saved to {token_path}")
        
        # Verify scopes
        if creds.has_scopes(SCOPES):
            print("✅ All required scopes are present!")
            print("📅 Calendar API: Manage calendar events")
            print("📧 Email: Using SMTP (configured in .env file)")
            return True
        else:
            print("⚠️  Warning: Some required scopes may be missing")
            print("Required scopes:")
            for scope in SCOPES:
                print(f"  - {scope}")
            return False
            
    except Exception as e:
        print(f"❌ Failed to save credentials: {e}")
        return False

def test_authentication():
    """Test the authentication by trying to access the APIs"""
    print("\n🧪 Testing Authentication")
    print("=" * 30)
    
    try:
        from interview_agent import InterviewSchedulingAgent
        
        agent = InterviewSchedulingAgent()
        
        if agent.calendar_service:
            print("✅ Calendar service initialized successfully")
        else:
            print("❌ Calendar service initialization failed")
            
        if agent.calendar_service:
            print("🎉 Calendar service is ready!")
            print("📧 Email service: Using SMTP (check .env configuration)")
            return True
        else:
            print("⚠️  Calendar service failed to initialize")
            return False
            
    except Exception as e:
        print(f"❌ Authentication test failed: {e}")
        return False

def main():
    """Main function"""
    print("🚀 Google API Authentication Setup")
    print("=" * 50)
    print("This script will help you set up proper authentication")
    print("for Google Calendar and Gmail APIs.")
    print("=" * 50)
    
    # Step 1: Setup authentication
    if not setup_authentication():
        print("\n❌ Authentication setup failed!")
        print("Please check your credentials file and try again.")
        return False
    
    # Step 2: Test authentication
    if not test_authentication():
        print("\n❌ Authentication test failed!")
        print("Please run this script again to re-authenticate.")
        return False
    
    print("\n🎉 Setup completed successfully!")
    print("Your interview scheduling agent is now ready to use.")
    print("\n📝 Next steps:")
    print("1. Start your Flask server")
    print("2. Run your Flutter app")
    print("3. Try scheduling an interview!")
    
    return True

if __name__ == '__main__':
    success = main()
    exit(0 if success else 1)

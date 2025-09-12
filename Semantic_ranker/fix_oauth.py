"""
Fix OAuth Configuration for Google Calendar
This script will help you set up proper OAuth credentials
"""

import os
import json
from google_auth_oauthlib.flow import InstalledAppFlow

SCOPES = ['https://www.googleapis.com/auth/calendar']

def create_new_credentials():
    """Create new OAuth credentials with proper configuration"""
    print("🔧 Fixing OAuth Configuration for Google Calendar")
    print("=" * 60)
    
    # Check if credentials file exists
    credentials_path = '../Google-Calender-Agent/oauth2_credentials.json'
    
    if not os.path.exists(credentials_path):
        print("❌ OAuth credentials file not found!")
        print(f"Please ensure {credentials_path} exists")
        return False
    
    try:
        # Load existing credentials
        with open(credentials_path, 'r') as f:
            creds_data = json.load(f)
        
        print("📁 Found existing credentials file")
        print(f"Client ID: {creds_data.get('installed', {}).get('client_id', 'Not found')}")
        
        # Create flow with proper redirect URI
        flow = InstalledAppFlow.from_client_secrets_file(
            credentials_path, 
            SCOPES,
            redirect_uri='http://localhost:8080/callback'  # Use a different port
        )
        
        print("🚀 Starting OAuth flow...")
        print("This will open a browser window.")
        print("If you get a 403 error, try the following:")
        print("1. Make sure you're logged into the correct Google account")
        print("2. Check if the app is in testing mode and your email is added as a test user")
        print("3. Or try creating a new OAuth client in Google Cloud Console")
        
        # Run the flow
        creds = flow.run_local_server(port=8080)
        
        # Save credentials
        import pickle
        token_path = '../Google-Calender-Agent/token.pickle'
        with open(token_path, 'wb') as token_file:
            pickle.dump(creds, token_file)
        
        print(f"✅ Credentials saved to {token_path}")
        print("🎉 OAuth setup completed successfully!")
        
        return True
        
    except Exception as e:
        print(f"❌ OAuth setup failed: {e}")
        print("\n🔧 Troubleshooting steps:")
        print("1. Go to https://console.cloud.google.com/")
        print("2. Select your project")
        print("3. Go to APIs & Services > OAuth consent screen")
        print("4. Make sure the app is in 'Testing' mode")
        print("5. Add your email as a test user")
        print("6. Or publish the app for all users")
        return False

def test_calendar_access():
    """Test if we can access Google Calendar"""
    try:
        from googleapiclient.discovery import build
        import pickle
        
        token_path = '../Google-Calender-Agent/token.pickle'
        if not os.path.exists(token_path):
            print("❌ No token file found. Please run OAuth setup first.")
            return False
        
        with open(token_path, 'rb') as token_file:
            creds = pickle.load(token_file)
        
        service = build('calendar', 'v3', credentials=creds)
        
        # Test by listing calendars
        calendar_list = service.calendarList().list().execute()
        calendars = calendar_list.get('items', [])
        
        print(f"✅ Successfully connected to Google Calendar!")
        print(f"📅 Found {len(calendars)} calendars")
        
        for calendar in calendars[:3]:  # Show first 3 calendars
            print(f"  - {calendar.get('summary', 'No name')}")
        
        return True
        
    except Exception as e:
        print(f"❌ Calendar access test failed: {e}")
        return False

def main():
    """Main function"""
    print("🚀 Google Calendar OAuth Fix")
    print("=" * 40)
    
    # Step 1: Create new credentials
    if not create_new_credentials():
        return False
    
    # Step 2: Test calendar access
    print("\n🧪 Testing Calendar Access")
    print("-" * 30)
    if test_calendar_access():
        print("\n🎉 Everything is working! Your interview scheduling agent is ready.")
        return True
    else:
        print("\n❌ Calendar access test failed. Please check the troubleshooting steps above.")
        return False

if __name__ == '__main__':
    success = main()
    exit(0 if success else 1)

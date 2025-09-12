# final_server.py - Real Calendar Integration Server
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn
from datetime import datetime, timedelta
import re
import sys
import os

# Calendar integration code (copied from working calendar_service.py)
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google.auth.exceptions import RefreshError
import pickle
from googleapiclient.discovery import build
import pytz

SCOPES = ['https://www.googleapis.com/auth/calendar']

class CalendarService:
    def __init__(self):
        self.calendar_id = 'primary'
        self.service = self._authenticate()
    
    def _authenticate(self):
        creds = None
        token_path = 'Google-Calender-Agent/token.pickle'
        credentials_path = 'Google-Calender-Agent/oauth2_credentials.json'
        
        if os.path.exists(token_path):
            with open(token_path, 'rb') as token_file:
                creds = pickle.load(token_file)
        
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                try:
                    creds.refresh(Request())
                except RefreshError:
                    raise ValueError("❌ OAuth token refresh failed.")
                with open(token_path, 'wb') as token_file:
                    pickle.dump(creds, token_file)
            else:
                raise ValueError("❌ No valid authentication token found.")
        
        return build('calendar', 'v3', credentials=creds)
    
    def create_event(self, title, start_time, end_time, description=""):
        try:
            # Convert to UTC for Google Calendar (IST is UTC+5:30)
            # Subtract 5 hours 30 minutes to get UTC time
            utc_start = start_time - timedelta(hours=5, minutes=30)
            utc_end = end_time - timedelta(hours=5, minutes=30)
            
            event = {
                'summary': title,
                'description': description,
                'start': {
                    'dateTime': utc_start.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
                },
                'end': {
                    'dateTime': utc_end.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
                },
            }
            
            print("📅 Creating event:", event)
            
            event_result = self.service.events().insert(
                calendarId=self.calendar_id,
                body=event
            ).execute()
            
            print("✅ Event created successfully!")
            return event_result.get('id')
            
        except Exception as e:
            print(f"❌ Error creating event: {e}")
            return None
    
    def get_available_slots(self, date_str):
        try:
            target_date = datetime.strptime(date_str, "%Y-%m-%d")
            start_time = target_date.replace(hour=9, minute=0, second=0, microsecond=0)
            end_time = target_date.replace(hour=17, minute=0, second=0, microsecond=0)
            
            events_result = self.service.events().list(
                calendarId=self.calendar_id,
                timeMin=start_time.isoformat() + 'Z',
                timeMax=end_time.isoformat() + 'Z',
                singleEvents=True,
                orderBy='startTime'
            ).execute()
            
            events = events_result.get('items', [])
            available_slots = []
            current_time = start_time
            
            for event in events:
                event_start = datetime.fromisoformat(
                    event['start'].get('dateTime', event['start'].get('date')).replace('Z', '+00:00')
                ).replace(tzinfo=None)
                
                if current_time + timedelta(minutes=60) <= event_start:
                    available_slots.append({
                        'start': current_time.strftime("%H:%M"),
                        'end': (current_time + timedelta(minutes=60)).strftime("%H:%M")
                    })
                
                event_end = datetime.fromisoformat(
                    event['end'].get('dateTime', event['end'].get('date')).replace('Z', '+00:00')
                ).replace(tzinfo=None)
                current_time = max(current_time, event_end)
            
            while current_time + timedelta(minutes=60) <= end_time:
                available_slots.append({
                    'start': current_time.strftime("%H:%M"),
                    'end': (current_time + timedelta(minutes=60)).strftime("%H:%M")
                })
                current_time += timedelta(minutes=30)
            
            return available_slots[:5]
            
        except Exception as e:
            print(f"Error getting slots: {e}")
            return []

# Initialize FastAPI
app = FastAPI(title="TailorTalk Final API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatMessage(BaseModel):
    message: str

class ChatResponse(BaseModel):
    response: str
    booking_status: str = None
    event_details: dict = None

# Initialize calendar
calendar_service = None
try:
    calendar_service = CalendarService()
    print("✅ Calendar service initialized!")
except Exception as e:
    print(f"❌ Calendar failed: {e}")

def extract_time_from_message(message):
    """Extract time like '4 PM' from message"""
    time_patterns = [
        r'\b(\d{1,2})\s*PM\b',
        r'\b(\d{1,2})\s*AM\b',
        r'\b(\d{1,2}):(\d{2})\s*PM\b',
        r'\b(\d{1,2}):(\d{2})\s*AM\b'
    ]
    
    for pattern in time_patterns:
        match = re.search(pattern, message, re.IGNORECASE)
        if match:
            if "PM" in pattern.upper():
                hour = int(match.group(1))
                minute = int(match.group(2)) if len(match.groups()) > 1 else 0
                if hour != 12:
                    hour += 12
                return hour, minute
            else:  # AM
                hour = int(match.group(1))
                minute = int(match.group(2)) if len(match.groups()) > 1 else 0
                if hour == 12:
                    hour = 0
                return hour, minute
    
    return None, None

@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "service": "TailorTalk Final API",
        "calendar_ready": calendar_service is not None,
        "timestamp": datetime.now().isoformat()
    }

@app.post("/chat")
async def chat(message: ChatMessage):
    try:
        user_message = message.message
        print(f"📩 Message: {user_message}")
        
        # Check if it's a booking request
        if any(word in user_message.lower() for word in ["book", "schedule", "meeting"]):
            if not calendar_service:
                return {
                    "response": "❌ Calendar service not available. Please check setup.",
                    "booking_status": "error",
                    "event_details": None
                }
            
            # Extract time
            hour, minute = extract_time_from_message(user_message)
            
            if hour is None:
                return {
                    "response": "📅 I'd love to book a meeting! What time would you prefer? (e.g., '3 PM', '4:30 PM')",
                    "booking_status": "needs_time",
                    "event_details": None
                }
            
            # Create the meeting for tomorrow
            tomorrow = datetime.now() + timedelta(days=1)
            start_time = tomorrow.replace(hour=hour, minute=minute, second=0, microsecond=0)
            end_time = start_time + timedelta(hours=1)
            
            # Book the meeting
            event_id = calendar_service.create_event(
                title="Meeting via TailorTalk",
                start_time=start_time,
                end_time=end_time,
                description=f"Meeting scheduled via TailorTalk API\nOriginal request: {user_message}"
            )
            
            if event_id:
                return {
                    "response": f"✅ **Meeting Booked Successfully!**\n📅 Date: {start_time.strftime('%Y-%m-%d')}\n🕐 Time: {start_time.strftime('%I:%M %p')} - {end_time.strftime('%I:%M %p')}\n🆔 Event ID: {event_id}\n\n🔗 Check your Google Calendar!",
                    "booking_status": "confirmed",
                    "event_details": {
                        "date": start_time.strftime('%Y-%m-%d'),
                        "start_time": start_time.strftime('%I:%M %p'),
                        "end_time": end_time.strftime('%I:%M %p'),
                        "event_id": event_id,
                        "real_calendar_event": True
                    }
                }
            else:
                return {
                    "response": "❌ Failed to create calendar event. Please try again.",
                    "booking_status": "failed",
                    "event_details": None
                }
        
        # Check availability
        elif any(word in user_message.lower() for word in ["available", "free", "slots"]):
            if not calendar_service:
                return {
                    "response": "❌ Calendar service not available.",
                    "booking_status": "error", 
                    "event_details": None
                }
            
            tomorrow = (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")
            slots = calendar_service.get_available_slots(tomorrow)
            
            if slots:
                slot_text = "\n".join([f"• {slot['start']}-{slot['end']}" for slot in slots])
                return {
                    "response": f"🗓 **Available slots for {tomorrow}:**\n{slot_text}",
                    "booking_status": None,
                    "event_details": {
                        "date": tomorrow,
                        "available_slots": slots
                    }
                }
            else:
                return {
                    "response": f"📅 No available slots for {tomorrow}.",
                    "booking_status": None,
                    "event_details": {"date": tomorrow, "available_slots": []}
                }
        
        else:
            return {
                "response": f"👋 Hello! I can help you:\n• Book meetings: 'Book a meeting tomorrow at 4 PM'\n• Check availability: 'What slots are free tomorrow?'\n\nYou said: '{user_message}'",
                "booking_status": None,
                "event_details": None
            }
            
    except Exception as e:
        print(f"❌ Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    print("🚀 Starting TailorTalk Final Server on http://localhost:8005")
    uvicorn.run(app, host="127.0.0.1", port=8005, reload=False)

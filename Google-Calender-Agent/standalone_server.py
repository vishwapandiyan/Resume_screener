# standalone_server.py - FastAPI server with real calendar integration
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn
from datetime import datetime, timedelta
import sys
import os
import re

# Add path for imports
sys.path.append(os.path.join(os.path.dirname(__file__), 'Google-Calender-Agent'))

# Try to import calendar service
try:
    from app.calendar_service import GoogleCalendarService
    calendar_service = GoogleCalendarService()
    CALENDAR_AVAILABLE = True
    print("✅ Google Calendar service loaded successfully")
except Exception as e:
    print(f"⚠️ Calendar service not available: {e}")
    calendar_service = None
    CALENDAR_AVAILABLE = False

app = FastAPI(title="TailorTalk Standalone API", version="1.0.0")

# Enable CORS
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

@app.get("/health")
async def health_check():
    return {
        "status": "healthy", 
        "service": "TailorTalk Standalone",
        "timestamp": datetime.now().isoformat(),
        "port": 8002
    }

@app.get("/")
async def root():
    return {
        "message": "TailorTalk Standalone API is running!", 
        "timestamp": datetime.now().isoformat(),
        "endpoints": ["/health", "/chat"]
    }

@app.post("/chat")
async def chat(message: ChatMessage):
    user_message = message.message.lower()
    
    # Use real Google Calendar if available
    if CALENDAR_AVAILABLE and calendar_service:
        try:
            # Check for booking requests
            if any(word in user_message for word in ["book", "schedule", "appointment", "meeting"]):
                # Extract time from message using regex
                time_match = re.search(r'(\d{1,2})\s*(am|pm|:00)', user_message)
                date_match = re.search(r'(tomorrow|today|next week)', user_message)
                
                # Default values
                event_date = datetime.now() + timedelta(days=1)  # tomorrow
                event_time = "9:00 AM"  # default
                
                # Parse the actual time from user input
                if time_match:
                    hour = int(time_match.group(1))
                    period = time_match.group(2)
                    if period in ['pm'] and hour != 12:
                        hour += 12
                    elif period in ['am'] and hour == 12:
                        hour = 0
                    event_time = f"{hour:02d}:00"
                    if hour >= 12:
                        display_time = f"{hour if hour <= 12 else hour-12}:00 PM" if hour != 12 else "12:00 PM"
                    else:
                        display_time = f"{hour if hour != 0 else 12}:00 AM" if hour != 0 else "12:00 AM"
                else:
                    display_time = event_time
                
                # Create the event with datetime objects
                hour = int(event_time.split(':')[0])
                start_datetime = event_date.replace(hour=hour, minute=0, second=0, microsecond=0)
                end_datetime = start_datetime + timedelta(hours=1)  # 1 hour meeting
                
                result = calendar_service.create_event(
                    title='Meeting',
                    start_time=start_datetime,
                    end_time=end_datetime,
                    description=f'Meeting booked via TailorTalk: {message.message}'
                )
                
                return {
                    "response": f"✅ Meeting successfully booked for {event_date.strftime('%Y-%m-%d')} at {display_time}!",
                    "booking_status": "confirmed",
                    "event_details": {
                        "date": event_date.strftime('%Y-%m-%d'),
                        "time": display_time,
                        "event_id": result,  # result is already the event ID string
                        "note": "Real calendar event created!"
                    }
                }
            
            # Check for availability requests
            elif any(word in user_message for word in ["available", "slots", "free"]):
                # Get tomorrow's available slots using the calendar service
                tomorrow = datetime.now() + timedelta(days=1)
                date_str = tomorrow.strftime('%Y-%m-%d')
                
                available_slots = calendar_service.get_available_slots(date_str, duration_minutes=60)
                
                # Format slots for display
                slot_times = []
                for slot in available_slots:
                    start_time = slot['start']
                    # Convert 24h to 12h format
                    hour, minute = map(int, start_time.split(':'))
                    if hour == 0:
                        formatted_time = f"12:{minute:02d} AM"
                    elif hour < 12:
                        formatted_time = f"{hour}:{minute:02d} AM"
                    elif hour == 12:
                        formatted_time = f"12:{minute:02d} PM"
                    else:
                        formatted_time = f"{hour-12}:{minute:02d} PM"
                    slot_times.append(formatted_time)
                
                return {
                    "response": f"🗓 Available slots for {date_str}: {', '.join(slot_times) if slot_times else 'No available slots'}",
                    "booking_status": None,
                    "event_details": {
                        "date": date_str,
                        "slots": slot_times,
                        "note": "Real calendar availability checked!"
                    }
                }
                
        except Exception as e:
            return {
                "response": f"❌ Error with calendar service: {str(e)}. Using fallback response.",
                "booking_status": "error",
                "event_details": None
            }
    
    # Fallback responses if calendar not available
    if any(word in user_message for word in ["book", "schedule", "appointment", "meeting"]):
        return {
            "response": f"✅ Booking request received: '{message.message}'. Calendar service not available - this is a test response.",
            "booking_status": "test_confirmed",
            "event_details": {
                "date": (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d"),
                "time": "3:00 PM",
                "note": "This is a test response - calendar integration not available"
            }
        }
    
    elif any(word in user_message for word in ["available", "slots", "free"]):
        return {
            "response": f"🗓 Test available slots: 9:00 AM, 2:00 PM, 4:00 PM tomorrow",
            "booking_status": None,
            "event_details": {
                "date": (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d"),
                "slots": ["9:00-10:00", "14:00-15:00", "16:00-17:00"],
                "note": "This is a test response - calendar integration not available"
            }
        }
    
    else:
        return {
            "response": f"👋 Hello! I received your message: '{message.message}'. Try asking to 'book a meeting' or check 'available slots'!",
            "booking_status": None,
            "event_details": None
        }

if __name__ == "__main__":
    print("🚀 Starting TailorTalk Standalone Server on http://localhost:8002")
    uvicorn.run(app, host="127.0.0.1", port=8002, reload=False)

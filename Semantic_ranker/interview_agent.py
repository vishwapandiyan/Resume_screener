"""
Interview Scheduling Agent
Integrates with Google Calendar and Gmail API for automated interview scheduling
"""

import os
import re
import json
import pickle
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google.auth.exceptions import RefreshError
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
import pytz
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

SCOPES = [
    'https://www.googleapis.com/auth/calendar',
    'https://www.googleapis.com/auth/gmail.send'
]

class InterviewSchedulingAgent:
    def __init__(self):
        self.calendar_service = None
        self.smtp_config = {
            'server': os.getenv('SMTP_SERVER', 'smtp.gmail.com'),
            'port': int(os.getenv('SMTP_PORT', '587')),
            'username': os.getenv('EMAIL_USER'),
            'password': os.getenv('EMAIL_PASSWORD')
        }
        self.calendar_id = 'primary'
        self._initialize_services()
    
    def _initialize_services(self):
        """Initialize Google Calendar service and SMTP configuration"""
        # Try to initialize Calendar Service (optional)
        try:
            self.calendar_service = self._authenticate_calendar()
            print("✅ Google Calendar service initialized")
        except Exception as e:
            print(f"⚠️ Calendar service initialization failed: {e}")
            print("📅 Calendar features will be disabled, but email scheduling will work")
            self.calendar_service = None
        
        # Check SMTP configuration
        if self.smtp_config['username'] and self.smtp_config['password']:
            print("✅ SMTP configuration loaded")
        else:
            print("⚠️ SMTP configuration incomplete - email sending will be disabled")
    
    def _authenticate_calendar(self):
        """Authenticate with Google Calendar API"""
        creds = None
        token_path = '../Google-Calender-Agent/token.pickle'
        credentials_path = '../Google-Calender-Agent/oauth2_credentials.json'
        
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
        
        # Check if credentials have required scopes (only calendar scope needed)
        calendar_scope = 'https://www.googleapis.com/auth/calendar'
        if not creds.has_scopes([calendar_scope]):
            raise ValueError("❌ Credentials don't have required calendar scope. Please re-authenticate.")
        
        return build('calendar', 'v3', credentials=creds)
    
    
    def detect_interview_intent(self, message: str) -> bool:
        """Detect if the message contains interview scheduling intent"""
        interview_keywords = [
            'interview', 'schedule interview', 'call for interview', 'interview call',
            'book interview', 'arrange interview', 'set up interview', 'meet candidate',
            'interview candidate', 'call candidate', 'invite for interview',
            'interview scheduling', 'interview appointment', 'interview meeting',
            'technical interview', 'hr interview', 'final interview', 'phone interview',
            'video interview', 'onsite interview', 'interview process'
        ]
        
        message_lower = message.lower()
        return any(keyword in message_lower for keyword in interview_keywords)
    
    def get_available_slots(self, date_str: str = None) -> List[Dict]:
        """Get available time slots for interview scheduling"""
        if not self.calendar_service:
            return []
        
        try:
            if not date_str:
                # Default to tomorrow
                target_date = datetime.now() + timedelta(days=1)
            else:
                target_date = datetime.strptime(date_str, "%Y-%m-%d")
            
            start_time = target_date.replace(hour=9, minute=0, second=0, microsecond=0)
            end_time = target_date.replace(hour=17, minute=0, second=0, microsecond=0)
            
            events_result = self.calendar_service.events().list(
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
                        'start': current_time,
                        'end': current_time + timedelta(minutes=60),
                        'start_str': current_time.strftime("%H:%M"),
                        'end_str': (current_time + timedelta(minutes=60)).strftime("%H:%M"),
                        'date': target_date.strftime("%Y-%m-%d")
                    })
                
                event_end = datetime.fromisoformat(
                    event['end'].get('dateTime', event['end'].get('date')).replace('Z', '+00:00')
                ).replace(tzinfo=None)
                current_time = max(current_time, event_end)
            
            # Add remaining slots
            while current_time + timedelta(minutes=60) <= end_time:
                available_slots.append({
                    'start': current_time,
                    'end': current_time + timedelta(minutes=60),
                    'start_str': current_time.strftime("%H:%M"),
                    'end_str': (current_time + timedelta(minutes=60)).strftime("%H:%M"),
                    'date': target_date.strftime("%Y-%m-%d")
                })
                current_time += timedelta(minutes=30)
            
            return available_slots[:5]  # Return first 5 available slots
            
        except Exception as e:
            print(f"Error getting available slots: {e}")
            return []
    
    def book_interview_slot(self, slot: Dict, candidate_info: Dict, job_info: Dict) -> Dict:
        """Book an interview slot in Google Calendar"""
        if not self.calendar_service:
            return {"success": False, "error": "Calendar service not available"}
        
        try:
            # Create event details
            candidate_name = candidate_info.get('candidate', 'Candidate')
            position = job_info.get('job_title', 'Software Developer')
            company = job_info.get('company', 'Our Company')
            
            event_title = f"Interview: {candidate_name} - {position}"
            event_description = f"""
Interview Details:
• Candidate: {candidate_name}
• Position: {position}
• Company: {company}
• Email: {candidate_info.get('email', 'N/A')}
• Skills: {candidate_info.get('skills', 'N/A')}

This interview was automatically scheduled via our AI-powered recruitment system.
            """.strip()
            
            # Convert to UTC for Google Calendar
            utc_start = slot['start'] - timedelta(hours=5, minutes=30)
            utc_end = slot['end'] - timedelta(hours=5, minutes=30)
            
            event = {
                'summary': event_title,
                'description': event_description,
                'start': {
                    'dateTime': utc_start.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
                },
                'end': {
                    'dateTime': utc_end.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
                },
                'attendees': [
                    {'email': candidate_info.get('email', '')}
                ],
                'reminders': {
                    'useDefault': False,
                    'overrides': [
                        {'method': 'email', 'minutes': 24 * 60},  # 1 day before
                        {'method': 'popup', 'minutes': 30},       # 30 minutes before
                    ],
                },
            }
            
            event_result = self.calendar_service.events().insert(
                calendarId=self.calendar_id,
                body=event
            ).execute()
            
            return {
                "success": True,
                "event_id": event_result.get('id'),
                "event_title": event_title,
                "start_time": slot['start'].strftime('%Y-%m-%d %H:%M'),
                "end_time": slot['end'].strftime('%Y-%m-%d %H:%M'),
                "meeting_link": event_result.get('hangoutLink', ''),
                "calendar_link": event_result.get('htmlLink', '')
            }
            
        except Exception as e:
            print(f"Error booking interview slot: {e}")
            return {"success": False, "error": str(e)}
    
    def generate_interview_email(self, candidate_info: Dict, job_info: Dict, interview_details: Dict) -> Dict:
        """Generate professional interview invitation email"""
        candidate_name = candidate_info.get('candidate', 'Candidate')
        candidate_email = candidate_info.get('email', '')
        position = job_info.get('job_title', 'Software Developer')
        company = job_info.get('company', 'Our Company')
        
        # Format interview time
        start_time = datetime.strptime(interview_details['start_time'], '%Y-%m-%d %H:%M')
        formatted_date = start_time.strftime('%A, %B %d, %Y')
        formatted_time = start_time.strftime('%I:%M %p')
        
        subject = f"Interview Invitation - {position} at {company}"
        
        # Use the exact email format specified
        email_body = f"""
Dear {candidate_name},

We are excited to invite you for an interview!

📅 Interview Details:
• Date: {formatted_date}
• Time: {formatted_time}
• Duration: 1 hour
• Type: Interview Discussion

"""
        
        # Add calendar link if available
        calendar_link = interview_details.get('calendar_link', '')
        if calendar_link:
            email_body += f"🔗 Calendar Event: {calendar_link}\n\n"
        
        email_body += f"""
📋 Meeting Confirmation:
Please confirm your attendance.

📝 What to Prepare:
• Updated resume and portfolio
• Questions about the role and company
• Examples of your previous work

If you need to reschedule, please contact us at least 24 hours in advance.

Looking forward to our conversation!

Best regards,
HR Team
        """.strip()
        
        return {
            "to": candidate_email,
            "subject": subject,
            "body": email_body,
            "candidate_name": candidate_name,
            "interview_date": formatted_date,
            "interview_time": formatted_time
        }
    
    def send_email(self, email_data: Dict) -> Dict:
        """Send email using SMTP"""
        if not self.smtp_config['username'] or not self.smtp_config['password']:
            return {"success": False, "error": "SMTP configuration not available", "manual_required": True}
        
        try:
            # Create message
            msg = MIMEMultipart()
            msg['From'] = self.smtp_config['username']
            msg['To'] = email_data['to']
            msg['Subject'] = email_data['subject']
            
            # Add body
            msg.attach(MIMEText(email_data['body'], 'html'))
            
            # Connect to server and send email
            server = smtplib.SMTP(self.smtp_config['server'], self.smtp_config['port'])
            server.starttls()  # Enable TLS encryption
            server.login(self.smtp_config['username'], self.smtp_config['password'])
            
            text = msg.as_string()
            server.sendmail(self.smtp_config['username'], email_data['to'], text)
            server.quit()
            
            return {
                "success": True,
                "message": "Email sent successfully via SMTP"
            }
            
        except smtplib.SMTPAuthenticationError as e:
            print(f"SMTP Authentication error: {e}")
            return {
                "success": False, 
                "error": "SMTP authentication failed. Please check your email credentials.", 
                "manual_required": True
            }
        except smtplib.SMTPRecipientsRefused as e:
            print(f"SMTP Recipients refused: {e}")
            return {
                "success": False, 
                "error": "Invalid recipient email address.", 
                "manual_required": True
            }
        except smtplib.SMTPException as e:
            print(f"SMTP error: {e}")
            return {
                "success": False, 
                "error": f"SMTP error: {str(e)}", 
                "manual_required": True
            }
        except Exception as e:
            print(f"Email sending error: {e}")
            return {
                "success": False, 
                "error": f"Email sending failed: {str(e)}", 
                "manual_required": True
            }
    
    
    def process_interview_request(self, message: str, candidate_info: Dict, job_info: Dict) -> Dict:
        """Main method to process interview scheduling request"""
        stages = []
        
        try:
            # Stage 1: Agent Thinking
            stages.append({
                "stage": "thinking",
                "message": "🤔 Analyzing your request and preparing interview scheduling...",
                "status": "in_progress"
            })
            
            # Stage 2: Checking Schedule
            stages.append({
                "stage": "checking_schedule",
                "message": "📅 Checking your calendar for available slots...",
                "status": "in_progress"
            })
            
            available_slots = self.get_available_slots()
            if not available_slots:
                return {
                    "success": False,
                    "error": "No available slots found for the next few days",
                    "stages": stages
                }
            
            # Update stage 2 as completed
            stages[-1]["status"] = "completed"
            stages[-1]["message"] = f"✅ Found {len(available_slots)} available slots"
            
            # Stage 3: Booking Interview
            stages.append({
                "stage": "booking_interview",
                "message": "📝 Booking the first available interview slot...",
                "status": "in_progress"
            })
            
            # Book first available slot
            booking_result = self.book_interview_slot(available_slots[0], candidate_info, job_info)
            if not booking_result["success"]:
                return {
                    "success": False,
                    "error": booking_result["error"],
                    "stages": stages
                }
            
            # Update stage 3 as completed
            stages[-1]["status"] = "completed"
            stages[-1]["message"] = f"✅ Interview booked for {booking_result['start_time']}"
            
            # Stage 4: Generating Email
            stages.append({
                "stage": "generating_email",
                "message": "✍️ Generating professional interview invitation email...",
                "status": "in_progress"
            })
            
            email_data = self.generate_interview_email(candidate_info, job_info, booking_result)
            
            # Update stage 4 as completed
            stages[-1]["status"] = "completed"
            stages[-1]["message"] = "✅ Professional email generated"
            
            # Stage 5: Sending Email
            stages.append({
                "stage": "sending_email",
                "message": f"📧 Sending email to {candidate_info.get('email', 'candidate')}...",
                "status": "in_progress"
            })
            
            email_result = self.send_email(email_data)
            
            if email_result["success"]:
                stages[-1]["status"] = "completed"
                stages[-1]["message"] = "✅ Email sent successfully!"
            else:
                stages[-1]["status"] = "failed"
                stages[-1]["message"] = f"❌ Email sending failed: {email_result['error']}"
            
            return {
                "success": True,
                "booking_result": booking_result,
                "email_data": email_data,
                "email_result": email_result,
                "stages": stages,
                "manual_email_option": not email_result["success"]
            }
            
        except Exception as e:
            print(f"Error in interview processing: {e}")
            return {
                "success": False,
                "error": str(e),
                "stages": stages
            }
    
    def get_manual_email_data(self, candidate_info: Dict, job_info: Dict, interview_details: Dict) -> Dict:
        """Get email data for manual sending"""
        return self.generate_interview_email(candidate_info, job_info, interview_details)

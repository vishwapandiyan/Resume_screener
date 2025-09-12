import requests
import json

def test_api():
    try:
        # Test health endpoint
        print("Testing health endpoint...")
        response = requests.get("http://localhost:8001/health", timeout=5)
        print(f"Health Status: {response.status_code}")
        print(f"Health Response: {response.json()}")
        
        # Test chat endpoint
        print("\nTesting chat endpoint...")
        chat_data = {"message": "Book a meeting tomorrow at 3 PM"}
        response = requests.post("http://localhost:8001/chat", json=chat_data, timeout=5)
        print(f"Chat Status: {response.status_code}")
        print(f"Chat Response: {json.dumps(response.json(), indent=2)}")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_api()


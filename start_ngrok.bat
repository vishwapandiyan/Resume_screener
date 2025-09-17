@echo off
echo Starting ngrok tunnel for Flask API...
echo.
echo Make sure your Flask API is running on port 5000 first!
echo Run: cd Semantic_ranker && python ats_flask_api.py
echo.
echo Starting ngrok...
ngrok http 5000
echo.
echo Copy the HTTPS URL from above and update your Flutter app configuration.
pause


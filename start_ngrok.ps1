# PowerShell script to start ngrok tunnel
Write-Host "Starting ngrok tunnel for Flask API..." -ForegroundColor Green
Write-Host ""
Write-Host "Make sure your Flask API is running on port 5000 first!" -ForegroundColor Yellow
Write-Host "Run: cd Semantic_ranker && python ats_flask_api.py" -ForegroundColor Cyan
Write-Host ""
Write-Host "Starting ngrok..." -ForegroundColor Green

# Start ngrok
ngrok http 5000

Write-Host ""
Write-Host "Copy the HTTPS URL from above and update your Flutter app configuration." -ForegroundColor Yellow


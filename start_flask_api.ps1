# PowerShell script to start Flask API
Write-Host "Starting Flask API..." -ForegroundColor Green

# Change to Semantic_ranker directory
Set-Location -Path "Semantic_ranker"

# Start Flask API
Write-Host "Running: python ats_flask_api.py" -ForegroundColor Cyan
python ats_flask_api.py


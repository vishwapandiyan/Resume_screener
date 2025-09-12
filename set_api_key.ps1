# PowerShell script to set LLaMA API Key environment variable
Write-Host "Setting LLaMA API Key environment variable..." -ForegroundColor Green

# Set for current session
$env:NVIDIA_API_KEY = "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"
$env:LLAMA_API_KEY = "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"

Write-Host "API keys set for this PowerShell session." -ForegroundColor Yellow
Write-Host ""
Write-Host "To make this permanent, run as Administrator and use:" -ForegroundColor Cyan
Write-Host '[Environment]::SetEnvironmentVariable("NVIDIA_API_KEY", "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", "User")' -ForegroundColor White
Write-Host '[Environment]::SetEnvironmentVariable("LLAMA_API_KEY", "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", "User")' -ForegroundColor White
Write-Host ""
Write-Host "Now you can run the Flask API." -ForegroundColor Green


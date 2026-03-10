# Run ML server from project root (required for model path)
Set-Location $PSScriptRoot
if (-not (Test-Path "assets\model\best.pt")) { Write-Warning "Model not found: assets\model\best.pt" }
python -m pip install -r ml_server/requirements.txt -q 2>$null
python ml_server/server.py

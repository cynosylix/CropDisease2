@echo off
cd /d "%~dp0"
echo Starting ML server (best.pt)...
echo Wait for "[server] Model loaded: ..." then use the app.
echo.
uvicorn server:app --host 0.0.0.0 --port 8000
pause

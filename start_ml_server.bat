@echo off
cd /d "%~dp0"
echo Starting ML server for Crop Disease app...
echo.
start "ML Server" cmd /k "cd /d ml_server && uvicorn server:app --host 0.0.0.0 --port 8000"
echo.
echo Server is starting in a new window. Wait for "[server] Model loaded: ..." then run the app.
timeout /t 3 >nul

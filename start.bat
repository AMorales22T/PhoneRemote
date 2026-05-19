@echo off
title PhoneRemote Server
echo ==========================================
echo    PhoneRemote - PC Remote Control
echo ==========================================
echo.

:: Check for admin rights (needed for firewall rules)
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin privileges for firewall...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo Installing dependencies...
cd /d "%~dp0desktop"
pip install -r requirements.txt
echo.
echo Starting PhoneRemote...
python main.py
pause

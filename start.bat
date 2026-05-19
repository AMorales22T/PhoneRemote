@echo off
title PhoneRemote Server
echo ==========================================
echo    PhoneRemote - PC Remote Control
echo ==========================================
echo.
echo Installing dependencies...
cd desktop
pip install -r requirements.txt
echo.
echo Starting PhoneRemote...
python main.py
pause

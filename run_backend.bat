@echo off
title Kruti Dev AI - Backend Server
cd /d D:\krutidev-ai-typing\backend

echo ========================================
echo  Kruti Dev AI Typing - Backend Server
echo  Languages: Hindi (hi) + Marathi (mr)
echo ========================================

:: Redirect Go cache to D: drive (avoids C: space issues)
set GOCACHE=D:\gocache\build
set GOTMPDIR=D:\gocache\tmp

:: Ensure Python UTF-8 encoding for Whisper
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8

:: Create dirs if missing
if not exist uploads mkdir uploads
if not exist documents mkdir documents
if not exist D:\gocache\tmp mkdir D:\gocache\tmp

echo Checking dependencies...

:: Check whisper
whisper --version >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Whisper not found. Install with: pip install openai-whisper
)

:: Check ffmpeg
ffmpeg -version >nul 2>&1
if errorlevel 1 (
    echo [WARNING] FFmpeg not found in PATH. Please restart after install.
)

echo.
echo Starting backend on http://localhost:8080
echo Supported languages: Hindi (hi), Marathi (mr)
echo Press Ctrl+C to stop
echo.

:: Run the pre-built exe if it exists, else go run
if exist krutidev.exe (
    krutidev.exe
) else (
    go run main.go
)
pause

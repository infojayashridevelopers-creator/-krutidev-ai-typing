@echo off
title Kruti Dev AI - Build All
echo ========================================
echo  Kruti Dev AI Typing - Full Build
echo ========================================

:: Build Backend
echo [1/2] Building Go Backend...
cd /d D:\krutidev-ai-typing\backend
go mod tidy
go build -o krutidev-backend.exe main.go
if errorlevel 1 (
    echo Backend build FAILED!
    pause
    exit /b 1
)
echo Backend built successfully: backend\krutidev-backend.exe

:: Build Flutter
echo.
echo [2/2] Building Flutter Windows App...
cd /d D:\krutidev-ai-typing\frontend
flutter pub get
flutter build windows --release
if errorlevel 1 (
    echo Flutter build FAILED!
    pause
    exit /b 1
)
echo Flutter app built successfully: frontend\build\windows\runner\Release\

echo.
echo ========================================
echo  BUILD COMPLETE!
echo ========================================
echo Backend exe: D:\krutidev-ai-typing\backend\krutidev-backend.exe
echo Flutter app: D:\krutidev-ai-typing\frontend\build\windows\runner\Release\
echo.
pause

@echo off
title Kruti Dev AI - Flutter App
cd /d D:\krutidev-ai-typing\frontend

echo ========================================
echo  Kruti Dev AI Typing - Flutter App
echo ========================================

echo Getting packages...
flutter pub get

echo.
echo Starting Flutter Windows app...
flutter run -d windows
pause

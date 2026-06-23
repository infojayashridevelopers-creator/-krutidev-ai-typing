@echo off
echo Creating desktop shortcuts for Kruti Dev AI Typing...

set DESKTOP=%USERPROFILE%\Desktop
set APP_DIR=D:\krutidev-ai-typing

:: Shortcut for Backend
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%DESKTOP%\Kruti Dev - Backend.lnk'); $s.TargetPath = '%APP_DIR%\run_backend.bat'; $s.WorkingDirectory = '%APP_DIR%\backend'; $s.IconLocation = 'C:\Windows\System32\cmd.exe,0'; $s.Description = 'Start Kruti Dev AI Backend Server'; $s.Save()"

:: Shortcut for Flutter Windows App
set FLUTTER_EXE=%APP_DIR%\frontend\build\windows\x64\runner\Release\krutidev_ai_typing.exe
if exist "%FLUTTER_EXE%" (
    powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%DESKTOP%\Kruti Dev AI Typing.lnk'); $s.TargetPath = '%FLUTTER_EXE%'; $s.WorkingDirectory = '%APP_DIR%\frontend\build\windows\x64\runner\Release'; $s.Description = 'Kruti Dev AI Voice Typing Agent'; $s.Save()"
    echo Flutter app shortcut created.
) else (
    echo Flutter app not built yet. Run build_all.bat first.
)

echo.
echo Shortcuts created on Desktop:
echo   - Kruti Dev - Backend.lnk
echo   - Kruti Dev AI Typing.lnk
echo.
pause

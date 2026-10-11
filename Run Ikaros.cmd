@echo off
setlocal
cd /d "%~dp0"
if errorlevel 1 (
    echo Ikaros could not open its application folder.
    pause
    exit /b 1
)
if not exist "%~dp0bin\Ikaros.exe" (
    echo Ikaros is missing bin\Ikaros.exe.
    echo Keep the complete application folder together.
    echo See USER-GUIDE.html or README.md for setup instructions.
    pause
    exit /b 1
)
if not exist "%~dp0scenarios\Pioneer-11-Saturn.txt" (
    echo Ikaros is missing its scenarios folder.
    echo Keep scenarios beside bin and this launcher.
    pause
    exit /b 1
)
start "" "%~dp0bin\Ikaros.exe"
exit /b 0

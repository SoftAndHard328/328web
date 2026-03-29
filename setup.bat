@echo off
chcp 65001 >nul
title AI Monitor Setup
color 0A

echo ==========================================
echo    AI Monitor Environment Setup
echo ==========================================
echo.

echo [Check] Checking system environment...
echo.

:: Check Windows version
ver | findstr /i "10\." >nul
if %errorlevel% neq 0 (
    ver | findstr /i "11\." >nul
    if %errorlevel% neq 0 (
        echo [Error] Windows 10 or 11 required
        pause
        exit /b 1
    )
)
echo [OK] Windows version check passed

:: Check Python 3.13
python --version 2>nul | findstr "3.13" >nul
if %errorlevel% equ 0 (
    echo [OK] Python 3.13 found
    goto CHECK_PIP
)

:: Check py launcher
py --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [Check] Python Launcher found, checking versions...
    py --list | findstr "3.13" >nul
    if %errorlevel% equ 0 (
        echo [OK] Python 3.13 available via py launcher
        goto CHECK_PIP
    )
)

echo.
echo [Info] Python 3.13 not found
echo.
echo Option 1: Auto-install (winget)
echo Option 2: Manual install
echo.
set /p choice="Select (1/2): "

if "%choice%"=="1" goto AUTO_INSTALL
if "%choice%"=="2" goto MANUAL_INSTALL
goto END

:AUTO_INSTALL
echo.
echo [Install] Installing Python 3.13 via winget...
echo [Install] This may take a few minutes...
echo.

winget install Python.Python.3.13 --source winget --accept-package-agreements --accept-source-agreements

if %errorlevel% neq 0 (
    echo.
    echo [Error] Auto-install failed, please try manual
    pause
    goto MANUAL_INSTALL
)

echo.
echo [OK] Python 3.13 installed!
echo [Info] Please restart command prompt to use new Python
echo.
pause
goto CHECK_PIP

:MANUAL_INSTALL
echo.
echo [Info] Opening Python download page...
echo [Info] Download Windows installer (64-bit)
echo.
start https://www.python.org/downloads/release/python-3130/
echo [Info] Make sure to check "Add Python to PATH"
echo.
pause
goto END

:CHECK_PIP
echo.
echo [Check] Checking pip...

py -3.13 -m pip --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] pip ready
    goto INSTALL_DEPS
)

python -m pip --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] pip ready
    goto INSTALL_DEPS
)

echo [Error] pip not found, please reinstall Python with pip
pause
goto END

:INSTALL_DEPS
echo.
echo ==========================================
echo    Installing Dependencies
echo ==========================================
echo.

echo [Prepare] Creating requirements.txt...
(
echo opencv-python>=4.8.0
echo numpy>=1.24.0
echo ultralytics>=8.0.0
echo PyQt5>=5.15.0
echo psutil>=5.9.0
echo pygetwindow
echo pyrect
echo pillow
echo requests
) > requirements.txt

echo [Install] Installing packages...
echo [Info] This may take 5-10 minutes...
echo.

py -3.13 -m pip install --upgrade pip
py -3.13 -m pip install -r requirements.txt

if %errorlevel% neq 0 (
    echo.
    echo [Retry] Trying with python command...
    python -m pip install --upgrade pip
    python -m pip install -r requirements.txt
)

del requirements.txt 2>nul

echo.
echo ==========================================
echo    Setup Complete!
echo ==========================================
echo.
echo [OK] All dependencies installed
echo.
echo You can now run DroidCamAIMonitor.exe
echo.
echo For Discord notifications:
echo   - Visit https://328web.vercel.app/ for Discord auth
echo   - Enter your Discord user ID in the app
echo.

:END
pause

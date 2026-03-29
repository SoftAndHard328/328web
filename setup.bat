@echo off
chcp 65001 >nul
title 緣氏監控系統 - 環境配置工具
color 0A

echo ==========================================
echo    緣氏監控系統 - 環境配置工具
echo ==========================================
echo.

:: 檢查是否以管理員身分執行
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [警告] 建議以系統管理員身分執行此腳本
    echo [警告] 某些功能可能需要管理員權限
    echo.
    pause
)

echo [檢查] 正在檢查系統環境...
echo.

:: 檢查 Windows 版本
ver | findstr /i "10\." >nul
if %errorlevel% neq 0 (
    ver | findstr /i "11\." >nul
    if %errorlevel% neq 0 (
        echo [錯誤] 本程式需要 Windows 10 或 Windows 11
        pause
        exit /b 1
    )
)
echo [OK] Windows 版本檢查通過

:: 檢查是否已安裝 Python 3.13
python --version 2>nul | findstr "3.13" >nul
if %errorlevel% equ 0 (
    echo [OK] Python 3.13 已安裝
    goto CHECK_PIP
)

:: 檢查 py launcher
py --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [檢查] 發現 Python Launcher，檢查可用版本...
    py --list | findstr "3.13" >nul
    if %errorlevel% equ 0 (
        echo [OK] Python 3.13 已透過 py launcher 安裝
        goto CHECK_PIP
    )
)

echo.
echo [提示] 需要安裝 Python 3.13
echo.
echo 選項 1: 自動安裝 (推薦) - 使用 winget 自動下載並安裝
echo 選項 2: 手動安裝 - 開啟瀏覽器下載安裝程式
echo.
set /p choice="請選擇安裝方式 (1/2): "

if "%choice%"=="1" goto AUTO_INSTALL
if "%choice%"=="2" goto MANUAL_INSTALL
goto END

:AUTO_INSTALL
echo.
echo [安裝] 正在使用 winget 安裝 Python 3.13...
echo [安裝] 這可能需要幾分鐘時間，請稍候...
echo.

winget install Python.Python.3.13 --source winget --accept-package-agreements --accept-source-agreements

if %errorlevel% neq 0 (
    echo.
    echo [錯誤] 自動安裝失敗，請嘗試手動安裝
    pause
    goto MANUAL_INSTALL
)

echo.
echo [OK] Python 3.13 安裝完成！
echo [提示] 請重新開啟命令提示字元以使用新版本的 Python
echo.
pause
goto CHECK_PIP

:MANUAL_INSTALL
echo.
echo [提示] 即將開啟 Python 官方下載頁面...
echo [提示] 請下載 Windows installer (64-bit)
echo.
start https://www.python.org/downloads/release/python-3130/
echo [提示] 安裝時請務必勾選 "Add Python to PATH"
echo.
pause
goto END

:CHECK_PIP
echo.
echo [檢查] 檢查 pip 套件管理器...

:: 嘗試使用 py -3.13
py -3.13 -m pip --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] pip 已就緒
    goto INSTALL_DEPS
)

:: 嘗試直接使用 python
python -m pip --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] pip 已就緒
    goto INSTALL_DEPS
)

echo [錯誤] 無法找到 pip，請重新安裝 Python 並勾選 "pip"
pause
goto END

:INSTALL_DEPS
echo.
echo ==========================================
echo    安裝必要套件
echo ==========================================
echo.

:: 建立 requirements.txt
echo [準備] 建立套件清單...
(
echo opencv-python^>=4.8.0
echo numpy^>=1.24.0
echo ultralytics^>=8.0.0
echo PyQt5^>=5.15.0
echo psutil^>=5.9.0
echo pygetwindow
echo pyrect
echo pillow
echo requests
) > requirements.txt

echo [安裝] 正在安裝必要套件...
echo [提示] 這可能需要 5-10 分鐘，請耐心等候...
echo.

:: 嘗試使用 py -3.13
py -3.13 -m pip install --upgrade pip
py -3.13 -m pip install -r requirements.txt

if %errorlevel% neq 0 (
    echo.
    echo [重試] 嘗試使用 python 指令...
    python -m pip install --upgrade pip
    python -m pip install -r requirements.txt
)

:: 清理暫存檔
del requirements.txt 2>nul

echo.
echo ==========================================
echo    環境配置完成！
echo ==========================================
echo.
echo [OK] 所有必要套件已安裝完成
echo.
echo 您現在可以：
echo   1. 執行 DroidCamAIMonitor.exe 使用圖形介面
echo   2. 或執行整合監控系統腳本
echo.
echo 如需 Discord 通知功能，請：
echo   - 前往 https://328web.vercel.app/ 進行 Discord 授權
echo   - 在程式中輸入您的 Discord 用戶 ID
echo.

:END
pause

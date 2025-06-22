@echo off
REM Script untuk generate keyfile MongoDB di Windows
REM Requirements: OpenSSL harus terinstall (bisa dari Git for Windows atau WSL)

echo ========================================
echo MongoDB Keyfile Generator for Railway
echo ========================================
echo.

REM Check if openssl is available
openssl version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: OpenSSL tidak ditemukan!
    echo.
    echo Silakan install salah satu dari:
    echo 1. Git for Windows (includes OpenSSL)
    echo 2. WSL (Windows Subsystem for Linux)
    echo 3. OpenSSL for Windows
    echo.
    pause
    exit /b 1
)

echo Generating MongoDB keyfile...
echo.

REM Generate keyfile
for /f "delims=" %%i in ('openssl rand -base64 756 ^| tr -d "\n"') do set KEYFILE=%%i

echo Generated keyfile:
echo ========================================
echo %KEYFILE%
echo ========================================
echo.

REM Save to file
echo %KEYFILE% > mongodb-keyfile.txt

echo Keyfile saved to: mongodb-keyfile.txt
echo.
echo IMPORTANT:
echo 1. Copy keyfile diatas ke environment variable KEYFILE
echo 2. Gunakan keyfile yang SAMA untuk semua 3 MongoDB nodes
echo 3. Jangan share keyfile ini secara public!
echo.
pause

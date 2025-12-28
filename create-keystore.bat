@echo off
echo ========================================
echo   Create Release Keystore
echo ========================================
echo.

REM Check if keystore already exists
if exist "android\app\upload-keystore.jks" (
    echo WARNING: Keystore already exists!
    echo Location: android\app\upload-keystore.jks
    echo.
    set /p confirm="Do you want to overwrite it? (yes/no): "
    if /i not "%confirm%"=="yes" (
        echo Cancelled.
        pause
        exit /b 0
    )
)

echo.
echo Creating keystore...
echo.
echo You will be asked for:
echo 1. Keystore password (choose a strong password)
echo 2. Key password (can be same as keystore password)
echo 3. Your name or company name
echo 4. Organizational unit (can skip)
echo 5. Organization (can skip)
echo 6. City
echo 7. State
echo 8. Country code (2 letters, e.g., US)
echo.
echo IMPORTANT: Remember your passwords! You'll need them for updates.
echo.
pause

keytool -genkey -v -keystore android\app\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo SUCCESS! Keystore created at:
    echo android\app\upload-keystore.jks
    echo ========================================
    echo.
    echo Next steps:
    echo 1. Run get-release-sha1.bat to get your SHA-1
    echo 2. Add the SHA-1 to Firebase Console
    echo 3. Create android\key.properties file with your passwords
    echo 4. Build release APK with: flutter build apk --release
    echo.
) else (
    echo.
    echo ERROR: Failed to create keystore
    echo.
)

pause

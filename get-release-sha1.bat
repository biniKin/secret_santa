@echo off
echo ========================================
echo   Get Release SHA-1 for Firebase
echo ========================================
echo.

REM Check if keystore exists
if not exist "android\app\upload-keystore.jks" (
    echo ERROR: Keystore not found!
    echo.
    echo Please create the keystore first using:
    echo keytool -genkey -v -keystore android\app\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
    echo.
    pause
    exit /b 1
)

echo Getting SHA-1 from release keystore...
echo.
keytool -list -v -keystore android\app\upload-keystore.jks -alias upload

echo.
echo ========================================
echo Copy the SHA1 fingerprint above and add it to Firebase Console
echo Firebase Console ^> Project Settings ^> Your apps ^> Add fingerprint
echo ========================================
echo.
pause

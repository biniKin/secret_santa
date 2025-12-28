# Release APK Build Guide

## Step 1: Generate Release Keystore

Open Command Prompt or PowerShell and run:

```powershell
keytool -genkey -v -keystore D:\Development\Flutter\secret_santa\secrete_santa\android\app\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**You'll be asked for:**
1. **Keystore password** - Choose a strong password (remember it!)
2. **Key password** - Can be the same as keystore password
3. **Your name** - Your name or company name
4. **Organizational unit** - Can skip (press Enter)
5. **Organization** - Can skip (press Enter)
6. **City** - Your city
7. **State** - Your state
8. **Country code** - Your 2-letter country code (e.g., US, UK)

**IMPORTANT:** Save these passwords somewhere safe! You'll need them for future updates.

## Step 2: Get Release SHA-1

After creating the keystore, get the SHA-1:

```powershell
keytool -list -v -keystore D:\Development\Flutter\secret_santa\secrete_santa\android\app\upload-keystore.jks -alias upload
```

Enter your keystore password when prompted.

**Copy the SHA-1 fingerprint** - it looks like:
```
SHA1: 99:01:EE:D9:3B:94:32:7B:68:E0:50:16:A4:B3:82:FC:25:36:ED:B0
```

## Step 3: Add SHA-1 to Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your Secret Santa project
3. Click the gear icon ⚙️ → Project Settings
4. Scroll down to "Your apps" section
5. Find your Android app
6. Click "Add fingerprint"
7. Paste the **release SHA-1** you copied
8. Click Save

**Note:** Keep your debug SHA-1 too! You need both for development and release.

## Step 4: Create key.properties File

Create a file at `android/key.properties` with this content:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

Replace `YOUR_KEYSTORE_PASSWORD` and `YOUR_KEY_PASSWORD` with your actual passwords.

**IMPORTANT:** This file contains sensitive information. It's already in .gitignore, so it won't be committed to Git.

## Step 5: Update build.gradle.kts

The signing configuration will be automatically set up in the next step.

## Step 6: Build Release APK

After completing steps 1-4, run:

```powershell
flutter build apk --release
```

Or for a smaller APK (split by architecture):

```powershell
flutter build apk --split-per-abi
```

The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

Or if split:
```
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
build/app/outputs/flutter-apk/app-x86_64-release.apk
```

## Step 7: Test the Release APK

Install on your device:

```powershell
flutter install --release
```

Or manually:
```powershell
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Quick Reference

### Get SHA-1 from existing keystore:
```powershell
keytool -list -v -keystore android\app\upload-keystore.jks -alias upload
```

### Get SHA-1 from debug keystore:
```powershell
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Build commands:
```powershell
# Regular APK
flutter build apk --release

# Split APKs (smaller size)
flutter build apk --split-per-abi

# App Bundle (for Play Store)
flutter build appbundle --release
```

## Troubleshooting

### "keytool is not recognized"
Make sure Java JDK is installed and in your PATH. Flutter includes keytool, try:
```powershell
flutter doctor -v
```
Look for the Java binary path.

### "Keystore was tampered with"
Wrong password. Try again with the correct password.

### Firebase authentication not working
Make sure you added the release SHA-1 to Firebase and downloaded the new `google-services.json`.

### App crashes on release
Check logs:
```powershell
adb logcat | findstr "flutter"
```

## Security Notes

- **Never commit** `key.properties` or `upload-keystore.jks` to Git
- **Backup** your keystore file somewhere safe
- **Remember** your passwords - you can't recover them
- If you lose your keystore, you can't update your app on Play Store

## Next Steps

After building the APK:
1. Test thoroughly on multiple devices
2. Check all Firebase features work (auth, Firestore, notifications)
3. Verify the app icon and notification icon appear correctly
4. Test in airplane mode to check offline behavior
5. Ready to distribute or upload to Play Store!

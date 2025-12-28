# Quick Guide: Build Release APK

## 🚀 Quick Steps

### 1. Create Keystore (First Time Only)

Double-click `create-keystore.bat` or run:

```powershell
keytool -genkey -v -keystore android\app\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Remember your passwords!** You'll need them forever.

### 2. Get Release SHA-1

Double-click `get-release-sha1.bat` or run:

```powershell
keytool -list -v -keystore android\app\upload-keystore.jks -alias upload
```

Copy the SHA-1 fingerprint (looks like: `99:01:EE:D9:3B:94:32:7B:68:E0:50:16:A4:B3:82:FC:25:36:ED:B0`)

### 3. Add SHA-1 to Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click ⚙️ → Project Settings
4. Scroll to "Your apps"
5. Click "Add fingerprint"
6. Paste the SHA-1
7. Click Save

### 4. Create key.properties

Create `android/key.properties` file:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

Replace with your actual passwords from step 1.

### 5. Build APK

```powershell
flutter build apk --release
```

Or for smaller APKs:

```powershell
flutter build apk --split-per-abi
```

### 6. Find Your APK

Location: `build/app/outputs/flutter-apk/app-release.apk`

## 📱 Install & Test

```powershell
flutter install --release
```

Or:

```powershell
adb install build/app/outputs/flutter-apk/app-release.apk
```

## ⚠️ Important Notes

- **Keep your keystore safe!** Backup `android/app/upload-keystore.jks`
- **Remember your passwords!** You can't recover them
- **Don't commit** `key.properties` or `*.jks` files to Git
- **Keep both SHA-1s** in Firebase (debug + release)

## 🔍 Verify Everything Works

After installing the release APK, test:
- ✅ Sign in / Sign up
- ✅ Create group
- ✅ Join group
- ✅ Draw names
- ✅ Notifications appear
- ✅ App icon looks correct
- ✅ Notification icon looks correct

## 📦 For Play Store

To build an App Bundle (required for Play Store):

```powershell
flutter build appbundle --release
```

Location: `build/app/outputs/bundle/release/app-release.aab`

## 🆘 Troubleshooting

### "keytool is not recognized"
Java JDK not in PATH. Check with `flutter doctor -v`

### "Keystore was tampered with"
Wrong password. Try again.

### Firebase auth not working
Did you add the release SHA-1 to Firebase?

### App crashes
Check logs: `adb logcat | findstr "flutter"`

## 📝 Files Created

- ✅ `android/app/build.gradle.kts` - Updated with signing config
- ✅ `create-keystore.bat` - Helper script to create keystore
- ✅ `get-release-sha1.bat` - Helper script to get SHA-1
- ✅ `android/key.properties.template` - Template for your passwords
- ✅ `RELEASE_BUILD_GUIDE.md` - Detailed guide

## 🎯 You're Ready!

Follow steps 1-5 above and you'll have your release APK ready to distribute or upload to Play Store!

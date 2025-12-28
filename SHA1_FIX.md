# Google Play Services Error Fix

## 🐛 Error
```
java.lang.SecurityException: Unknown calling package name 'com.google.android.gms'
DEVELOPER_ERROR
```

## 📝 What This Means

This error occurs when your app's SHA-1 certificate fingerprint is not registered in Firebase Console. This is required for Firebase Authentication and other Google services to work properly.

## ✅ Solution

### Step 1: Get Your SHA-1 Certificate Fingerprint

#### For Debug Build (Development):
Run this command in your project root:

**Windows (PowerShell):**
```powershell
cd android
./gradlew signingReport
```

**Or use keytool directly:**
```powershell
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Look for the **SHA-1** fingerprint in the output. It will look like:
```
SHA1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
```

#### For Release Build (Production):
You'll need to get the SHA-1 from your release keystore when you create one.

### Step 2: Add SHA-1 to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **secret_santa** (or whatever you named it)
3. Click the gear icon ⚙️ → **Project Settings**
4. Scroll down to **Your apps** section
5. Find your Android app (com.example.secrete_santa)
6. Click **Add fingerprint**
7. Paste your SHA-1 fingerprint
8. Click **Save**

### Step 3: Download New google-services.json

1. After adding the SHA-1, download the updated `google-services.json`
2. Replace the existing file at: `android/app/google-services.json`
3. Make sure the file is in the correct location

### Step 4: Rebuild the App

```bash
flutter clean
flutter pub get
flutter run
```

## 🔍 Quick Check

Does the flip card actually work despite the error? 

**If YES:** The error is just a warning and won't affect functionality. You can fix it later.

**If NO:** The SHA-1 issue might be blocking Firebase operations. Follow the steps above.

## 🎯 Alternative: Test Without Firebase Auth

If you want to test the flip card functionality without fixing Firebase immediately:

The flip card should still work because it's just a UI animation. The error is related to Firebase Authentication, not the card flip itself.

## 📱 Common Scenarios

### Scenario 1: Card Flips But Shows Error
- **Cause:** SHA-1 not registered
- **Impact:** Firebase Auth might not work properly
- **Fix:** Add SHA-1 to Firebase Console

### Scenario 2: Card Doesn't Flip
- **Cause:** BLoC state issue or data fetching problem
- **Impact:** User can't see their match
- **Fix:** Check Firestore rules and data structure

### Scenario 3: App Crashes on Reveal
- **Cause:** Missing data or null values
- **Impact:** App becomes unusable
- **Fix:** Add null checks and error handling

## 🧪 Testing Steps

1. **Create a group** (as admin)
2. **Join the group** (with another account or device)
3. **Draw names** (as admin)
4. **Click reveal card**
5. **Check if card flips** and shows match name

If steps 1-5 work, the error is just a warning and can be ignored for now.

## 🚨 Important Notes

1. **Debug vs Release:** You need different SHA-1 fingerprints for debug and release builds
2. **Multiple Developers:** Each developer needs to add their debug SHA-1
3. **CI/CD:** Your build server needs its SHA-1 added too
4. **Google Sign-In:** This error will definitely affect Google Sign-In if you add it later

## 📚 References

- [Firebase Android Setup](https://firebase.google.com/docs/android/setup)
- [Get SHA-1 Certificate](https://developers.google.com/android/guides/client-auth)
- [Firebase Console](https://console.firebase.google.com/)

## ✨ Quick Fix for Testing

If you just want to test the app quickly without fixing Firebase:

1. The flip card should still work (it's just UI)
2. Authentication might have issues
3. Add the SHA-1 when you have time

The error won't crash your app, it's just a warning that some Firebase features might not work optimally.

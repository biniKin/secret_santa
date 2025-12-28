# 🔑 Add SHA-1 to Firebase Console - Step by Step

## Your SHA-1 Fingerprint:
```
99:01:EE:D9:3B:94:32:7B:68:E0:50:16:A4:B3:82:FC:25:36:ED:B0
```

## 📋 Steps to Fix the Error

### Step 1: Open Firebase Console
1. Go to: https://console.firebase.google.com/
2. Sign in with your Google account
3. Select your project (the one you created for this app)

### Step 2: Navigate to Project Settings
1. Click the **gear icon** ⚙️ in the top left (next to "Project Overview")
2. Click **"Project settings"**

### Step 3: Find Your Android App
1. Scroll down to the **"Your apps"** section
2. Look for your Android app:
   - Package name: `com.example.secrete_santa`
   - You should see an Android icon 🤖

### Step 4: Add SHA-1 Fingerprint
1. In your Android app section, scroll down to **"SHA certificate fingerprints"**
2. Click **"Add fingerprint"** button
3. Paste this SHA-1:
   ```
   99:01:EE:D9:3B:94:32:7B:68:E0:50:16:A4:B3:82:FC:25:36:ED:B0
   ```
4. Click **"Save"**

### Step 5: Download Updated google-services.json
1. After saving, you should see a **"Download google-services.json"** button
2. Click it to download the updated file
3. Replace the existing file at:
   ```
   secrete_santa/android/app/google-services.json
   ```

### Step 6: Rebuild Your App
```bash
flutter clean
flutter pub get
flutter run
```

## ✅ Verification

After rebuilding, the error should be gone:
- ❌ Before: `java.lang.SecurityException: Unknown calling package name`
- ✅ After: No more Google Play Services errors

## 🎯 What This Fixes

Adding the SHA-1 fingerprint allows Firebase to:
- ✅ Authenticate your app
- ✅ Enable Firebase Authentication properly
- ✅ Allow Google Sign-In (if you add it later)
- ✅ Enable other Firebase services securely

## 📱 Testing After Fix

1. **Stop the app** completely
2. **Rebuild** with `flutter run`
3. **Test authentication**:
   - Sign up with a new account
   - Sign in with existing account
   - Create a group
   - Join a group
   - Draw names
   - Reveal match

All features should work without errors!

## 🚨 Important Notes

### For Multiple Developers:
If other developers work on this project, they need to:
1. Get their own SHA-1 fingerprint (run `./gradlew signingReport`)
2. Add it to Firebase Console (same steps above)
3. Each developer can have their own SHA-1

### For Release Build:
When you create a release build (for Play Store), you'll need to:
1. Generate a release keystore
2. Get the SHA-1 from that keystore
3. Add it to Firebase Console as well

### SHA-256 (Optional):
You can also add the SHA-256 fingerprint for extra security:
```
A8:AF:5C:7A:2C:B8:AD:BE:9B:58:47:C2:12:38:25:68:3C:DA:91:AC:0F:92:C1:DD:E2:6A:C0:11:F2:2:D2:FC:5E
```

## 🎉 Expected Result

After completing these steps:
- ✅ No more Google Play Services errors
- ✅ Firebase Authentication works perfectly
- ✅ All app features work smoothly
- ✅ Flip card reveals matches correctly

## 📞 Need Help?

If you still see errors after adding SHA-1:
1. Make sure you downloaded the NEW google-services.json
2. Make sure you replaced the OLD file
3. Make sure you did `flutter clean` before rebuilding
4. Check that the SHA-1 is correctly added in Firebase Console

---

**Your SHA-1 (copy this):**
```
99:01:EE:D9:3B:94:32:7B:68:E0:50:16:A4:B3:82:FC:25:36:ED:B0
```

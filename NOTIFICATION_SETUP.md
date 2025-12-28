# Firebase Messaging Setup - FIXED

## ✅ What Was Fixed

The `MissingPluginException` error occurred because Firebase Messaging wasn't properly configured on Android. Here's what was fixed:

### 1. Android Manifest Permissions
Added required permissions to `android/app/src/main/AndroidManifest.xml`:
- `INTERNET` - For network communication
- `POST_NOTIFICATIONS` - For Android 13+ notification permission
- `VIBRATE` - For notification vibration
- `RECEIVE_BOOT_COMPLETED` - For persistent notifications

### 2. Firebase Messaging Service
Added FCM service configuration to AndroidManifest.xml:
```xml
<service
    android:name="com.google.firebase.messaging.FirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

### 3. Default Notification Channel
Added default notification channel metadata:
```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="secret_santa_channel" />
```

### 4. Minimum SDK Version
Updated `android/app/build.gradle.kts`:
- Set `minSdk = 21` (required for Firebase Messaging)
- Added `multiDexEnabled = true` for better compatibility

### 5. Error Handling in main.dart
Added try-catch block around notification initialization so the app can still run if notifications fail.

## 🔧 How to Fix the Error

### Step 1: Stop the App
Stop the currently running app completely (not just hot restart).

### Step 2: Clean Build
Run these commands in the terminal:
```bash
cd secrete_santa
flutter clean
flutter pub get
```

### Step 3: Rebuild the App
**IMPORTANT:** You MUST do a full rebuild, not a hot restart!

```bash
flutter run
```

Or if using VS Code/Android Studio:
1. Stop the app completely
2. Click "Run" or "Debug" to do a full rebuild

### Step 4: Test Notifications
After the app rebuilds:
1. The app should launch without the MissingPluginException error
2. Notification permission will be requested on first launch
3. Test by drawing names in a group - all members should receive notifications

## 📱 Testing Checklist

- [ ] App launches without MissingPluginException
- [ ] Notification permission dialog appears
- [ ] Can grant notification permission
- [ ] Drawing names sends notifications to all members
- [ ] Tapping notification opens the app
- [ ] Reveal match card appears after drawing
- [ ] Tapping reveal card shows match dialog

## ⚠️ Important Notes

1. **Hot Restart Won't Work**: After adding native plugins like Firebase Messaging, you MUST do a full rebuild. Hot restart/reload will NOT register the plugin.

2. **Developer Mode (Windows)**: If you see "Building with plugins requires symlink support", enable Developer Mode:
   - Run `start ms-settings:developers` in terminal
   - Or go to Settings > Update & Security > For developers
   - Enable "Developer Mode"

3. **Android 13+**: On Android 13 and above, users must explicitly grant notification permission. The app will request this automatically.

4. **iOS Setup**: If you plan to run on iOS, you'll need additional setup:
   - Add notification capabilities in Xcode
   - Configure APNs (Apple Push Notification service)
   - Update Info.plist with notification permissions

## 🎯 What Happens After Fix

Once rebuilt, the notification flow works like this:

1. **App Launch** → NotificationService initializes → Requests permission
2. **User Grants Permission** → FCM token generated → Saved to Firestore
3. **Admin Draws Names** → DrawService called → Notifications sent to all members
4. **Members Receive Notification** → "Names Have Been Drawn! 🎁"
5. **Member Opens App** → Sees "Reveal Match" card → Taps to see their match
6. **Beautiful Dialog** → Shows match name with gradient design

## 🐛 Troubleshooting

### Still Getting MissingPluginException?
1. Make sure you did `flutter clean`
2. Delete the `build` folder manually
3. Restart your IDE (VS Code/Android Studio)
4. Rebuild the app (not hot restart)

### Notifications Not Showing?
1. Check notification permission is granted in device settings
2. Verify FCM token is saved in Firestore user document
3. Check Firestore rules allow writing to notifications collection
4. Look for errors in the console/logcat

### Permission Dialog Not Appearing?
1. Android 13+ requires explicit permission request
2. Check AndroidManifest.xml has POST_NOTIFICATIONS permission
3. Try uninstalling and reinstalling the app

## 📝 Files Modified

- ✅ `android/app/src/main/AndroidManifest.xml` - Added permissions and FCM service
- ✅ `android/app/build.gradle.kts` - Updated minSdk and added multiDex
- ✅ `lib/main.dart` - Added error handling for notification init
- ✅ `lib/services/notification_service.dart` - Already created
- ✅ `lib/services/draw_service.dart` - Already sends notifications
- ✅ `lib/ui/group_info_page/group_details_page.dart` - Already has reveal UI

## ✨ Next Steps

After the rebuild works:
1. Test the complete notification flow
2. Test on multiple devices
3. Consider adding Cloud Functions for more reliable notification delivery
4. Add notification click handling to navigate to specific group
5. Add notification badges/counts

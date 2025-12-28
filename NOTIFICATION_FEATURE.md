# 🔔 Notification & Match Reveal Feature

## Overview
After the admin draws names, all group members receive notifications and can reveal their Secret Santa match through an interactive UI.

## Features Implemented

### 1. **Notification System** 📱
- **Firebase Cloud Messaging (FCM)** integration
- **Local Notifications** for foreground messages
- **Background message handling**
- **Notification storage** in Firestore for tracking

### 2. **Match Reveal UI** 🎁
- Beautiful gradient card to reveal match
- Animated reveal dialog
- "Tap to reveal" interaction
- Secret reminder message

### 3. **Workflow**

```
Admin Draws Names
    ↓
Names Drawn Algorithm (no self-matches)
    ↓
Matches Saved to Firestore
    ↓
Notifications Sent to All Members
    ↓
Members See "Reveal Match" Card
    ↓
Tap Card → Beautiful Reveal Dialog
    ↓
Shows Match Name with Animation
```

## Files Modified

### Services
1. **notification_service.dart** (NEW)
   - FCM initialization
   - Permission handling
   - Local notification display
   - Group notification sending

2. **draw_service.dart**
   - Added `groupName` parameter
   - Calls notification service after drawing

### BLoC
3. **group_info_bloc.dart**
   - Updated to pass `groupName` to draw service
   - Handles `UserMatchLoaded` state

4. **group_info_event.dart**
   - Added `groupName` to `DrawNamesEvent`

5. **group_info_state.dart**
   - Already has `UserMatchLoaded` and `NoMatchFound` states

### UI
6. **group_details_page.dart**
   - Added beautiful "Reveal Match" card (shown after drawing)
   - Added `_showMatchRevealDialog()` method
   - Handles match reveal tap
   - Shows animated reveal dialog

7. **main.dart**
   - Initialize NotificationService on app start

### Dependencies
8. **pubspec.yaml**
   - Added `firebase_messaging: ^15.1.4`
   - Added `flutter_local_notifications: ^18.0.1`

## UI Components

### Reveal Match Card
```dart
- Gradient background (red theme)
- Gift icon
- "Your Secret Match" title
- "Tap to reveal" button
- Appears only after names are drawn
```

### Reveal Dialog
```dart
- Full-screen dialog
- Gradient background
- Large gift icon
- Match name in white card
- Secret reminder message
- "Got it!" button
```

## Firestore Structure

### Notifications Collection
```javascript
notifications/
  {notificationId}/
    - userId: string
    - groupId: string
    - type: "names_drawn"
    - title: string
    - body: string
    - read: boolean
    - createdAt: timestamp
```

### Matches Collection (existing)
```javascript
matches/
  {matchId}/
    - matchId: string
    - groupId: string
    - giverId: string
    - receiverId: string
    - hasRevealed: boolean
    - createdAt: timestamp
```

## How It Works

### 1. Drawing Names
```dart
// Admin clicks "Draw Names"
context.read<GroupInfoBloc>().add(
  DrawNamesEvent(
    groupId: groupId,
    memberIds: memberIds,
    groupName: groupName, // NEW
  ),
);
```

### 2. Notification Sent
```dart
// In DrawService
await _notificationService.notifyGroupMembersAboutDraw(
  groupId: groupId,
  groupName: groupName,
  memberIds: memberIds,
);
```

### 3. Member Reveals Match
```dart
// Tap on reveal card
context.read<GroupInfoBloc>().add(
  GetUserMatchEvent(
    groupId: groupId,
    userId: currentUserId,
  ),
);

// Shows dialog with match name
_showMatchRevealDialog(context, match);
```

## Testing Checklist

- [ ] **Notifications**
  - [ ] FCM permission requested on first launch
  - [ ] Notification appears after drawing names
  - [ ] Notification shows correct group name
  - [ ] Tapping notification opens app (optional)

- [ ] **Reveal Card**
  - [ ] Card only shows after names are drawn
  - [ ] Card has gradient background
  - [ ] "Tap to reveal" text visible
  - [ ] Tapping card triggers reveal

- [ ] **Reveal Dialog**
  - [ ] Dialog shows with animation
  - [ ] Match name displays correctly
  - [ ] Secret reminder shows
  - [ ] "Got it!" button closes dialog
  - [ ] Cannot dismiss by tapping outside

- [ ] **Edge Cases**
  - [ ] No match found shows appropriate message
  - [ ] Multiple reveals work correctly
  - [ ] Works for all group members

## Setup Required

### 1. Android Setup
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

### 2. iOS Setup
Add to `ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 3. Firebase Console
1. Enable Cloud Messaging in Firebase Console
2. Download updated `google-services.json` (Android)
3. Download updated `GoogleService-Info.plist` (iOS)

### 4. Cloud Function (Optional)
For production, create a Cloud Function to send FCM messages:
```javascript
exports.sendDrawNotification = functions.firestore
  .document('groups/{groupId}')
  .onUpdate(async (change, context) => {
    const after = change.after.data();
    if (after.hasDrawn && !change.before.data().hasDrawn) {
      // Send FCM to all members
    }
  });
```

## Future Enhancements

1. **Push Notification Handling**
   - Navigate to group details when tapping notification
   - Show notification badge count

2. **Notification History**
   - Show list of all notifications
   - Mark as read functionality

3. **Reminder Notifications**
   - Remind users to buy gifts
   - Countdown to exchange date

4. **Match Hints**
   - Allow users to add gift preferences
   - Show hints in reveal dialog

## Notes

- Notifications are stored in Firestore for tracking
- FCM tokens are saved to user documents
- Local notifications work even without internet
- Background messages require Cloud Functions for full functionality
- The reveal dialog cannot be dismissed accidentally (barrierDismissible: false)

## Dependencies Added

```yaml
firebase_messaging: ^15.1.4
flutter_local_notifications: ^18.0.1
```

Run `flutter pub get` to install!

# Notification Testing Guide

## 📱 Current Implementation

### What Happens When Names Are Drawn:

1. **Admin clicks "Draw Names"**
2. **DrawService.drawNames()** is called
3. **Matches are generated** and saved to Firestore
4. **Group status updated** (`hasDrawn: true`)
5. **NotificationService.notifyGroupMembersAboutDraw()** is called
6. **Notification documents created** in Firestore for each member
7. **Local notification shown** on the admin's device

### Console Logs to Watch For:

When you draw names, you should see:
```
✅ Names drawn successfully for group: [Group Name]
📧 Sending notifications to [X] members...
Sending notifications to [X] members for group: [Group Name]
✅ Notifications created successfully for [Group Name]
✅ Draw process completed successfully!
```

## 🧪 Testing Steps

### Test 1: Draw Names and Check Logs

1. **Open a group** (as admin)
2. **Click "Draw Names"**
3. **Watch the console** for the logs above
4. **Check for local notification** on your device
5. **Verify success message** appears

### Test 2: Check Firestore

After drawing names, check Firebase Console:

1. Go to **Firestore Database**
2. Check **notifications** collection
3. Should see documents for each member:
   ```json
   {
     "userId": "member123",
     "groupId": "group456",
     "type": "names_drawn",
     "title": "Names Have Been Drawn! 🎁",
     "body": "The Secret Santa names have been drawn for \"Group Name\". Tap to reveal your match!",
     "read": false,
     "createdAt": Timestamp
   }
   ```

### Test 3: Local Notification

On the device that drew names:
- [ ] Notification appears in notification tray
- [ ] Title: "Names Have Been Drawn! 🎁"
- [ ] Body includes group name
- [ ] Tapping notification opens app (if configured)

## 📋 Current Limitations

### ⚠️ Important Notes:

1. **Local Notifications Only**
   - Currently shows notification only on the device that drew names
   - Other members won't receive push notifications yet
   - Notification documents are saved to Firestore for all members

2. **No FCM Push Notifications**
   - To send actual push notifications to all members, you need:
     - Firebase Cloud Functions
     - Or a backend server
     - Or FCM Admin SDK

3. **Notification Documents**
   - Created in Firestore for tracking
   - Can be used to show in-app notifications
   - Can be processed by Cloud Functions later

## 🚀 How to Enable Full Push Notifications

### Option 1: Firebase Cloud Functions (Recommended)

Create a Cloud Function that triggers when names are drawn:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendDrawNotifications = functions.firestore
  .document('groups/{groupId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();
    
    // Check if hasDrawn changed to true
    if (newData.hasDrawn && !oldData.hasDrawn) {
      const groupId = context.params.groupId;
      const groupName = newData.groupName;
      const memberIds = newData.members;
      
      // Get FCM tokens for all members
      const tokens = [];
      for (const memberId of memberIds) {
        const userDoc = await admin.firestore()
          .collection('users')
          .doc(memberId)
          .get();
        
        if (userDoc.exists && userDoc.data().fcmToken) {
          tokens.push(userDoc.data().fcmToken);
        }
      }
      
      // Send notifications
      if (tokens.length > 0) {
        const message = {
          notification: {
            title: 'Names Have Been Drawn! 🎁',
            body: `The Secret Santa names have been drawn for "${groupName}". Tap to reveal your match!`
          },
          data: {
            groupId: groupId,
            type: 'names_drawn'
          },
          tokens: tokens
        };
        
        await admin.messaging().sendMulticast(message);
      }
    }
  });
```

### Option 2: Save FCM Tokens

Update the app to save FCM tokens when users log in:

```dart
// In AuthService or after login
final notificationService = NotificationService();
await notificationService.getAndSaveToken(userId);
```

## 📊 Verification Checklist

After drawing names:

- [ ] Console shows "✅ Names drawn successfully"
- [ ] Console shows "📧 Sending notifications to X members"
- [ ] Console shows "✅ Notifications created successfully"
- [ ] Local notification appears on admin's device
- [ ] Firestore has notification documents for all members
- [ ] Group's `hasDrawn` field is `true`
- [ ] Matches collection has documents for all members

## 🔍 Debugging

### If No Notification Appears:

1. **Check notification permission:**
   ```dart
   // Should see in console on app start:
   User granted permission
   ```

2. **Check console for errors:**
   ```
   ❌ Error sending notifications: [error message]
   ```

3. **Verify notification service initialized:**
   - Check `main.dart` calls `notificationService.initialize()`
   - Should happen before `runApp()`

4. **Check Android notification channel:**
   - Channel ID: `secret_santa_channel`
   - Should be created automatically

### If Notification Documents Not Created:

1. **Check Firestore rules:**
   ```javascript
   match /notifications/{notificationId} {
     allow read: if request.auth.uid == resource.data.userId;
     allow write: if request.auth != null;
   }
   ```

2. **Check console for Firestore errors**

3. **Verify memberIds array is correct**

## ✅ Expected Behavior

### Current (Local Notifications):
1. Admin draws names
2. Admin sees local notification
3. All members have notification documents in Firestore
4. Members can check in-app for notifications

### Future (With Cloud Functions):
1. Admin draws names
2. Cloud Function triggers
3. All members receive push notifications
4. Members can tap to open app and reveal match

## 📝 Next Steps

To implement full push notifications:

1. **Deploy Cloud Function** (see Option 1 above)
2. **Save FCM tokens** when users log in
3. **Test with multiple devices**
4. **Add notification click handling** to navigate to group

For now, the notification system:
- ✅ Creates notification documents
- ✅ Shows local notification on admin device
- ✅ Tracks notification status in Firestore
- ⏳ Needs Cloud Functions for multi-device push notifications

# Group Details Loading Issue - Debug Guide

## 🐛 Problem
Getting "Failed to load group details" message when opening a group.

## ✅ Changes Made

### 1. Added Error Display
Now when there's an error, you'll see:
- Error icon
- Error message (the actual error from Firebase)
- Retry button

### 2. Added Debug Logging
Added print statements to track the flow:
- `Loading group details for groupId: [id]`
- `Group data fetched: true/false`
- `Fetching group members...`
- `Members fetched: [count]`
- `Error in _onLoadGroupDetails: [error]`

## 🔍 How to Debug

### Step 1: Check Console Logs
After hot restart, when you open a group, check the console for these logs:

```
Loading group details for groupId: [your-group-id]
Group data fetched: true
Fetching group members...
Members fetched: 2
```

### Step 2: Look for Errors
If you see an error, it will show:
```
Error in _onLoadGroupDetails: [actual error message]
```

Common errors:
- **"Group not found"** → Group ID is wrong or group doesn't exist
- **"Permission denied"** → Firestore rules issue
- **"Error getting group members"** → Members array is malformed

### Step 3: Check Firestore Rules

Make sure your Firestore rules allow reading:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Groups collection
    match /groups/{groupId} {
      allow read: if request.auth != null && 
                     request.auth.uid in resource.data.members;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
                       request.auth.uid == resource.data.adminId;
      allow delete: if request.auth != null && 
                       request.auth.uid == resource.data.adminId;
    }
    
    // Matches collection
    match /matches/{matchId} {
      allow read: if request.auth != null && 
                     request.auth.uid == resource.data.giverId;
      allow write: if false; // Only server can write
    }
  }
}
```

### Step 4: Verify Data Structure

Check your Firestore console to ensure the group document has:

```json
{
  "groupId": "abc123",
  "groupName": "Friends Secret Santa",
  "groupCode": "SANTA1",
  "adminId": "user123",
  "members": ["user123", "user456"],
  "exchangeDate": Timestamp,
  "budget": "50",
  "hasDrawn": false,
  "createdAt": Timestamp
}
```

## 🧪 Testing Steps

### Test 1: Create a New Group
1. Create a group as admin
2. Note the group code
3. Open the group from home page
4. Check console logs
5. Should see group details

### Test 2: Join Existing Group
1. Use another account
2. Join group with code
3. Open the group
4. Check console logs
5. Should see group details

### Test 3: Check Error Message
1. If you see error screen
2. Read the error message
3. Check console for detailed logs
4. Click "Retry" button

## 🔧 Common Fixes

### Fix 1: Firestore Rules
If you see "Permission denied":
1. Go to Firebase Console
2. Firestore Database → Rules
3. Update rules (see Step 3 above)
4. Publish rules

### Fix 2: Group ID Mismatch
If you see "Group not found":
1. Check the groupId being passed
2. Verify it matches Firestore document ID
3. Check home page is passing correct ID

### Fix 3: Members Array Issue
If you see "Error getting group members":
1. Check Firestore group document
2. Ensure `members` is an array of strings
3. Ensure all member IDs exist in users collection

## 📱 What to Check Now

1. **Hot restart the app**
2. **Open a group**
3. **Check the console output**
4. **Look for the debug logs**
5. **If error, read the error message on screen**
6. **Share the console logs if you need help**

## 🎯 Expected Console Output

### Success Case:
```
Loading group details for groupId: abc123
Group data fetched: true
Fetching group members...
Members fetched: 2
```

### Error Case:
```
Loading group details for groupId: abc123
Group data fetched: true
Fetching group members...
Error in _onLoadGroupDetails: Error getting group members: [specific error]
```

## 💡 Quick Checks

- [ ] Firebase SHA-1 added and google-services.json updated?
- [ ] User is logged in?
- [ ] Group exists in Firestore?
- [ ] User is a member of the group?
- [ ] Firestore rules allow reading?
- [ ] Internet connection working?

## 🚀 Next Steps

After hot restart:
1. Open the app
2. Navigate to a group
3. Check console for debug logs
4. Share the logs if you still see errors

The error screen now shows the actual error message, so you'll know exactly what's wrong!

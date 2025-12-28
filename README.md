# 🎁 Secret Santa App

A Flutter-based Secret Santa gift exchange app with Firebase backend. Organize your Secret Santa events with ease!

## ✨ Features

- 🔐 **User Authentication** - Email/password sign up and login
- 👥 **Group Management** - Create and join Secret Santa groups
- 🎲 **Random Matching** - Automatic Secret Santa assignment (no self-matches)
- 📅 **Exchange Date Reminders** - Scheduled notifications one day before exchange
- 🔔 **Push Notifications** - Stay updated with group activities
- 👤 **User Profiles** - Track your groups and matches
- 🎨 **Beautiful UI** - Clean, festive design with red theme
- 📱 **Responsive** - Works on all Android screen sizes

## 📸 Screenshots

_Add your app screenshots here_

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.10.3 or higher)
- [Firebase Account](https://console.firebase.google.com/)
- Android Studio or VS Code
- Android device or emulator

### Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add an Android app to your project
   - Package name: `com.example.secrete_santa`
3. Download `google-services.json` and place it in `android/app/`
4. Enable the following Firebase services:
   - **Authentication** (Email/Password provider)
   - **Firestore Database**
   - **Firebase Cloud Messaging**

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/secret-santa-app.git
cd secret-santa-app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Add your `google-services.json` file to `android/app/`

4. Run the app:
```bash
flutter run
```

## 🔧 Configuration

### Android Signing (For Release Build)

1. Generate a keystore:
```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Create `android/key.properties`:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

3. Get your SHA-1 fingerprint:
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

4. Add the SHA-1 to Firebase Console (Project Settings → Your apps → Add fingerprint)

### Build Release APK

```bash
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## 📱 How to Use

1. **Sign Up** - Create an account with email and password
2. **Create Group** - Set group name, exchange date, and budget
3. **Share Code** - Share the group code with participants
4. **Join Group** - Others can join using the group code
5. **Draw Names** - Admin draws names when everyone has joined
6. **Reveal Match** - Tap the card to reveal your Secret Santa match
7. **Get Reminded** - Receive notification one day before exchange

## 🏗️ Architecture

- **State Management**: BLoC Pattern
- **Backend**: Firebase (Auth, Firestore, FCM)
- **Local Notifications**: flutter_local_notifications
- **UI**: Material Design with custom theme

## 📦 Dependencies

- `firebase_core` - Firebase initialization
- `firebase_auth` - User authentication
- `cloud_firestore` - Database
- `firebase_messaging` - Push notifications
- `flutter_local_notifications` - Local scheduled notifications
- `flutter_bloc` - State management
- `timezone` - Notification scheduling
- `equatable` - Value equality
- `uuid` - Unique ID generation

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for the backend services
- All contributors and testers

## 📞 Support

If you have any questions or issues, please open an issue on GitHub.

---

Made with ❤️ and Flutter

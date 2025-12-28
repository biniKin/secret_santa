import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize notifications
  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Get FCM token and save to Firestore
  Future<String?> getAndSaveToken(String userId) async {
    try {
      String? token = await _messaging.getToken();

      if (token != null) {
        // Save token to user document
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      }

      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message in foreground: ${message.messageId}');

    if (message.notification != null) {
      _showLocalNotification(
        title: message.notification!.title ?? 'Secret Santa',
        body: message.notification!.body ?? '',
        payload: message.data['groupId'],
      );
    }
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'secret_santa_channel',
          'Secret Santa Notifications',
          channelDescription: 'Notifications for Secret Santa app',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Send notification to group members after drawing names
  Future<void> notifyGroupMembersAboutDraw({
    required String groupId,
    required String groupName,
    required List<String> memberIds,
  }) async {
    try {
      print(
        'Sending notifications to ${memberIds.length} members for group: $groupName',
      );

      // Save notification documents to Firestore for each member
      for (String memberId in memberIds) {
        await _firestore.collection('notifications').add({
          'userId': memberId,
          'groupId': groupId,
          'type': 'names_drawn',
          'title': 'Names Have Been Drawn! 🎁',
          'body':
              'The Secret Santa names have been drawn for "$groupName". Tap to reveal your match!',
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Show local notification immediately for testing
      // In production, you'd use FCM with Cloud Functions
      await _showLocalNotification(
        title: 'Names Have Been Drawn! 🎁',
        body:
            'The Secret Santa names have been drawn for "$groupName". Tap to reveal your match!',
        payload: groupId,
      );

      print('Notifications created successfully for $groupName');
    } catch (e) {
      print('Error sending notifications: $e');
    }
  }

  // Send test notification
  Future<void> sendTestNotification() async {
    await _showLocalNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Secret Santa!',
    );
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

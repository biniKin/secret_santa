import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize notifications
  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

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
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

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

  // Schedule notification for exchange date reminder
  Future<void> scheduleExchangeDateReminder({
    required String groupId,
    required String groupName,
    required DateTime exchangeDate,
  }) async {
    try {
      final now = DateTime.now();

      // Calculate the day before exchange date at 9 AM
      final reminderDate = DateTime(
        exchangeDate.year,
        exchangeDate.month,
        exchangeDate.day - 1, // One day before exchange
        9, // 9 AM
        0,
      );

      // Only schedule if the reminder date is in the future
      if (reminderDate.isAfter(now)) {
        await _localNotifications.zonedSchedule(
          groupId.hashCode, // Use groupId hash as notification ID
          'Exchange Day Tomorrow! 🎁',
          'Don\'t forget! The Secret Santa exchange for "$groupName" is tomorrow!',
          _convertToTZDateTime(reminderDate),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'secret_santa_channel',
              'Secret Santa Notifications',
              channelDescription: 'Notifications for Secret Santa app',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@drawable/ic_notification',
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: groupId,
        );

        print(
          '✅ Scheduled reminder for "$groupName" on ${reminderDate.toString()}',
        );
      } else {
        print('⚠️ Reminder date for "$groupName" has already passed');
      }
    } catch (e) {
      print('❌ Error scheduling exchange date reminder: $e');
    }
  }

  // Check all user's groups and schedule reminders
  Future<void> checkAndScheduleExchangeReminders(String userId) async {
    try {
      // Get all groups where user is a member
      final groupsSnapshot = await _firestore
          .collection('groups')
          .where('members', arrayContains: userId)
          .get();

      for (var doc in groupsSnapshot.docs) {
        final data = doc.data();
        final exchangeDate = (data['exchangeDate'] as Timestamp?)?.toDate();
        final groupName = data['groupName'] as String?;
        final hasDrawn = data['hasDrawn'] as bool? ?? false;

        if (exchangeDate != null && groupName != null && hasDrawn) {
          await scheduleExchangeDateReminder(
            groupId: doc.id,
            groupName: groupName,
            exchangeDate: exchangeDate,
          );
        }
      }

      print('Checked and scheduled reminders for user groups');
    } catch (e) {
      print('Error checking exchange reminders: $e');
    }
  }

  // Helper to convert DateTime to TZDateTime
  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final location = tz.local;
    return tz.TZDateTime.from(dateTime, location);
  }

  // Cancel scheduled notification for a group
  Future<void> cancelExchangeReminder(String groupId) async {
    try {
      await _localNotifications.cancel(groupId.hashCode);
      print('Cancelled reminder for group: $groupId');
    } catch (e) {
      print('Error cancelling reminder: $e');
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

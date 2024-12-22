import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes FCM and handles permissions, token saving, and message handling.
  Future<void> initializeFCM(String uid) async {
    // Request notification permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted FCM permissions');
    } else {
      print('User declined or has not granted FCM permissions');
      return;
    }

    // Save the FCM token to Firestore
    await saveFCMToken(uid);

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      print('FCM token refreshed: $newToken');
      saveFCMToken(uid); // Save the new token to Firestore
    });

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.notification?.title}');
      if (message.notification != null) {
        try {
          _showNotification(
            message.notification!.title ?? 'Notification',
            message.notification!.body ?? 'You have a new message',
          );
        } catch (e) {
          print('Error showing notification: $e');
        }
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Saves the FCM token to the Firestore user document.
  Future<void> saveFCMToken(String uid) async {
    try {
      String? token = await _messaging.getToken();
      await _firestore.collection('users').doc(uid).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
      print('FCM Token saved: $token');
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  /// Initializes local notifications for the app (Android only).
  Future<void> _initializeLocalNotifications() async {
    // Android settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Platform-specific initialization
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    // Initialize plugin
    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          print('Notification clicked with payload: ${response.payload}');
          // Handle navigation or other logic here
        }
      },
    );
    print('Local notifications initialized');
  }

  /// Displays a local notification for foreground messages.
  Future<void> _showNotification(String title, String body) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'default_channel',
        'Default Channel',
        channelDescription: 'Notification channel for app',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

      await _localNotificationsPlugin.show(
        0, // Notification ID
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }
}

/// Handles background messages received by FCM.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.title}');
}

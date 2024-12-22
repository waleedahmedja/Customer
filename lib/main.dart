import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Import customer-specific screens
import 'features/customer/customer_dashboard.dart';
import 'features/customer/book_job_screen.dart';
import 'features/customer/previous_jobs_screen.dart';
import 'features/customer/track_worker_screen.dart';

// Local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initializeNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CleanMatch Customer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          elevation: 0,
        ),
      ),
      home: const CustomerDashboard(),
      routes: {
        '/book-job': (_) => const BookJobScreen(),
        '/track-worker': (context) {
          final workerId = ModalRoute.of(context)?.settings.arguments as String;
          return TrackWorkerScreen(workerId: workerId);
        },
        '/previous-jobs': (_) => const PreviousJobsScreen(),
      },
    );
  }
}

/// A service class for handling FCM and notifications
class NotificationService {
  static Future<void> initializeNotifications() async {
    // Local notification setup
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initSettings =
        const InitializationSettings(android: androidInitSettings);

    // Initialize notifications with the new callback
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        print("Notification clicked: ${response.payload}");
        // Handle navigation or any other logic here
      },
    );

    // Setup FCM listeners
    setupFCMListeners();
  }

  static void setupFCMListeners() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showNotification(
          message.notification!.title ?? "Notification",
          message.notification!.body ?? "You have a new message",
        );
      }
    });

    // Handle messages when the app is opened from a terminated state
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print("App launched by notification: ${message.data}");
        // Handle navigation or other logic here
      }
    });

    // Handle background messages when the app is resumed
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification caused app to open: ${message.data}");
      // Navigate to a specific screen if needed
    });
  }

  static Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
    );
  }
}

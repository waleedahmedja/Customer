import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/location_utils.dart';

class GeofencingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Monitors a worker's proximity to the customer and triggers notifications when within range.
  /// 
  /// [workerId]: The unique ID of the worker being monitored.
  /// [customerId]: The unique ID of the customer to notify.
  /// [customerLocation]: The customer's location as a GeoPoint.
  /// [proximityRadius]: The radius in meters to trigger notifications (default: 500m).
  void monitorWorkerProximity(
      String workerId, String customerId, GeoPoint customerLocation,
      {double proximityRadius = 500}) {
    try {
      // Listen to worker's location updates
      _firestore
          .collection('users')
          .doc(workerId)
          .snapshots()
          .listen((snapshot) async {
        if (!snapshot.exists) {
          print('Worker document does not exist.');
          return;
        }

        // **Explicitly cast snapshot.data() to Map<String, dynamic>**
        var data = snapshot.data() as Map<String, dynamic>;
        GeoPoint? workerLocation = data['location'];

        if (workerLocation == null) {
          print('Worker location is missing.');
          return;
        }

        // Calculate the distance between the worker and the customer
        double distance = LocationUtils.calculateDistance(
          customerLocation.latitude,
          customerLocation.longitude,
          workerLocation.latitude,
          workerLocation.longitude,
        );

        // Check if the worker is within the specified radius
        if (distance <= proximityRadius) {
          print('Worker is within $proximityRadius meters of the customer.');

          // Check if the customer was recently notified
          bool alreadyNotified = await _hasBeenNotifiedRecently(workerId, customerId);
          if (alreadyNotified) {
            print('Customer already notified recently.');
            return;
          }

          // Notify the customer
          await _notifyCustomer(workerId, customerId);
        }
      });
    } catch (e) {
      print('Error monitoring worker proximity: $e');
    }
  }

  /// Checks if the customer was recently notified about a worker's proximity.
  Future<bool> _hasBeenNotifiedRecently(String workerId, String customerId) async {
    try {
      QuerySnapshot recentNotifications = await _firestore
          .collection('notifications')
          .where('customerId', isEqualTo: customerId)
          .where('workerId', isEqualTo: workerId)
          .where('timestamp',
              isGreaterThan: Timestamp.fromDate(
                  DateTime.now().subtract(const Duration(minutes: 5))))
          .get();

      return recentNotifications.docs.isNotEmpty;
    } catch (e) {
      print('Error checking notification history: $e');
      return false;
    }
  }

  /// Sends a notification to the customer when the worker is nearby.
  Future<void> _notifyCustomer(String workerId, String customerId) async {
    try {
      // Fetch the customer's FCM token
      DocumentSnapshot customerSnapshot =
          await _firestore.collection('users').doc(customerId).get();

      if (!customerSnapshot.exists) {
        print('Customer document does not exist.');
        return;
      }

      // **Explicitly cast customerSnapshot.data() to Map<String, dynamic>**
      var customerData = customerSnapshot.data() as Map<String, dynamic>;
      String? fcmToken = customerData['fcmToken'];

      if (fcmToken == null) {
        print('Customer FCM token not found.');
        return;
      }

      // Add a notification record in Firestore
      await _firestore.collection('notifications').add({
        'customerId': customerId,
        'workerId': workerId,
        'message': 'The worker is near your location!',
        'timestamp': Timestamp.now(),
      });

      // Send FCM notification
      await FirebaseMessaging.instance.sendMessage(
        to: fcmToken,
        data: {
          'title': 'Worker Nearby',
          'body': 'The worker is near your location!',
        },
      );

      print('Notification sent to customer.');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}

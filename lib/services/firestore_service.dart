import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Adds a user to the Firestore `users` collection.
  Future<void> addUser(String uid, Map<String, dynamic> userData) async {
    if (uid.isEmpty || userData.isEmpty) {
      throw ArgumentError('UID and userData cannot be empty');
    }

    try {
      await _firestore.collection('users').doc(uid).set(userData);
    } catch (e) {
      print('Error adding user: $e');
      rethrow;
    }
  }

  /// Fetches a user document by UID from the `users` collection.
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      rethrow;
    }
  }

  /// Creates a new job in the Firestore `jobs` collection.
  Future<void> createJob(Map<String, dynamic> jobData) async {
    if (jobData.isEmpty) {
      throw ArgumentError('Job data cannot be empty');
    }

    try {
      await _firestore.collection('jobs').add(jobData);
    } catch (e) {
      print('Error creating job: $e');
      rethrow;
    }
  }

  /// Updates the status of a job in the Firestore `jobs` collection.
  Future<void> updateJobStatus(String jobId, String status) async {
    if (jobId.isEmpty || status.isEmpty) {
      throw ArgumentError('Job ID and status cannot be empty');
    }

    try {
      await _firestore.collection('jobs').doc(jobId).update({'status': status});
    } catch (e) {
      print('Error updating job status: $e');
      rethrow;
    }
  }

  /// Updates worker earnings in the Firestore `earnings` collection using transactions.
  Future<void> addWorkerEarnings(String workerId, double amount) async {
    try {
      DocumentReference earningsRef = _firestore.collection('earnings').doc(workerId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(earningsRef);

        if (!snapshot.exists) {
          transaction.set(earningsRef, {
            'daily': [amount],
            'weekly': [amount],
            'monthly': [amount],
            'total': amount,
          });
        } else {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          List<double> daily = List<double>.from(data['daily'] ?? []);
          List<double> weekly = List<double>.from(data['weekly'] ?? []);
          List<double> monthly = List<double>.from(data['monthly'] ?? []);
          double total = data['total'] ?? 0.0;

          daily.add(amount);
          weekly.add(amount);
          monthly.add(amount);
          total += amount;

          transaction.update(earningsRef, {
            'daily': daily,
            'weekly': weekly,
            'monthly': monthly,
            'total': total,
          });
        }
      });
    } catch (e) {
      print('Error updating worker earnings: $e');
      rethrow;
    }
  }

  /// Fetches paginated jobs from the Firestore `jobs` collection.
  Future<QuerySnapshot> fetchPaginatedJobs({DocumentSnapshot? lastDoc, int limit = 10}) async {
    try {
      Query query = _firestore.collection('jobs').orderBy('createdAt').limit(limit);
      if (lastDoc != null) query = query.startAfterDocument(lastDoc);
      return await query.get();
    } catch (e) {
      print('Error fetching paginated jobs: $e');
      rethrow;
    }
  }

  /// Deletes a job by ID from the Firestore `jobs` collection.
  Future<void> deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
    } catch (e) {
      print('Error deleting job: $e');
      rethrow;
    }
  }
}

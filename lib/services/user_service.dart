import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Adds a user to the Firestore `users` collection.
  ///
  /// If the document exists, it will overwrite unless `merge` is set to true.
  Future<void> addUser(String uid, Map<String, dynamic> userData, {bool merge = false}) async {
    _validateUserData(userData);
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(userData, SetOptions(merge: merge));
      print('User added successfully: $uid');
    } catch (e) {
      print('Error adding user: $e');
      rethrow;
    }
  }

  /// Updates an existing user in the Firestore `users` collection.
  ///
  /// This method merges updates with the existing document.
  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    _validateUserData(updates);
    try {
      await _firestore.collection('users').doc(uid).update(updates);
      print('User updated successfully: $uid');
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  /// Fetches a user document by UID.
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print('User not found: $uid');
        return null;
      }
    } catch (e) {
      print('Error fetching user: $e');
      rethrow;
    }
  }

  /// Deletes a user document from the Firestore `users` collection.
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      print('User deleted successfully: $uid');
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  /// Fetches all users by role from the Firestore `users` collection.
  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching users by role: $e');
      rethrow;
    }
  }

  /// Adds multiple users in a single batch operation.
  Future<void> addUsersBatch(List<Map<String, dynamic>> users) async {
    WriteBatch batch = _firestore.batch();

    for (var user in users) {
      DocumentReference userRef = _firestore.collection('users').doc(user['uid']);
      batch.set(userRef, user, SetOptions(merge: true));
    }

    try {
      await batch.commit();
      print('Batch user creation successful.');
    } catch (e) {
      print('Error in batch user creation: $e');
      rethrow;
    }
  }

  /// Validates required fields in user data.
  void _validateUserData(Map<String, dynamic> data) {
    if (!data.containsKey('name') || data['name'].isEmpty) {
      throw ArgumentError('User data must contain a valid "name".');
    }
    if (!data.containsKey('email') || data['email'].isEmpty) {
      throw ArgumentError('User data must contain a valid "email".');
    }
  }
}

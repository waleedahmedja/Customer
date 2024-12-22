import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../services/firestore_service.dart';
import '../../../services/fcm_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final FCMService _fcmService = FCMService();

  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String cnic,
    required String role,
  }) async {
    _validateSignUpInputs(email: email, password: password, name: name, cnic: cnic);

    _setLoading(true);
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;

      if (_user != null) {
        await _firestoreService.addUser(_user!.uid, _buildUserData(
          name: name,
          cnic: cnic,
          email: email,
          role: role,
        ));

        await _fcmService.saveFCMToken(_user!.uid);
      }
      notifyListeners();
    } catch (e) {
      print('Error during sign-up: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;

      if (_user != null) {
        await _fetchUserData(_user!.uid);
        await _fcmService.saveFCMToken(_user!.uid);
      }
      notifyListeners();
    } catch (e) {
      print('Error during sign-in: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _auth.signOut();
      _user = null;
      _userData = null;
      notifyListeners();
    } catch (e) {
      print('Error during sign-out: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reloadUserData() async {
    if (_user == null) return;
    _setLoading(true);
    try {
      await _fetchUserData(_user!.uid);
    } catch (e) {
      print('Error reloading user data: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _validateSignUpInputs({
    required String email,
    required String password,
    required String name,
    required String cnic,
  }) {
    if (email.isEmpty || !email.contains('@')) {
      throw ArgumentError('Invalid email');
    }
    if (password.isEmpty || password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters');
    }
    if (name.isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    if (cnic.isEmpty || cnic.length != 13) {
      throw ArgumentError('Invalid CNIC format');
    }
  }

  Map<String, dynamic> _buildUserData({
    required String name,
    required String cnic,
    required String email,
    required String role,
  }) {
    return {
      'name': name,
      'cnic': cnic,
      'email': email,
      'role': role,
      'uid': _user!.uid,
      'createdAt': Timestamp.now(),
      if (role == 'worker') ...{
        'location': null,
        'isAvailable': false,
      },
    };
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      final userDoc = await _firestoreService.getUser(uid);
      if (userDoc != null) {
        _userData = userDoc;
      } else {
        throw Exception("User data not found.");
      }
    } catch (e) {
      print('Error fetching user data: $e');
      rethrow;
    }
  }
}

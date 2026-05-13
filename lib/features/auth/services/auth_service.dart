import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:pick_pack/models/app_user.dart';
import 'package:pick_pack/firebase_options.dart';
import 'package:pick_pack/core/services/notification_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  
  StreamSubscription? _userSub;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  AuthService() {
    _init();
  }

  Future<void> _init() async {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        _fetchUserData(user.uid);
      } else {
        _clearData();
      }
    });
  }

  void _clearData() {
    _userSub?.cancel();
    _userSub = null;
    _currentUser = null;
    notifyListeners();
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      _userSub?.cancel();
      // Listen to user document for real-time blocking/deletion enforcement
      _userSub = _firestore.collection('users').doc(uid).snapshots().listen((doc) async {
        if (!doc.exists) {
          signOut();
          return;
        }
        final userData = doc.data()!;
        if (userData['isBlocked'] == true) {
          signOut();
          return;
        }

        // Check if their agency is blocked
        final String? agencyId = userData['agencyId'];
        if (agencyId != null && agencyId.isNotEmpty) {
          final agencyDoc = await _firestore.collection('agencies').doc(agencyId).get();
          if (agencyDoc.exists && agencyDoc.data()?['isBlocked'] == true) {
            signOut();
            return;
          }
          
          // Check if their agency's gang is blocked
          final gangSnap = await _firestore.collection('gangs').where('agencyIds', arrayContains: agencyId).limit(1).get();
          if (gangSnap.docs.isNotEmpty && (gangSnap.docs.first.data()['isBlocked'] == true)) {
            signOut();
            return;
          }
        }

        _currentUser = AppUser.fromMap(userData);
        // Register device for notifications
        NotificationService.registerDevice(uid);
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      _error = e.toString();
    }
  }

  Future<String?> signIn(String usernameOrEmail, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      String loginEmail = usernameOrEmail.trim();

      // If it doesn't look like an email, assume it's a username (name) and look up the email
      if (!loginEmail.contains('@')) {
        final querySnap = await _firestore
            .collection('users')
            .where('name', isEqualTo: loginEmail)
            .limit(1)
            .get();

        if (querySnap.docs.isEmpty) {
          _isLoading = false;
          notifyListeners();
          return 'Username not found.';
        }
        
        final data = querySnap.docs.first.data();
        if (data['isBlocked'] == true) {
          _isLoading = false;
          notifyListeners();
          return 'This account has been blocked by an administrator.';
        }
        loginEmail = data['email'] ?? '';
      } else {
        // If it is an email, check if blocked first
        final querySnap = await _firestore
            .collection('users')
            .where('email', isEqualTo: loginEmail)
            .limit(1)
            .get();
        if (querySnap.docs.isNotEmpty && querySnap.docs.first.data()['isBlocked'] == true) {
          _isLoading = false;
          notifyListeners();
          return 'This account has been blocked by an administrator.';
        }
      }

      await _auth.signInWithEmailAndPassword(email: loginEmail, password: password);
      
      // Double check Firestore after login for safety
      final userDoc = await _firestore.collection('users').doc(_auth.currentUser?.uid).get();
      if (!userDoc.exists || userDoc.data()?['isBlocked'] == true) {
        await signOut();
        _isLoading = false;
        notifyListeners();
        return 'This account is restricted or does not exist.';
      }

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> signOut() async {
    if (_currentUser != null) {
      await NotificationService.clearToken(_currentUser!.uid);
    }
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }


  Future<String?> adminCreateUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? agencyId,
    String? gangId,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('adminCreateUser');
      
      final response = await callable.call({
        'email': email,
        'password': password,
        'name': name,
        'role': role.name,
        'agencyId': agencyId,
        'gangId': gangId,
      });

      debugPrint('Cloud function response: ${response.data}');
      return null;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Cloud function error: ${e.code} - ${e.message}');
      return e.message;
    } catch (e) {
      debugPrint('Admin create user error: $e');
      return e.toString();
    }
  }
}

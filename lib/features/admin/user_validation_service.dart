import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserValidationService {
  UserValidationService._();
  static final UserValidationService instance = UserValidationService._();

  Timer? _timer;
  final _auth = FirebaseAuth.instance;

  void startPeriodicCheck({Duration interval = const Duration(seconds: 30)}) {
    stopPeriodicCheck();
    _timer = Timer.periodic(interval, (_) => _validateCurrentUser());
  }

  void stopPeriodicCheck() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _validateCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!doc.exists) {
        await _auth.signOut();
        _onUserRemoved?.call();
      }
    } catch (_) {
      // Silently fail - don't sign out on network errors
    }
  }

  Future<bool> isUserValid() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      return doc.exists;
    } catch (_) {
      return true;
    }
  }

  void Function()? _onUserRemoved;

  void setOnUserRemoved(void Function() callback) {
    _onUserRemoved = callback;
  }
}

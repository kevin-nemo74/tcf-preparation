import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserStatusService {
  UserStatusService._();
  static final UserStatusService instance = UserStatusService._();

  final _auth = FirebaseAuth.instance;
  bool? _cachedIsSuspended;

  bool get isSuspended => _cachedIsSuspended ?? false;

  Future<bool> checkIsSuspended() async {
    final user = _auth.currentUser;
    if (user == null) {
      _cachedIsSuspended = false;
      return false;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        _cachedIsSuspended = true;
        return true;
      }

      final role = doc.data()?['role']?.toString();
      _cachedIsSuspended = role == 'suspended';
      return _cachedIsSuspended!;
    } catch (_) {
      return false;
    }
  }

  void clearCache() {
    _cachedIsSuspended = null;
  }
}

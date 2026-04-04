import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum SubscriptionPlan {
  none('Aucun'),
  essential('Essentiel - 15 jours / 15\$', 15),
  standard('Standard - 30 jours / 25\$', 30);

  final String label;
  final int days;
  const SubscriptionPlan(this.label, [this.days = 0]);
}

enum UserStatus {
  active('Actif'),
  expired('Expire'),
  suspended('Suspendu');

  final String label;
  const UserStatus(this.label);
}

class AdminUser {
  final String uid;
  final String username;
  final String email;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final SubscriptionPlan subscription;
  final DateTime? subscriptionStartDate;
  final int? attemptsCount;
  final int? bestScore;

  AdminUser({
    required this.uid,
    required this.username,
    required this.email,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
    this.subscription = SubscriptionPlan.none,
    this.subscriptionStartDate,
    this.attemptsCount,
    this.bestScore,
  });

  factory AdminUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AdminUser(
      uid: doc.id,
      username: data['username']?.toString() ?? 'Unknown',
      email: data['email']?.toString() ?? '',
      role: data['role']?.toString() ?? 'user',
      createdAt: _toDate(data['createdAt']) ?? DateTime.now(),
      lastLoginAt: _toDate(data['lastLoginAt']),
      subscription: _parseSubscription(data),
      subscriptionStartDate: _toDate(data['subscriptionStartDate']),
      attemptsCount: _toInt(data, [
        'attemptsCount',
        'attempts',
        'totalAttempts',
      ]),
      bestScore: _toInt(data, ['bestScore', 'highestScore']),
    );
  }

  DateTime? get subscriptionEndDate {
    if (subscription == SubscriptionPlan.none ||
        subscriptionStartDate == null) {
      return null;
    }
    return subscriptionStartDate!.add(Duration(days: subscription.days));
  }

  int? get daysRemaining {
    if (subscriptionEndDate == null) return null;
    final remaining = subscriptionEndDate!.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  UserStatus get status {
    if (role == 'admin') return UserStatus.active;
    if (role == 'suspended') return UserStatus.suspended;
    if (subscriptionEndDate == null) return UserStatus.active;
    if (DateTime.now().isAfter(subscriptionEndDate!)) return UserStatus.expired;
    return UserStatus.active;
  }

  bool get isAdmin => role == 'admin';
  bool get isSuspended => role == 'suspended';

  static SubscriptionPlan _parseSubscription(Map<String, dynamic> data) {
    final sub = data['subscription']?.toString();
    if (sub == null) return SubscriptionPlan.none;
    switch (sub.toLowerCase()) {
      case 'essential':
        return SubscriptionPlan.essential;
      case 'standard':
        return SubscriptionPlan.standard;
      default:
        return SubscriptionPlan.none;
    }
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static int? _toInt(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
    }
    return null;
  }
}

class AdminRepository {
  AdminRepository._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Stream<List<AdminUser>> streamAllUsers() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => AdminUser.fromFirestore(doc)).toList(),
        );
  }

  static Future<List<AdminUser>> getAllUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs.map((doc) => AdminUser.fromFirestore(doc)).toList();
  }

  static Future<AdminUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AdminUser.fromFirestore(doc);
  }

  static Future<List<AdminUser>> searchUsers(String query) async {
    final allUsers = await getAllUsers();
    final lowerQuery = query.toLowerCase();
    return allUsers.where((user) {
      return user.username.toLowerCase().contains(lowerQuery) ||
          user.email.toLowerCase().contains(lowerQuery) ||
          user.uid.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static Future<void> createUser({
    required String username,
    required String email,
    required String password,
    SubscriptionPlan subscription = SubscriptionPlan.none,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = cred.user!.uid;

    await cred.user!.updateDisplayName(username.trim());

    final userData = <String, dynamic>{
      'username': username.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'role': 'user',
    };

    if (subscription != SubscriptionPlan.none) {
      userData['subscription'] = subscription.name;
      userData['subscriptionStartDate'] = FieldValue.serverTimestamp();
    }

    await _db
        .collection('users')
        .doc(uid)
        .set(userData, SetOptions(merge: true));
  }

  static Future<void> updateUserSubscription({
    required String uid,
    required SubscriptionPlan subscription,
  }) async {
    final updateData = <String, dynamic>{
      'subscription': subscription == SubscriptionPlan.none
          ? null
          : subscription.name,
    };

    if (subscription != SubscriptionPlan.none) {
      updateData['subscriptionStartDate'] = FieldValue.serverTimestamp();
    } else {
      updateData['subscriptionStartDate'] = null;
    }

    await _db.collection('users').doc(uid).update(updateData);
  }

  static Future<void> updateUserRole({
    required String uid,
    required String role,
  }) async {
    await _db.collection('users').doc(uid).update({'role': role});
  }

  static Future<void> suspendUser(String uid) async {
    await _db.collection('users').doc(uid).update({'role': 'suspended'});
  }

  static Future<void> reactivateUser(String uid) async {
    await _db.collection('users').doc(uid).update({'role': 'user'});
  }

  static Future<bool> removeUser(String uid) async {
    try {
      await _db.collection('users').doc(uid).delete();
      final currentUid = _auth.currentUser?.uid;
      if (currentUid == uid) {
        await _auth.signOut();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> forceLogoutUser(String uid) async {
    await _db.collection('users').doc(uid).update({
      'forceLogout': FieldValue.serverTimestamp(),
    });
  }

  static Future<bool> isCurrentUserAdmin() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;
    final doc = await _db.collection('users').doc(currentUser.uid).get();
    final role = doc.data()?['role']?.toString();
    return role == 'admin';
  }
}

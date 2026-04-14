import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ee_attempt.dart';
import '../models/ee_evaluation.dart';

class EEProgressService {
  EEProgressService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String? get currentUid {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } on FirebaseException {
      return null;
    } catch (_) {
      return null;
    }
  }

  static DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  static CollectionReference<Map<String, dynamic>> _eeAttemptsCol(String uid) =>
      _userDoc(uid).collection('eeAttempts');

  static Future<void> saveAttempt({
    required String uid,
    required String combinaisonId,
    required String monthId,
    required double scoreOutOf20,
    required int tache1WordCount,
    required int tache2WordCount,
    required int tache3WordCount,
    double? tache1Score,
    double? tache2Score,
    double? tache3Score,
    String? feedback,
    String? tache1Feedback,
    String? tache2Feedback,
    String? tache3Feedback,
    String? corrections,
    String? suggestions,
  }) async {
    final attemptRef = _eeAttemptsCol(uid).doc();
    final attempt = EEAttempt(
      id: attemptRef.id,
      combinaisonId: combinaisonId,
      monthId: monthId,
      scoreOutOf20: scoreOutOf20,
      nclcLevel: calculateNCLCFromScore(scoreOutOf20),
      cefrLevel: calculateCEFRFromScore(scoreOutOf20),
      tache1WordCount: tache1WordCount,
      tache2WordCount: tache2WordCount,
      tache3WordCount: tache3WordCount,
      tache1Score: tache1Score,
      tache2Score: tache2Score,
      tache3Score: tache3Score,
      feedback: feedback,
      tache1Feedback: tache1Feedback,
      tache2Feedback: tache2Feedback,
      tache3Feedback: tache3Feedback,
      corrections: corrections,
      suggestions: suggestions,
      createdAt: DateTime.now(),
    );

    await attemptRef.set(attempt.toMap());
  }

  static Stream<List<EEAttempt>> streamAttempts(String uid) {
    return _eeAttemptsCol(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EEAttempt.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  static Future<List<EEAttempt>> getAttempts(String uid) async {
    final snapshot = await _eeAttemptsCol(
      uid,
    ).orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => EEAttempt.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  static Stream<EEProgressSummary> streamProgressSummary(String uid) {
    return streamAttempts(
      uid,
    ).map((attempts) => EEProgressSummary.fromAttempts(attempts));
  }

  static Future<EEProgressSummary> getProgressSummary(String uid) async {
    final attempts = await getAttempts(uid);
    return EEProgressSummary.fromAttempts(attempts);
  }

  static Future<EEAttempt?> getBestAttempt(String uid) async {
    final attempts = await getAttempts(uid);
    if (attempts.isEmpty) return null;
    return attempts.reduce((a, b) => a.scoreOutOf20 > b.scoreOutOf20 ? a : b);
  }

  static Future<EEAttempt?> getLastAttempt(String uid) async {
    final attempts = await getAttempts(uid);
    if (attempts.isEmpty) return null;
    return attempts.first;
  }

  static Future<List<EEAttempt>> getAttemptsByCombinaison(
    String uid,
    String combinaisonId,
  ) async {
    final snapshot = await _eeAttemptsCol(uid)
        .where('combinaisonId', isEqualTo: combinaisonId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => EEAttempt.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  static Future<int> getTotalAttemptsCount(String uid) async {
    final snapshot = await _eeAttemptsCol(uid).get();
    return snapshot.size;
  }
}


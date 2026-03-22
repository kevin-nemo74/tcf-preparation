import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProgressSummary {
  final int attemptsCount;
  final int bestScore;
  final int lastScore;
  final DateTime? lastAttemptAt;
  final double averageScore;
  final int currentStreak;
  final int bestStreak;
  final int weeklyAttempts;
  final double weeklyAverage;
  final bool onboardingDone;

  const UserProgressSummary({
    required this.attemptsCount,
    required this.bestScore,
    required this.lastScore,
    required this.lastAttemptAt,
    required this.averageScore,
    required this.currentStreak,
    required this.bestStreak,
    required this.weeklyAttempts,
    required this.weeklyAverage,
    required this.onboardingDone,
  });

  factory UserProgressSummary.empty() {
    return const UserProgressSummary(
      attemptsCount: 0,
      bestScore: 0,
      lastScore: 0,
      lastAttemptAt: null,
      averageScore: 0,
      currentStreak: 0,
      bestStreak: 0,
      weeklyAttempts: 0,
      weeklyAverage: 0,
      onboardingDone: false,
    );
  }

  factory UserProgressSummary.fromMap(Map<String, dynamic> map) {
    final lastAttempt = map['lastAttemptAt'];
    return UserProgressSummary(
      attemptsCount: _asInt(map['attemptsCount']),
      bestScore: _asInt(map['bestScore']),
      lastScore: _asInt(map['lastScore']),
      lastAttemptAt: lastAttempt is Timestamp ? lastAttempt.toDate() : null,
      averageScore: _asDouble(map['averageScore']),
      currentStreak: _asInt(map['currentStreak']),
      bestStreak: _asInt(map['bestStreak']),
      weeklyAttempts: _asInt(map['weeklyAttempts']),
      weeklyAverage: _asDouble(map['weeklyAverage']),
      onboardingDone: map['onboardingDone'] == true,
    );
  }
}

class StudyTask {
  final String id;
  final String title;
  final String type;
  final bool done;

  const StudyTask({
    required this.id,
    required this.title,
    required this.type,
    required this.done,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'type': type,
        'done': done,
      };

  factory StudyTask.fromMap(Map<String, dynamic> map) => StudyTask(
        id: (map['id'] ?? '').toString(),
        title: (map['title'] ?? '').toString(),
        type: (map['type'] ?? '').toString(),
        done: map['done'] == true,
      );
}

class StudyPlan {
  final int targetScore;
  final String targetLevel;
  final DateTime targetDate;
  final int weeklyCadence;
  final List<StudyTask> todayTasks;

  const StudyPlan({
    required this.targetScore,
    required this.targetLevel,
    required this.targetDate,
    required this.weeklyCadence,
    required this.todayTasks,
  });

  factory StudyPlan.fromMap(Map<String, dynamic> map) {
    final targetDate = map['targetDate'];
    final tasks = (map['todayTasks'] as List?)
            ?.whereType<Map>()
            .map((e) => StudyTask.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        const <StudyTask>[];
    return StudyPlan(
      targetScore: _asInt(map['targetScore']),
      targetLevel: (map['targetLevel'] ?? 'NCLC 7').toString(),
      targetDate: targetDate is Timestamp ? targetDate.toDate() : DateTime.now(),
      weeklyCadence: _asInt(map['weeklyCadence']),
      todayTasks: tasks,
    );
  }

  Map<String, dynamic> toMap() => {
        'targetScore': targetScore,
        'targetLevel': targetLevel,
        'targetDate': Timestamp.fromDate(targetDate),
        'weeklyCadence': weeklyCadence,
        'todayTasks': todayTasks.map((e) => e.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

class ProgressRepository {
  ProgressRepository._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Safe when Firebase is not initialized (e.g. widget tests).
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

  static CollectionReference<Map<String, dynamic>> _attemptsCol(String uid) =>
      _userDoc(uid).collection('attempts');

  static CollectionReference<Map<String, dynamic>> _reviewQueueCol(String uid) =>
      _userDoc(uid).collection('reviewQueue');

  static Stream<UserProgressSummary> streamSummary(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return UserProgressSummary.empty();
      return UserProgressSummary.fromMap(data);
    });
  }

  static Stream<StudyPlan?> streamStudyPlan(String uid) {
    return _userDoc(uid).collection('meta').doc('studyPlan').snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return null;
      return StudyPlan.fromMap(data);
    });
  }

  static Future<void> saveStudyPlan(String uid, StudyPlan plan) async {
    await _userDoc(uid).collection('meta').doc('studyPlan').set(
          plan.toMap(),
          SetOptions(merge: true),
        );
  }

  static Future<void> toggleTask(String uid, String taskId) async {
    final ref = _userDoc(uid).collection('meta').doc('studyPlan');
    final snap = await ref.get();
    final data = snap.data();
    if (data == null) return;
    final plan = StudyPlan.fromMap(data);
    final updatedTasks = plan.todayTasks
        .map((t) => t.id == taskId
            ? StudyTask(id: t.id, title: t.title, type: t.type, done: !t.done)
            : t)
        .toList();
    await ref.set(
      {
        'todayTasks': updatedTasks.map((e) => e.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static Future<void> recordAttempt({
    required String uid,
    required String testId,
    required String testTitle,
    required String moduleType,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    required Set<String> flaggedQuestionIds,
    required Map<String, String> userAnswers,
    required Map<String, String> correctAnswersByQuestion,
  }) async {
    final now = DateTime.now();
    final userRef = _userDoc(uid);
    final attemptRef = _attemptsCol(uid).doc();
    await attemptRef.set({
      'testId': testId,
      'testTitle': testTitle,
      'moduleType': moduleType,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': totalQuestions - correctAnswers,
      'flaggedQuestionIds': flaggedQuestionIds.toList(),
      'userAnswers': userAnswers,
      'correctAnswersByQuestion': correctAnswersByQuestion,
      'createdAt': FieldValue.serverTimestamp(),
      'createdAtDay': DateTime(now.year, now.month, now.day).toIso8601String(),
    });

    await _db.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      final data = userSnap.data() ?? <String, dynamic>{};
      final attemptsCount = _asInt(data['attemptsCount']);
      final oldBest = _asInt(data['bestScore']);
      final oldAvg = _asDouble(data['averageScore']);
      final oldStreak = _asInt(data['currentStreak']);
      final bestStreak = _asInt(data['bestStreak']);
      final lastAttemptTs = data['lastAttemptAt'];
      DateTime? lastAttemptAt;
      if (lastAttemptTs is Timestamp) lastAttemptAt = lastAttemptTs.toDate();

      final nextCount = attemptsCount + 1;
      final nextAvg = ((oldAvg * attemptsCount) + score) / nextCount;
      final nextBest = score > oldBest ? score : oldBest;
      final nextStreak = _computeStreak(lastAttemptAt, oldStreak, now);
      final nextBestStreak = nextStreak > bestStreak ? nextStreak : bestStreak;

      tx.set(
        userRef,
        {
          'attemptsCount': nextCount,
          'bestScore': nextBest,
          'lastScore': score,
          'lastAttemptAt': FieldValue.serverTimestamp(),
          'averageScore': nextAvg,
          'currentStreak': nextStreak,
          'bestStreak': nextBestStreak,
          'weeklyAttempts': FieldValue.increment(1),
          'weeklyScoreTotal': FieldValue.increment(score),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });

    final userSnap = await userRef.get();
    final updated = userSnap.data() ?? <String, dynamic>{};
    final weeklyAttempts = _asInt(updated['weeklyAttempts']);
    final weeklyScoreTotal = _asInt(updated['weeklyScoreTotal']);
    final weeklyAverage = weeklyAttempts == 0 ? 0 : weeklyScoreTotal / weeklyAttempts;
    await userRef.set({'weeklyAverage': weeklyAverage}, SetOptions(merge: true));

    await _storeReviewQueue(
      uid: uid,
      moduleType: moduleType,
      userAnswers: userAnswers,
      correctAnswersByQuestion: correctAnswersByQuestion,
      flaggedQuestionIds: flaggedQuestionIds,
    );
  }

  static Future<void> _storeReviewQueue({
    required String uid,
    required String moduleType,
    required Map<String, String> userAnswers,
    required Map<String, String> correctAnswersByQuestion,
    required Set<String> flaggedQuestionIds,
  }) async {
    final ids = <String>{};
    for (final entry in correctAnswersByQuestion.entries) {
      final user = userAnswers[entry.key];
      if (user != entry.value) ids.add(entry.key);
    }
    ids.addAll(flaggedQuestionIds);

    for (final id in ids) {
      await _reviewQueueCol(uid).doc('$moduleType:$id').set(
        {
          'questionId': id,
          'moduleType': moduleType,
          'needsReview': true,
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
  }

  static Stream<List<Map<String, dynamic>>> streamRecentAttempts(String uid, {int limit = 12}) {
    return _attemptsCol(uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((e) => e.data()).toList());
  }

  static Stream<List<Map<String, dynamic>>> streamReviewQueue(String uid, {int limit = 20}) {
    return _reviewQueueCol(uid)
        .where('needsReview', isEqualTo: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((e) => e.data()).toList());
  }

  static Future<bool> isOnboardingDone() async {
    final uid = currentUid;
    if (uid == null) return true;
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getBool('onboarding_done_$uid');
    if (local == true) return true;
    final snap = await _userDoc(uid).get();
    final remote = snap.data()?['onboardingDone'] == true;
    if (remote) {
      await prefs.setBool('onboarding_done_$uid', true);
    }
    return remote;
  }

  static Future<void> setOnboardingDone() async {
    final uid = currentUid;
    if (uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done_$uid', true);
    await _userDoc(uid).set({'onboardingDone': true}, SetOptions(merge: true));
  }

  static int _computeStreak(DateTime? lastAttempt, int oldStreak, DateTime now) {
    if (lastAttempt == null) return 1;
    final d1 = DateTime(lastAttempt.year, lastAttempt.month, lastAttempt.day);
    final d2 = DateTime(now.year, now.month, now.day);
    final diff = d2.difference(d1).inDays;
    if (diff == 0) return oldStreak;
    if (diff == 1) return oldStreak + 1;
    return 1;
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

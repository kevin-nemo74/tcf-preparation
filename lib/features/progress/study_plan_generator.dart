import 'package:cloud_firestore/cloud_firestore.dart';

import 'progress_repository.dart';

class StudyPlanGenerator {
  StudyPlanGenerator._();

  static StudyPlan generate({
    required int targetScore,
    required String targetLevel,
    required DateTime targetDate,
    required int weeklyCadence,
    required List<Map<String, dynamic>> recentAttempts,
    required int pendingReviewCount,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final weakModule = _weakestModule(recentAttempts);
    final accelerating = _daysUntilTarget(today, targetDate) <= 21;
    final scoreTrend = recentTrend(recentAttempts);
    final needsRecovery = scoreTrend == _Trend.down;
    final hasRecentData = recentAttempts.isNotEmpty;
    final taskSeed = _dateKey(today);
    final tasks = <StudyTask>[
      StudyTask(
        id: '${taskSeed}_focus_$weakModule',
        title: weakModule == 'CO'
            ? 'Complete one oral practice set'
            : 'Complete one comprehension set',
        type: weakModule,
        done: false,
      ),
    ];
    if (pendingReviewCount > 0) {
      tasks.add(
        StudyTask(
          id: '${taskSeed}_review',
          title: 'Review $pendingReviewCount flagged or missed question(s)',
          type: 'REVIEW',
          done: false,
        ),
      );
    }
    tasks.add(
      StudyTask(
        id: '${taskSeed}_timed',
        title: accelerating || weeklyCadence >= 5
            ? 'Take one timed mixed mini-test'
            : 'Take one untimed mixed mini-test',
        type: 'MIXED',
        done: false,
      ),
    );
    if (!hasRecentData) {
      tasks.add(
        StudyTask(
          id: '${taskSeed}_baseline',
          title: 'Finish a baseline set and record your starting score',
          type: 'BASELINE',
          done: false,
        ),
      );
    } else if (needsRecovery) {
      tasks.add(
        StudyTask(
          id: '${taskSeed}_recovery',
          title: 'Redo one recent weak module to recover your score trend',
          type: weakModule,
          done: false,
        ),
      );
    } else if (accelerating) {
      tasks.add(
        StudyTask(
          id: '${taskSeed}_deadline',
          title: 'Add one extra exam-paced session before your target date',
          type: 'MIXED',
          done: false,
        ),
      );
    }
    return StudyPlan(
      targetScore: targetScore,
      targetLevel: targetLevel,
      targetDate: targetDate,
      weeklyCadence: weeklyCadence,
      planDateKey: taskSeed,
      todayTasks: tasks,
    );
  }

  static String _weakestModule(List<Map<String, dynamic>> attempts) {
    if (attempts.isEmpty) return 'CE';
    double ceTotal = 0;
    int ceCount = 0;
    double coTotal = 0;
    int coCount = 0;
    for (final a in attempts) {
      final type = (a['moduleType'] ?? '').toString();
      final score = _asDouble(a['score']);
      if (type == 'CO') {
        coTotal += score;
        coCount++;
      } else {
        ceTotal += score;
        ceCount++;
      }
    }
    final ceAvg = ceCount == 0 ? 0 : ceTotal / ceCount;
    final coAvg = coCount == 0 ? 0 : coTotal / coCount;
    return coAvg < ceAvg ? 'CO' : 'CE';
  }

  static bool needsRefresh(StudyPlan plan, {DateTime? now}) {
    return plan.planDateKey != _dateKey(now ?? DateTime.now());
  }

  static int daysUntilTarget(DateTime now, DateTime targetDate) =>
      _daysUntilTarget(now, targetDate);

  static _Trend recentTrend(List<Map<String, dynamic>> attempts) {
    if (attempts.length < 2) return _Trend.flat;
    final sorted = [...attempts]
      ..sort((a, b) => _attemptTime(b).compareTo(_attemptTime(a)));
    final latest = sorted.take(3).map((a) => _asDouble(a['score'])).toList();
    final earlier = sorted.skip(3).take(3).map((a) => _asDouble(a['score'])).toList();
    if (latest.isEmpty || earlier.isEmpty) return _Trend.flat;
    final latestAvg = latest.reduce((a, b) => a + b) / latest.length;
    final earlierAvg = earlier.reduce((a, b) => a + b) / earlier.length;
    if (latestAvg >= earlierAvg + 15) return _Trend.up;
    if (latestAvg <= earlierAvg - 15) return _Trend.down;
    return _Trend.flat;
  }
}

enum _Trend { up, flat, down }

DateTime _attemptTime(Map<String, dynamic> attempt) {
  final createdAt = attempt['createdAt'];
  if (createdAt is Timestamp) return createdAt.toDate();
  if (createdAt is DateTime) return createdAt;
  if (createdAt is String) return DateTime.tryParse(createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
  return DateTime.fromMillisecondsSinceEpoch(0);
}

int _daysUntilTarget(DateTime now, DateTime targetDate) {
  final start = DateTime(now.year, now.month, now.day);
  final end = DateTime(targetDate.year, targetDate.month, targetDate.day);
  return end.difference(start).inDays;
}

String _dateKey(DateTime value) =>
    DateTime(value.year, value.month, value.day).toIso8601String().split('T').first;

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

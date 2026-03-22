import 'progress_repository.dart';

class StudyPlanGenerator {
  StudyPlanGenerator._();

  static StudyPlan generate({
    required int targetScore,
    required String targetLevel,
    required DateTime targetDate,
    required int weeklyCadence,
    required List<Map<String, dynamic>> recentAttempts,
  }) {
    final weakModule = _weakestModule(recentAttempts);
    final tasks = <StudyTask>[
      StudyTask(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}_1',
        title: weakModule == 'CO' ? 'Do one oral practice set' : 'Do one comprehension set',
        type: weakModule,
        done: false,
      ),
      StudyTask(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}_2',
        title: 'Review missed questions',
        type: 'REVIEW',
        done: false,
      ),
      StudyTask(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}_3',
        title: 'Take one timed mini-test',
        type: 'MIXED',
        done: false,
      ),
    ];
    return StudyPlan(
      targetScore: targetScore,
      targetLevel: targetLevel,
      targetDate: targetDate,
      weeklyCadence: weeklyCadence,
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
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

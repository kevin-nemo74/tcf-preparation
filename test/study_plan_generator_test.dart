import 'package:flutter_test/flutter_test.dart';
import 'package:tcf_canada_preparation/features/progress/study_plan_generator.dart';

void main() {
  test('generates plan with three tasks', () {
    final plan = StudyPlanGenerator.generate(
      targetScore: 520,
      targetLevel: 'NCLC 8',
      targetDate: DateTime(2026, 12, 1),
      weeklyCadence: 5,
      recentAttempts: const [],
    );

    expect(plan.targetScore, 520);
    expect(plan.todayTasks.length, 3);
  });
}

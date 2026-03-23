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
      pendingReviewCount: 0,
      now: DateTime(2026, 3, 23),
    );

    expect(plan.targetScore, 520);
    expect(plan.planDateKey, '2026-03-23');
    expect(plan.todayTasks.length, greaterThanOrEqualTo(3));
    expect(plan.todayTasks.any((task) => task.type == 'BASELINE'), isTrue);
  });

  test('adds review and recovery tasks when trend is dropping', () {
    final plan = StudyPlanGenerator.generate(
      targetScore: 520,
      targetLevel: 'NCLC 8',
      targetDate: DateTime(2026, 4, 1),
      weeklyCadence: 5,
      pendingReviewCount: 6,
      now: DateTime(2026, 3, 23),
      recentAttempts: [
        {'moduleType': 'CE', 'score': 410, 'createdAt': '2026-03-22T08:00:00.000'},
        {'moduleType': 'CO', 'score': 405, 'createdAt': '2026-03-21T08:00:00.000'},
        {'moduleType': 'CE', 'score': 420, 'createdAt': '2026-03-20T08:00:00.000'},
        {'moduleType': 'CE', 'score': 520, 'createdAt': '2026-03-19T08:00:00.000'},
        {'moduleType': 'CO', 'score': 530, 'createdAt': '2026-03-18T08:00:00.000'},
        {'moduleType': 'CE', 'score': 540, 'createdAt': '2026-03-17T08:00:00.000'},
      ],
    );

    expect(
      plan.todayTasks.any((task) => task.type == 'REVIEW'),
      isTrue,
    );
    expect(
      plan.todayTasks.any((task) => task.type == 'REVIEW_SPACED'),
      isTrue,
    );
    expect(
      plan.todayTasks.any((task) => task.title.contains('recover')),
      isTrue,
    );
  });

  test('needsRefresh returns true when plan date is not today', () {
    final stalePlan = StudyPlanGenerator.generate(
      targetScore: 500,
      targetLevel: 'NCLC 7',
      targetDate: DateTime(2026, 6, 1),
      weeklyCadence: 4,
      recentAttempts: const [],
      pendingReviewCount: 0,
      now: DateTime(2026, 3, 20),
    );

    expect(
      StudyPlanGenerator.needsRefresh(
        stalePlan,
        now: DateTime(2026, 3, 23),
      ),
      isTrue,
    );
  });
}

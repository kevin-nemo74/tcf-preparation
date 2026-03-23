import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

class AppAnalytics {
  AppAnalytics._();

  static FirebaseAnalytics? _instance;

  static FirebaseAnalytics? get instance {
    try {
      _instance ??= FirebaseAnalytics.instance;
      return _instance;
    } on FirebaseException {
      return null;
    }
  }

  static Future<void> logOnboardingCompleted() {
    return _log('onboarding_completed');
  }

  static Future<void> logTestStarted({
    required String moduleType,
    required String testId,
  }) {
    return _log(
      'test_started',
      parameters: {
        'module_type': moduleType,
        'test_id': testId,
      },
    );
  }

  static Future<void> logTestSubmitted({
    required String moduleType,
    required String testId,
    required int score,
  }) {
    return _log(
      'test_submitted',
      parameters: {
        'module_type': moduleType,
        'test_id': testId,
        'score': score,
      },
    );
  }

  static Future<void> logReviewQueueCompleted() {
    return _log('review_queue_item_completed');
  }

  static Future<void> logStudyPlanTaskToggled({required bool done}) {
    return _log(
      'study_plan_task_toggled',
      parameters: {'done': done},
    );
  }

  static Future<void> _log(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    final analytics = instance;
    if (analytics == null) return;
    await analytics.logEvent(name: name, parameters: parameters);
  }
}

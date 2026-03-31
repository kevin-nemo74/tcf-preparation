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

  static Future<void> logLandingCtaClicked() {
    return _log('landing_cta_clicked');
  }

  static Future<void> logSignupStarted() {
    return _log('signup_started');
  }

  static Future<void> logSignupSuccess() {
    return _log('signup_success');
  }

  static Future<void> logLoginSuccess() {
    return _log('login_success');
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

  static Future<void> logReviewCompleted({
    required String moduleType,
    required String testId,
  }) {
    return _log(
      'review_completed',
      parameters: {
        'module_type': moduleType,
        'test_id': testId,
      },
    );
  }

  static Future<void> logStudyPlanTaskToggled({required bool done}) {
    return _log(
      'study_plan_task_toggled',
      parameters: {'done': done},
    );
  }

  static Future<void> logStudyPlanCreated({
    required int targetScore,
    required String targetLevel,
  }) {
    return _log(
      'study_plan_created',
      parameters: {
        'target_score': targetScore,
        'target_level': targetLevel,
      },
    );
  }

  static Future<void> logPdfOpened({required String pdfId}) {
    return _log('pdf_opened', parameters: {'pdf_id': pdfId});
  }

  static Future<void> logNonFatalTestEvent() {
    return _log('crashlytics_non_fatal_test');
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

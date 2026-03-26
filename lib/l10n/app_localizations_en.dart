// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MapleTcf';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginAccessTests => 'Login to access all tests';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get forgotPasswordCta => 'Forgot password?';

  @override
  String get loginCta => 'Login';

  @override
  String get noAccount => 'No account?';

  @override
  String get createOne => 'Create one';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle =>
      'Register to unlock all tests and save progress';

  @override
  String get usernameLabel => 'Username';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get createAccountCta => 'Create account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordSubtitle =>
      'Enter your email and we will send you a reset link.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start';

  @override
  String get onboardingHowScoringTitle => 'How scoring works';

  @override
  String get onboardingHowScoringBody =>
      'Each test is scored on a 699-point scale and mapped to NCLC bands.';

  @override
  String get onboardingStudyRhythmTitle => 'Study rhythm';

  @override
  String get onboardingStudyRhythmBody =>
      'Use daily tasks from your study plan and keep your streak alive.';

  @override
  String get onboardingProgressTitle => 'Track your progress';

  @override
  String get onboardingProgressBody =>
      'See best score, recent attempts, weak areas, and review queue.';
}

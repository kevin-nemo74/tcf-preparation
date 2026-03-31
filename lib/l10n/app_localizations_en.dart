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

  @override
  String get landingBrandName => 'MapleTcf';

  @override
  String get landingHeroTitle => 'MapleTcf';

  @override
  String get landingHeroSubtitle =>
      'Specialized platform for TCF Canada preparation. Train with realistic tests and updated topics.';

  @override
  String get landingServicesTitle => 'Services';

  @override
  String get landingPricingTitle => 'Pricing';

  @override
  String get landingContactTitle => 'Contact';

  @override
  String get landingCtaLogin => 'Sign in';

  @override
  String get landingCtaLoginShort => 'Sign in';

  @override
  String get landingServicesSummary => 'What MapleTcf currently offers';

  @override
  String get landingPricingSummary => 'Preparation plans';

  @override
  String get landingContactSummary => 'Talk with our team';

  @override
  String get landingTagTcfCanada => 'TCF Canada';

  @override
  String get landingTagPreparation => 'Preparation';

  @override
  String get landingTagWebPlatform => 'Web platform';

  @override
  String get landingResumeTitle => 'Quick overview';

  @override
  String get landingPlanEssential => 'Essential access - 15 days';

  @override
  String get landingPlanStandard => 'Standard access - 30 days';

  @override
  String landingPlanPriceLabel(Object price) {
    return 'Price: $price';
  }

  @override
  String get landingCheckWrittenTests =>
      '40 written tests adapted to TCF Canada format';

  @override
  String get landingCheckOralTests =>
      '40 oral tests to strengthen your speaking';

  @override
  String get landingCheckPdfResources =>
      'PDF books for oral and written expression';

  @override
  String get landingCheckUpdatedTopics => 'Regularly updated topics';

  @override
  String get landingResumeLineEssential => 'Essential: 15 days - \$30';

  @override
  String get landingResumeLineStandard => 'Standard: 30 days - \$55';

  @override
  String get landingResumeLineSupport => 'Direct contact by email and phone';

  @override
  String get landingEmailLabel => 'Email: hello@mapletcf.com';

  @override
  String get landingPhoneLabel => 'Phone: +1 514 555 0147';

  @override
  String get landingSupportLabel => 'Support: Monday to Friday - 9:00 to 18:00';

  @override
  String get ceStartTestCta => 'Start test';

  @override
  String get ceHeaderAdviceNeedsPractice =>
      'Adaptive: focus on recent weak points.';

  @override
  String get ceHeaderAdviceEstablishBaseline =>
      'Adaptive: continue exercises to establish a baseline.';

  @override
  String get ceLoadError => 'Failed to load CE tests:';

  @override
  String get ceEmptyState => 'No test available';

  @override
  String get coLoadError => 'Failed to load CO tests:';

  @override
  String get coEmptyState => 'No oral test available';

  @override
  String get ceResultTitle => 'Test result';

  @override
  String get ceResultYourScore => 'Your score';

  @override
  String get ceResultBelowNclc4 => 'Below NCLC 4';

  @override
  String get ceReviewCta => 'Review answers';

  @override
  String get ceQuestionGridTooltip => 'Question grid';

  @override
  String get ceFlagTooltipAdd => 'Flag';

  @override
  String get ceFlagTooltipRemove => 'Remove flag';

  @override
  String get ceImageLoadError => 'Failed to load image';

  @override
  String get cePrevQuestion => 'Previous';

  @override
  String get ceNextQuestion => 'Next';

  @override
  String get ceSubmitTest => 'Submit';
}

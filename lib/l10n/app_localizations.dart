import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MapleTcf'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginAccessTests.
  ///
  /// In en, this message translates to:
  /// **'Login to access all tests'**
  String get loginAccessTests;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @forgotPasswordCta.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordCta;

  /// No description provided for @loginCta.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginCta;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account?'**
  String get noAccount;

  /// No description provided for @createOne.
  ///
  /// In en, this message translates to:
  /// **'Create one'**
  String get createOne;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register to unlock all tests and save progress'**
  String get registerSubtitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @createAccountCta.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountCta;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a reset link.'**
  String get resetPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStart;

  /// No description provided for @onboardingHowScoringTitle.
  ///
  /// In en, this message translates to:
  /// **'How scoring works'**
  String get onboardingHowScoringTitle;

  /// No description provided for @onboardingHowScoringBody.
  ///
  /// In en, this message translates to:
  /// **'Each test is scored on a 699-point scale and mapped to NCLC bands.'**
  String get onboardingHowScoringBody;

  /// No description provided for @onboardingStudyRhythmTitle.
  ///
  /// In en, this message translates to:
  /// **'Study rhythm'**
  String get onboardingStudyRhythmTitle;

  /// No description provided for @onboardingStudyRhythmBody.
  ///
  /// In en, this message translates to:
  /// **'Use daily tasks from your study plan and keep your streak alive.'**
  String get onboardingStudyRhythmBody;

  /// No description provided for @onboardingProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get onboardingProgressTitle;

  /// No description provided for @onboardingProgressBody.
  ///
  /// In en, this message translates to:
  /// **'See best score, recent attempts, weak areas, and review queue.'**
  String get onboardingProgressBody;

  /// No description provided for @landingBrandName.
  ///
  /// In en, this message translates to:
  /// **'MapleTcf'**
  String get landingBrandName;

  /// No description provided for @landingHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'MapleTcf'**
  String get landingHeroTitle;

  /// No description provided for @landingHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Specialized platform for TCF Canada preparation. Train with realistic tests and updated topics.'**
  String get landingHeroSubtitle;

  /// No description provided for @landingServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get landingServicesTitle;

  /// No description provided for @landingPricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get landingPricingTitle;

  /// No description provided for @landingContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get landingContactTitle;

  /// No description provided for @landingCtaLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get landingCtaLogin;

  /// No description provided for @landingCtaLoginShort.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get landingCtaLoginShort;

  /// No description provided for @landingServicesSummary.
  ///
  /// In en, this message translates to:
  /// **'What MapleTcf currently offers'**
  String get landingServicesSummary;

  /// No description provided for @landingPricingSummary.
  ///
  /// In en, this message translates to:
  /// **'Preparation plans'**
  String get landingPricingSummary;

  /// No description provided for @landingContactSummary.
  ///
  /// In en, this message translates to:
  /// **'Talk with our team'**
  String get landingContactSummary;

  /// No description provided for @landingTagTcfCanada.
  ///
  /// In en, this message translates to:
  /// **'TCF Canada'**
  String get landingTagTcfCanada;

  /// No description provided for @landingTagPreparation.
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get landingTagPreparation;

  /// No description provided for @landingTagWebPlatform.
  ///
  /// In en, this message translates to:
  /// **'Web platform'**
  String get landingTagWebPlatform;

  /// No description provided for @landingResumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick overview'**
  String get landingResumeTitle;

  /// No description provided for @landingPlanEssential.
  ///
  /// In en, this message translates to:
  /// **'Essential access - 15 days'**
  String get landingPlanEssential;

  /// No description provided for @landingPlanStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard access - 30 days'**
  String get landingPlanStandard;

  /// No description provided for @landingPlanPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price: {price}'**
  String landingPlanPriceLabel(Object price);

  /// No description provided for @landingCheckWrittenTests.
  ///
  /// In en, this message translates to:
  /// **'40 written tests adapted to TCF Canada format'**
  String get landingCheckWrittenTests;

  /// No description provided for @landingCheckOralTests.
  ///
  /// In en, this message translates to:
  /// **'40 oral tests to strengthen your speaking'**
  String get landingCheckOralTests;

  /// No description provided for @landingCheckPdfResources.
  ///
  /// In en, this message translates to:
  /// **'PDF books for oral and written expression'**
  String get landingCheckPdfResources;

  /// No description provided for @landingCheckUpdatedTopics.
  ///
  /// In en, this message translates to:
  /// **'Regularly updated topics'**
  String get landingCheckUpdatedTopics;

  /// No description provided for @landingResumeLineEssential.
  ///
  /// In en, this message translates to:
  /// **'Essential: 15 days - \$30'**
  String get landingResumeLineEssential;

  /// No description provided for @landingResumeLineStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard: 30 days - \$55'**
  String get landingResumeLineStandard;

  /// No description provided for @landingResumeLineSupport.
  ///
  /// In en, this message translates to:
  /// **'Direct contact by email and phone'**
  String get landingResumeLineSupport;

  /// No description provided for @landingEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email: hello@mapletcf.com'**
  String get landingEmailLabel;

  /// No description provided for @landingPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone: +1 514 555 0147'**
  String get landingPhoneLabel;

  /// No description provided for @landingSupportLabel.
  ///
  /// In en, this message translates to:
  /// **'Support: Monday to Friday - 9:00 to 18:00'**
  String get landingSupportLabel;

  /// No description provided for @ceStartTestCta.
  ///
  /// In en, this message translates to:
  /// **'Start test'**
  String get ceStartTestCta;

  /// No description provided for @ceHeaderAdviceNeedsPractice.
  ///
  /// In en, this message translates to:
  /// **'Adaptive: focus on recent weak points.'**
  String get ceHeaderAdviceNeedsPractice;

  /// No description provided for @ceHeaderAdviceEstablishBaseline.
  ///
  /// In en, this message translates to:
  /// **'Adaptive: continue exercises to establish a baseline.'**
  String get ceHeaderAdviceEstablishBaseline;

  /// No description provided for @ceLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load CE tests:'**
  String get ceLoadError;

  /// No description provided for @ceEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No test available'**
  String get ceEmptyState;

  /// No description provided for @coLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load CO tests:'**
  String get coLoadError;

  /// No description provided for @coEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No oral test available'**
  String get coEmptyState;

  /// No description provided for @ceResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Test result'**
  String get ceResultTitle;

  /// No description provided for @ceResultYourScore.
  ///
  /// In en, this message translates to:
  /// **'Your score'**
  String get ceResultYourScore;

  /// No description provided for @ceResultBelowNclc4.
  ///
  /// In en, this message translates to:
  /// **'Below NCLC 4'**
  String get ceResultBelowNclc4;

  /// No description provided for @ceReviewCta.
  ///
  /// In en, this message translates to:
  /// **'Review answers'**
  String get ceReviewCta;

  /// No description provided for @ceQuestionGridTooltip.
  ///
  /// In en, this message translates to:
  /// **'Question grid'**
  String get ceQuestionGridTooltip;

  /// No description provided for @ceFlagTooltipAdd.
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get ceFlagTooltipAdd;

  /// No description provided for @ceFlagTooltipRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove flag'**
  String get ceFlagTooltipRemove;

  /// No description provided for @ceImageLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get ceImageLoadError;

  /// No description provided for @cePrevQuestion.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get cePrevQuestion;

  /// No description provided for @ceNextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get ceNextQuestion;

  /// No description provided for @ceSubmitTest.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get ceSubmitTest;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

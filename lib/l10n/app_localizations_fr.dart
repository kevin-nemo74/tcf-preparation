// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Simulateur TCF Canada';

  @override
  String get settingsTitle => 'Parametres';

  @override
  String get loginWelcomeBack => 'Bon retour';

  @override
  String get loginAccessTests => 'Connectez-vous pour acceder aux tests';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get forgotPasswordCta => 'Mot de passe oublie ?';

  @override
  String get loginCta => 'Connexion';

  @override
  String get noAccount => 'Pas de compte ?';

  @override
  String get createOne => 'Creer un compte';

  @override
  String get registerTitle => 'Creer un compte';

  @override
  String get registerSubtitle =>
      'Inscrivez-vous pour debloquer tous les tests et sauvegarder votre progression';

  @override
  String get usernameLabel => 'Nom d\'utilisateur';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get createAccountCta => 'Creer un compte';

  @override
  String get alreadyHaveAccount => 'Vous avez deja un compte ?';

  @override
  String get resetPasswordTitle => 'Reinitialiser le mot de passe';

  @override
  String get resetPasswordSubtitle =>
      'Entrez votre e-mail et nous vous enverrons un lien de reinitialisation.';

  @override
  String get sendResetLink => 'Envoyer le lien';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get onboardingHowScoringTitle => 'Comprendre le score';

  @override
  String get onboardingHowScoringBody =>
      'Chaque test est note sur 699 points et associe a un niveau NCLC.';

  @override
  String get onboardingStudyRhythmTitle => 'Rythme d\'etude';

  @override
  String get onboardingStudyRhythmBody =>
      'Utilisez les taches quotidiennes de votre plan d\'etude et gardez votre serie.';

  @override
  String get onboardingProgressTitle => 'Suivre vos progres';

  @override
  String get onboardingProgressBody =>
      'Consultez votre meilleur score, vos tentatives recentes, vos points faibles et la file de revision.';
}

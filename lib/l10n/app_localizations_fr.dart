// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'MapleTcf';

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

  @override
  String get landingBrandName => 'MapleTcf';

  @override
  String get landingHeroTitle => 'MapleTcf';

  @override
  String get landingHeroSubtitle =>
      'Plateforme specialisee dans la preparation au TCF Canada. Entrainez-vous avec des tests adaptes et des sujets mis a jour';

  @override
  String get landingServicesTitle => 'Services';

  @override
  String get landingPricingTitle => 'Tarifs';

  @override
  String get landingContactTitle => 'Contact';

  @override
  String get landingCtaLogin => 'Se connecter';

  @override
  String get landingCtaLoginShort => 'Connexion';

  @override
  String get landingServicesSummary => 'Ce que MapleTcf propose actuellement';

  @override
  String get landingPricingSummary => 'Formules de preparation';

  @override
  String get landingContactSummary => 'Parlez avec notre equipe';

  @override
  String get landingTagTcfCanada => 'TCF Canada';

  @override
  String get landingTagPreparation => 'Preparation';

  @override
  String get landingTagWebPlatform => 'Plateforme web';

  @override
  String get landingResumeTitle => 'Resume rapide';

  @override
  String get landingPlanEssential => 'Acces essentiel - 15 jours';

  @override
  String get landingPlanStandard => 'Acces standard - 30 jours';

  @override
  String landingPlanPriceLabel(Object price) {
    return 'Prix: $price';
  }

  @override
  String get landingCheckWrittenTests =>
      '40 tests ecrits adaptes au format TCF Canada';

  @override
  String get landingCheckOralTests =>
      '40 tests oraux pour renforcer votre expression';

  @override
  String get landingCheckPdfResources =>
      'Livres PDF pour les expressions orale et ecrite';

  @override
  String get landingCheckUpdatedTopics => 'Sujets mis a jour';

  @override
  String get landingResumeLineEssential => 'Essentiel: 15 jours - 30\$';

  @override
  String get landingResumeLineStandard => 'Standard: 30 jours - 55\$';

  @override
  String get landingResumeLineSupport =>
      'Contact direct par e-mail et telephone';

  @override
  String get landingEmailLabel => 'Email: hello@mapletcf.com';

  @override
  String get landingPhoneLabel => 'Telephone: +1 514 555 0147';

  @override
  String get landingSupportLabel => 'Support: Lundi a vendredi - 9:00 a 18:00';

  @override
  String get ceStartTestCta => 'Commencer le test';

  @override
  String get ceHeaderAdviceNeedsPractice =>
      'Adaptatif: concentrez-vous sur les points faibles recents.';

  @override
  String get ceHeaderAdviceEstablishBaseline =>
      'Adaptatif: poursuivez les exercices pour etablir une reference.';

  @override
  String get ceLoadError => 'Echec du chargement des tests CE:';

  @override
  String get ceEmptyState => 'Aucun test disponible';

  @override
  String get coLoadError => 'Echec du chargement des tests CO:';

  @override
  String get coEmptyState => 'Aucun test oral disponible';

  @override
  String get ceResultTitle => 'Resultat du test';

  @override
  String get ceResultYourScore => 'Votre score';

  @override
  String get ceResultBelowNclc4 => 'En dessous de NCLC 4';

  @override
  String get ceReviewCta => 'Revoir les reponses';

  @override
  String get ceQuestionGridTooltip => 'Grille des questions';

  @override
  String get ceFlagTooltipAdd => 'Signaler';

  @override
  String get ceFlagTooltipRemove => 'Retirer le drapeau';

  @override
  String get ceImageLoadError => 'Echec du chargement de l\'image';

  @override
  String get cePrevQuestion => 'Precedent';

  @override
  String get ceNextQuestion => 'Suivant';

  @override
  String get ceSubmitTest => 'Soumettre';
}

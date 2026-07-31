// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get all => 'Tout';

  @override
  String get alphaBadge => 'ALPHA';

  @override
  String get alphaBanner =>
      'Cette application est en alpha. Les fonctionnalités peuvent changer et des bugs sont attendus.';

  @override
  String get apertium => 'Apertium';

  @override
  String get autoTryAll => 'Auto (essayer tout)';

  @override
  String get azure => 'Azure';

  @override
  String get cancel => 'Annuler';

  @override
  String couldNotLoadVoices(String error) {
    return 'Impossible de charger les voix : $error';
  }

  @override
  String get couldNotOpenBugReport => 'Impossible d\'ouvrir le rapport de bug';

  @override
  String get createAccountForMore =>
      'Créez un compte gratuit OpenSubtitles pour débloquer plus de résultats.';

  @override
  String get createFreeAccount => 'Créer un compte gratuit';

  @override
  String get createOsAccount => 'Créer un compte OpenSubtitles';

  @override
  String get defaultLanguageLabel => 'Langue par défaut';

  @override
  String get defaultTargetLanguage => 'Langue cible par défaut';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteTranslation => 'Supprimer la traduction ?';

  @override
  String get dismiss => 'Ignorer';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ? Créez-en un';

  @override
  String get emailHelper =>
      'Augmente la limite quotidienne de MyMemory de 5 000 à 50 000 caractères';

  @override
  String get emailHint => 'votre@email.com';

  @override
  String get emailOptional => 'Email (facultatif)';

  @override
  String get enterSearchQuery => 'Entrez une requête de recherche';

  @override
  String get errorCheckingAuth =>
      'Erreur lors de la vérification de l\'authentification';

  @override
  String get failedToLoad => 'Échec du chargement';

  @override
  String get getStarted => 'Commencer';

  @override
  String get gotIt => 'Compris';

  @override
  String get help => 'Aide';

  @override
  String get helpCreateAccountFull =>
      'Créez un compte gratuit OpenSubtitles pour obtenir 5 téléchargements par jour. Ouvrez la page d\'inscription dans votre navigateur.';

  @override
  String get helpDownloadsDesc =>
      'Tous les fournisseurs sont interrogés en parallèle. Les résultats OpenSubtitles nécessitent une connexion. Appuyez sur un résultat pour télécharger et démarrer la lecture.';

  @override
  String get helpDownloadsFull =>
      'Lorsque vous recherchez, tous les fournisseurs sont interrogés en parallèle. Si vous n\'êtes pas connecté à OpenSubtitles, seuls les résultats SubDL et Podnapisi sont affichés. Appuyez sur un résultat pour télécharger et lire. Les téléchargements OpenSubtitles nécessitent une connexion gratuite.';

  @override
  String get helpProvidersAppDesc =>
      'Cette application recherche trois fournisseurs de sous-titres. OpenSubtitles est gratuit avec 5 téléchargements par jour, ou illimité avec un abonnement VIP. SubDL offre 2 000 recherches par jour avec une clé API gratuite. Podnapisi ne nécessite aucune authentification et n\'a pas de limite quotidienne.';

  @override
  String get helpProvidersDescription =>
      'OpenSubtitles — compte gratuit : 5 téléchargements/jour, VIP : illimité.\nSubDL — 2 000 recherches/jour avec clé API gratuite.\nPodnapisi — aucune authentification, pas de limite quotidienne.';

  @override
  String get homeTagline =>
      'Choisissez des sous-titres et lisez-les à voix haute';

  @override
  String get howDownloadsWork => 'Comment fonctionnent les téléchargements';

  @override
  String get language => 'Langue';

  @override
  String get libreTranslate => 'LibreTranslate';

  @override
  String get loadingSaved => 'Chargement des traductions sauvegardées…';

  @override
  String loggedInAs(String username) {
    return 'Connecté en tant que $username';
  }

  @override
  String get login => 'Connexion';

  @override
  String get loginFailed => 'Échec de la connexion. Vérifiez vos identifiants.';

  @override
  String get loginRequired => 'Connexion requise';

  @override
  String get loginRequiredHelp =>
      'Vous avez besoin d\'un compte gratuit OpenSubtitles pour télécharger des sous-titres.\n\nLes comptes gratuits obtiennent 5 téléchargements par jour.\n\nVous pouvez également utiliser les sous-titres SubDL ou Podnapisi sans vous connecter.';

  @override
  String get logout => 'Déconnexion';

  @override
  String get movies => 'Films';

  @override
  String get myMemory => 'MyMemory';

  @override
  String get newestFirst => 'Plus récents d\'abord';

  @override
  String get next => 'Suivant';

  @override
  String get noDownloadableResults =>
      'Aucun résultat téléchargeable trouvé. Créez un compte gratuit OpenSubtitles pour obtenir plus de résultats.';

  @override
  String noResultsFound(String query) {
    return 'Aucun résultat trouvé pour \"$query\".';
  }

  @override
  String get noSavedTranslations =>
      'Aucune traduction sauvegardée pour le moment.';

  @override
  String get noTranslationsAvailable => 'Aucune traduction disponible.';

  @override
  String noVoicesAvailable(String language) {
    return 'Aucune voix disponible pour $language';
  }

  @override
  String get ok => 'OK';

  @override
  String get oldestFirst => 'Plus anciens d\'abord';

  @override
  String get openSignupPage => 'Ouvrir la page d\'inscription';

  @override
  String get openSubtitlesAccount => 'Compte OpenSubtitles';

  @override
  String get password => 'Mot de passe';

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Lire';

  @override
  String get playSample => 'Lire l\'échantillon';

  @override
  String get playTranslatedSample => 'Lire l\'échantillon traduit';

  @override
  String get pleaseEnterBoth =>
      'Veuillez entrer à la fois le nom d\'utilisateur et le mot de passe';

  @override
  String get previous => 'Précédent';

  @override
  String get readAccountHelpAloud =>
      'Lire l\'aide à la création de compte à voix haute';

  @override
  String get readAccountInfoAloud =>
      'Lire les informations du compte à voix haute';

  @override
  String get readAloud => 'Lire à voix haute';

  @override
  String get readHelpAloud => 'Lire l\'aide à voix haute';

  @override
  String get readHelpAloudNoResults => 'Lire l\'aide de recherche à voix haute';

  @override
  String get readHowDownloadsWorkAloud =>
      'Lire comment fonctionnent les téléchargements à voix haute';

  @override
  String get readSubtitleProvidersAloud =>
      'Lire l\'aide sur les fournisseurs de sous-titres à voix haute';

  @override
  String get readWelcomeAloud => 'Lire le message de bienvenue à voix haute';

  @override
  String get recent => 'Récent';

  @override
  String get reportABug => 'Signaler un bug';

  @override
  String get reportABugSubtitle =>
      'Ouvrir un rapport de bug prérempli sur GitHub';

  @override
  String get savedTranslations => 'Traductions sauvegardées';

  @override
  String get savedTranslationsTitle => 'Traductions Sauvegardées';

  @override
  String get saveTranslation => 'Sauvegarder la traduction';

  @override
  String get saveTranslationHint =>
      'Sauvegarder la traduction pour une utilisation hors ligne';

  @override
  String get searchHelp => 'Aide de recherche';

  @override
  String get searchHint => 'Rechercher des films et émissions de TV…';

  @override
  String get searchSubtitles => 'Rechercher des sous-titres';

  @override
  String get searchTips => 'Conseils de recherche';

  @override
  String get searchTipsContent =>
      'Recherchez des sous-titres de films et TV par nom.\n\nLes résultats de SubDL et Podnapisi sont toujours affichés. Les résultats OpenSubtitles apparaissent uniquement lorsque vous êtes connecté.\n\nLes comptes gratuits OpenSubtitles obtiennent 5 téléchargements par jour.';

  @override
  String get searchTitle => 'Rechercher des Sous-titres';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get skip => 'Passer';

  @override
  String get sortBy => 'Trier par';

  @override
  String get speechConfiguration => 'Configuration vocale';

  @override
  String get speechRate => 'Vitesse de parole';

  @override
  String get speed => 'Vitesse';

  @override
  String get stop => 'Arrêter';

  @override
  String get stopSample => 'Arrêter l\'échantillon';

  @override
  String get stopTranslatedSample => 'Arrêter l\'échantillon traduit';

  @override
  String get subtitleProviders => 'Fournisseurs de sous-titres';

  @override
  String get support => 'Support';

  @override
  String get sync => 'Synchronisation';

  @override
  String get testTranslatedVoice => 'Tester la voix traduite';

  @override
  String testTranslatedVoiceDescription(String language) {
    return 'Traduisez les 5 premières lignes en $language et écoutez-les.';
  }

  @override
  String get testVoice => 'Tester la voix';

  @override
  String testVoiceDescription(String speed, String pitch) {
    return 'Écoutez un échantillon à votre vitesse actuelle (${speed}x) et hauteur (${pitch}x).';
  }

  @override
  String get timeHint => 'Format : HH:MM';

  @override
  String get titleAZ => 'Titre (A-Z)';

  @override
  String translatingEntries(String current, String total) {
    return 'Traduction $current sur $total…';
  }

  @override
  String get translationAndLanguage => 'Traduction et langue';

  @override
  String get translationError => 'Erreur de traduction';

  @override
  String get translationFailedTap =>
      'Traduction échouée : appuyez pour plus de détails';

  @override
  String get translationProvider => 'Fournisseur de traduction';

  @override
  String get translationSaved => 'Traduction sauvegardée';

  @override
  String get tvEpisodes => 'Épisodes TV';

  @override
  String get unexpectedError => 'Une erreur inattendue s\'est produite.';

  @override
  String get unknownVoice => 'Inconnue';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get voice => 'Voix';

  @override
  String get voicePitch => 'Hauteur de voix';

  @override
  String get welcomeFullText =>
      'Bienvenue sur subvocal !\n\nCette application lit les sous-titres à voix haute en synchronisation avec votre vidéo.\n\nPour commencer :\n1. Recherchez un film ou une émission dans l\'onglet Recherche.\n2. Appuyez sur un résultat pour télécharger les sous-titres.\n3. La lecture commence automatiquement.\n\nVous pouvez également vous connecter à OpenSubtitles dans les Paramètres pour plus de résultats.\n\nBesoin d\'aide ? Consultez la section Aide dans Paramètres.';

  @override
  String get welcomeGettingStarted => 'Pour commencer :';

  @override
  String get welcomeHelpHint =>
      'Besoin d\'aide ? Consultez la section Aide dans Paramètres.';

  @override
  String get welcomeIntro =>
      'Cette application lit les sous-titres à voix haute en synchronisation avec votre vidéo.';

  @override
  String get welcomeLoginHint =>
      'Vous pouvez également vous connecter à OpenSubtitles dans les Paramètres pour plus de résultats.';

  @override
  String welcomeStep(String number, String description) {
    return '$number. $description';
  }

  @override
  String get welcomeTitle => 'Bienvenue sur subvocal';

  @override
  String deleteConfirm(String title, String language) {
    return 'Êtes-vous sûr de vouloir supprimer \"$title\" ($language) ?';
  }

  @override
  String searchError(String message) {
    return 'Recherche échouée : $message';
  }

  @override
  String get welcomeStep1 =>
      '1. Recherchez un film ou une émission dans l\'onglet Recherche.';

  @override
  String get welcomeStep2 =>
      '2. Appuyez sur un résultat pour télécharger les sous-titres.';

  @override
  String get welcomeStep3 => '3. La lecture commence automatiquement.';

  @override
  String get noSubtitleLoaded => 'Aucun sous-titre chargé';
}

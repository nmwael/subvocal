// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get all => 'All';

  @override
  String get alphaBadge => 'ALPHA';

  @override
  String get alphaBanner =>
      'This app is in alpha. Features may change and bugs are expected.';

  @override
  String get apertium => 'Apertium';

  @override
  String get autoTryAll => 'Auto (try all)';

  @override
  String get azure => 'Azure';

  @override
  String get cancel => 'Cancel';

  @override
  String couldNotLoadVoices(String error) {
    return 'Could not load voices: $error';
  }

  @override
  String get couldNotOpenBugReport => 'Could not open bug report';

  @override
  String get createAccountForMore =>
      'Create a free OpenSubtitles account to unlock more results.';

  @override
  String get createFreeAccount => 'Create Free Account';

  @override
  String get createOsAccount => 'Create OpenSubtitles Account';

  @override
  String get defaultLanguageLabel => 'Default Language';

  @override
  String get defaultTargetLanguage => 'Default Target Language';

  @override
  String get delete => 'Delete';

  @override
  String get deleteTranslation => 'Delete translation?';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Create one';

  @override
  String get emailHelper =>
      'Raises MyMemory daily limit from 5,000 to 50,000 characters';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get emailOptional => 'Email (optional)';

  @override
  String get enterSearchQuery => 'Enter a search query';

  @override
  String get errorCheckingAuth => 'Error checking auth status';

  @override
  String get failedToLoad => 'Failed to load';

  @override
  String get getStarted => 'Get Started';

  @override
  String get gotIt => 'Got it';

  @override
  String get help => 'Help';

  @override
  String get helpCreateAccountFull =>
      'Create a free OpenSubtitles account to get 5 downloads per day. Open the signup page in your browser.';

  @override
  String get helpDownloadsDesc =>
      'All providers searched in parallel. OpenSubtitles results require login. Tap a result to download and start playback.';

  @override
  String get helpDownloadsFull =>
      'When you search, all providers are queried in parallel. If you are not logged in to OpenSubtitles, only SubDL and Podnapisi results are shown. Tap a result to download and play. OpenSubtitles downloads require a free login.';

  @override
  String get helpProvidersAppDesc =>
      'This app searches three subtitle providers. OpenSubtitles is free with 5 downloads per day, or unlimited with a VIP subscription. SubDL gives 2,000 searches per day with a free API key. Podnapisi has no authentication required and no daily limit.';

  @override
  String get helpProvidersDescription =>
      'OpenSubtitles — free account: 5 downloads/day, VIP: unlimited.\nSubDL — 2,000 searches/day with free API key.\nPodnapisi — no auth needed, no daily limit.';

  @override
  String get homeTagline => 'Pick subtitles and read them aloud';

  @override
  String get howDownloadsWork => 'How Downloads Work';

  @override
  String get language => 'Language';

  @override
  String get libreTranslate => 'LibreTranslate';

  @override
  String get loadingSaved => 'Loading saved translations…';

  @override
  String loggedInAs(String username) {
    return 'Logged in as $username';
  }

  @override
  String get login => 'Login';

  @override
  String get loginFailed => 'Login failed. Check your credentials.';

  @override
  String get loginRequired => 'Login Required';

  @override
  String get loginRequiredHelp =>
      'You need a free OpenSubtitles account to download subtitles.\n\nFree accounts get 5 downloads per day.\n\nYou can also use SubDL or Podnapisi subtitles without logging in.';

  @override
  String get logout => 'Logout';

  @override
  String get movies => 'Movies';

  @override
  String get myMemory => 'MyMemory';

  @override
  String get newestFirst => 'Newest first';

  @override
  String get next => 'Next';

  @override
  String get noDownloadableResults =>
      'No downloadable results found. Create a free OpenSubtitles account to unlock more results.';

  @override
  String noResultsFound(String query) {
    return 'No results found for \"$query\".';
  }

  @override
  String get noSavedTranslations => 'No saved translations yet.';

  @override
  String get noTranslationsAvailable => 'No translations available.';

  @override
  String noVoicesAvailable(String language) {
    return 'No voices available for $language';
  }

  @override
  String get ok => 'OK';

  @override
  String get oldestFirst => 'Oldest first';

  @override
  String get openSignupPage => 'Open signup page';

  @override
  String get openSubtitlesAccount => 'OpenSubtitles Account';

  @override
  String get password => 'Password';

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Play';

  @override
  String get playSample => 'Play Sample';

  @override
  String get playTranslatedSample => 'Play Translated Sample';

  @override
  String get pleaseEnterBoth => 'Please enter both username and password';

  @override
  String get previous => 'Previous';

  @override
  String get readAccountHelpAloud => 'Read account creation help aloud';

  @override
  String get readAccountInfoAloud => 'Read account info aloud';

  @override
  String get readAloud => 'Read aloud';

  @override
  String get readHelpAloud => 'Read help aloud';

  @override
  String get readHelpAloudNoResults => 'Read search help aloud';

  @override
  String get readHowDownloadsWorkAloud => 'Read how downloads work aloud';

  @override
  String get readSubtitleProvidersAloud => 'Read subtitle providers help aloud';

  @override
  String get readWelcomeAloud => 'Read welcome message aloud';

  @override
  String get recent => 'Recent';

  @override
  String get reportABug => 'Report a Bug';

  @override
  String get reportABugSubtitle => 'Open a pre-filled bug report on GitHub';

  @override
  String get savedTranslations => 'Saved translations';

  @override
  String get savedTranslationsTitle => 'Saved Translations';

  @override
  String get saveTranslation => 'Save translation';

  @override
  String get saveTranslationHint => 'Save translation for offline use';

  @override
  String get searchHelp => 'Search Help';

  @override
  String get searchHint => 'Search movies and TV shows…';

  @override
  String get searchSubtitles => 'Search subtitles';

  @override
  String get searchTips => 'Search Tips';

  @override
  String get searchTipsContent =>
      'Search for movie and TV subtitles by name.\n\nResults from SubDL and Podnapisi are always shown. OpenSubtitles results appear only when you are logged in.\n\nFree OpenSubtitles accounts get 5 downloads per day.';

  @override
  String get searchTitle => 'Search Subtitles';

  @override
  String get settingsTitle => 'Readout Settings';

  @override
  String get skip => 'Skip';

  @override
  String get sortBy => 'Sort by';

  @override
  String get speechConfiguration => 'Speech Configuration';

  @override
  String get speechRate => 'Speech Rate';

  @override
  String get speed => 'Speed';

  @override
  String get stop => 'Stop';

  @override
  String get stopSample => 'Stop Sample';

  @override
  String get stopTranslatedSample => 'Stop Translated Sample';

  @override
  String get subtitleProviders => 'Subtitle Providers';

  @override
  String get support => 'Support';

  @override
  String get sync => 'Sync';

  @override
  String get testTranslatedVoice => 'Test Translated Voice';

  @override
  String testTranslatedVoiceDescription(String language) {
    return 'Translate the first 5 lines to $language and hear them spoken.';
  }

  @override
  String get testVoice => 'Test Voice';

  @override
  String testVoiceDescription(String speed, String pitch) {
    return 'Hear a sample at your current speed (${speed}x) and pitch (${pitch}x).';
  }

  @override
  String get timeHint => 'Format: HH:MM';

  @override
  String get titleAZ => 'Title (A-Z)';

  @override
  String translatingEntries(String current, String total) {
    return 'Translating $current of $total…';
  }

  @override
  String get translationAndLanguage => 'Translation & Language';

  @override
  String get translationError => 'Translation Error';

  @override
  String get translationFailedTap => 'Translation failed: tap for details';

  @override
  String get translationProvider => 'Translation Provider';

  @override
  String get translationSaved => 'Translation saved';

  @override
  String get tvEpisodes => 'TV Episodes';

  @override
  String get unexpectedError => 'An unexpected error occurred.';

  @override
  String get unknownVoice => 'Unknown';

  @override
  String get username => 'Username';

  @override
  String get voice => 'Voice';

  @override
  String get voicePitch => 'Voice Pitch';

  @override
  String get welcomeFullText =>
      'Welcome to subvocal!\n\nThis app reads subtitles aloud in sync with your video.\n\nTo get started:\n1. Search for a movie or show on the Search tab.\n2. Tap a result to download subtitles.\n3. Playback starts automatically.\n\nYou can also log in to OpenSubtitles in Settings for more results.\n\nNeed help? Check the Help section in Settings.';

  @override
  String get welcomeGettingStarted => 'To get started:';

  @override
  String get welcomeHelpHint =>
      'Need help? Check the Help section in Settings.';

  @override
  String get welcomeIntro =>
      'This app reads subtitles aloud in sync with your video.';

  @override
  String get welcomeLoginHint =>
      'You can also log in to OpenSubtitles in Settings for more results.';

  @override
  String welcomeStep(String number, String description) {
    return '$number. $description';
  }

  @override
  String get welcomeTitle => 'Welcome to subvocal';

  @override
  String deleteConfirm(String title, String language) {
    return 'Are you sure you want to delete \"$title\" ($language)?';
  }

  @override
  String searchError(String message) {
    return 'Search failed: $message';
  }

  @override
  String get welcomeStep1 => '1. Search for a movie or show on the Search tab.';

  @override
  String get welcomeStep2 => '2. Tap a result to download subtitles.';

  @override
  String get welcomeStep3 => '3. Playback starts automatically.';

  @override
  String get noSubtitleLoaded => 'No subtitle loaded';
}

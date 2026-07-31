import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_da.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
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
/// import 'generated/app_localizations.dart';
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
    Locale('da'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @alphaBadge.
  ///
  /// In en, this message translates to:
  /// **'ALPHA'**
  String get alphaBadge;

  /// No description provided for @alphaBanner.
  ///
  /// In en, this message translates to:
  /// **'This app is in alpha. Features may change and bugs are expected.'**
  String get alphaBanner;

  /// No description provided for @apertium.
  ///
  /// In en, this message translates to:
  /// **'Apertium'**
  String get apertium;

  /// No description provided for @autoTryAll.
  ///
  /// In en, this message translates to:
  /// **'Auto (try all)'**
  String get autoTryAll;

  /// No description provided for @azure.
  ///
  /// In en, this message translates to:
  /// **'Azure'**
  String get azure;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Could not load voices: {error}'**
  String couldNotLoadVoices(String error);

  /// No description provided for @couldNotOpenBugReport.
  ///
  /// In en, this message translates to:
  /// **'Could not open bug report'**
  String get couldNotOpenBugReport;

  /// No description provided for @createAccountForMore.
  ///
  /// In en, this message translates to:
  /// **'Create a free OpenSubtitles account to unlock more results.'**
  String get createAccountForMore;

  /// No description provided for @createFreeAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Free Account'**
  String get createFreeAccount;

  /// No description provided for @createOsAccount.
  ///
  /// In en, this message translates to:
  /// **'Create OpenSubtitles Account'**
  String get createOsAccount;

  /// No description provided for @defaultLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Default Language'**
  String get defaultLanguageLabel;

  /// No description provided for @defaultTargetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Default Target Language'**
  String get defaultTargetLanguage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteTranslation.
  ///
  /// In en, this message translates to:
  /// **'Delete translation?'**
  String get deleteTranslation;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Create one'**
  String get dontHaveAccount;

  /// No description provided for @emailHelper.
  ///
  /// In en, this message translates to:
  /// **'Raises MyMemory daily limit from 5,000 to 50,000 characters'**
  String get emailHelper;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailHint;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @enterSearchQuery.
  ///
  /// In en, this message translates to:
  /// **'Enter a search query'**
  String get enterSearchQuery;

  /// No description provided for @errorCheckingAuth.
  ///
  /// In en, this message translates to:
  /// **'Error checking auth status'**
  String get errorCheckingAuth;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get failedToLoad;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @helpCreateAccountFull.
  ///
  /// In en, this message translates to:
  /// **'Create a free OpenSubtitles account to get 5 downloads per day. Open the signup page in your browser.'**
  String get helpCreateAccountFull;

  /// No description provided for @helpDownloadsDesc.
  ///
  /// In en, this message translates to:
  /// **'All providers searched in parallel. OpenSubtitles results require login. Tap a result to download and start playback.'**
  String get helpDownloadsDesc;

  /// No description provided for @helpDownloadsFull.
  ///
  /// In en, this message translates to:
  /// **'When you search, all providers are queried in parallel. If you are not logged in to OpenSubtitles, only SubDL and Podnapisi results are shown. Tap a result to download and play. OpenSubtitles downloads require a free login.'**
  String get helpDownloadsFull;

  /// No description provided for @helpProvidersAppDesc.
  ///
  /// In en, this message translates to:
  /// **'This app searches three subtitle providers. OpenSubtitles is free with 5 downloads per day, or unlimited with a VIP subscription. SubDL gives 2,000 searches per day with a free API key. Podnapisi has no authentication required and no daily limit.'**
  String get helpProvidersAppDesc;

  /// No description provided for @helpProvidersDescription.
  ///
  /// In en, this message translates to:
  /// **'OpenSubtitles — free account: 5 downloads/day, VIP: unlimited.\nSubDL — 2,000 searches/day with free API key.\nPodnapisi — no auth needed, no daily limit.'**
  String get helpProvidersDescription;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Pick subtitles and read them aloud'**
  String get homeTagline;

  /// No description provided for @howDownloadsWork.
  ///
  /// In en, this message translates to:
  /// **'How Downloads Work'**
  String get howDownloadsWork;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @libreTranslate.
  ///
  /// In en, this message translates to:
  /// **'LibreTranslate'**
  String get libreTranslate;

  /// No description provided for @loadingSaved.
  ///
  /// In en, this message translates to:
  /// **'Loading saved translations…'**
  String get loadingSaved;

  ///
  ///
  /// In en, this message translates to:
  /// **'Logged in as {username}'**
  String loggedInAs(String username);

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Check your credentials.'**
  String get loginFailed;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// No description provided for @loginRequiredHelp.
  ///
  /// In en, this message translates to:
  /// **'You need a free OpenSubtitles account to download subtitles.\n\nFree accounts get 5 downloads per day.\n\nYou can also use SubDL or Podnapisi subtitles without logging in.'**
  String get loginRequiredHelp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @movies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get movies;

  /// No description provided for @myMemory.
  ///
  /// In en, this message translates to:
  /// **'MyMemory'**
  String get myMemory;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get newestFirst;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @noDownloadableResults.
  ///
  /// In en, this message translates to:
  /// **'No downloadable results found. Create a free OpenSubtitles account to unlock more results.'**
  String get noDownloadableResults;

  ///
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\".'**
  String noResultsFound(String query);

  /// No description provided for @noSavedTranslations.
  ///
  /// In en, this message translates to:
  /// **'No saved translations yet.'**
  String get noSavedTranslations;

  /// No description provided for @noTranslationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No translations available.'**
  String get noTranslationsAvailable;

  ///
  ///
  /// In en, this message translates to:
  /// **'No voices available for {language}'**
  String noVoicesAvailable(String language);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get oldestFirst;

  /// No description provided for @openSignupPage.
  ///
  /// In en, this message translates to:
  /// **'Open signup page'**
  String get openSignupPage;

  /// No description provided for @openSubtitlesAccount.
  ///
  /// In en, this message translates to:
  /// **'OpenSubtitles Account'**
  String get openSubtitlesAccount;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @playSample.
  ///
  /// In en, this message translates to:
  /// **'Play Sample'**
  String get playSample;

  /// No description provided for @playTranslatedSample.
  ///
  /// In en, this message translates to:
  /// **'Play Translated Sample'**
  String get playTranslatedSample;

  /// No description provided for @pleaseEnterBoth.
  ///
  /// In en, this message translates to:
  /// **'Please enter both username and password'**
  String get pleaseEnterBoth;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @readAccountHelpAloud.
  ///
  /// In en, this message translates to:
  /// **'Read account creation help aloud'**
  String get readAccountHelpAloud;

  /// No description provided for @readAccountInfoAloud.
  ///
  /// In en, this message translates to:
  /// **'Read account info aloud'**
  String get readAccountInfoAloud;

  /// No description provided for @readAloud.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get readAloud;

  /// No description provided for @readHelpAloud.
  ///
  /// In en, this message translates to:
  /// **'Read help aloud'**
  String get readHelpAloud;

  /// No description provided for @readHelpAloudNoResults.
  ///
  /// In en, this message translates to:
  /// **'Read search help aloud'**
  String get readHelpAloudNoResults;

  /// No description provided for @readHowDownloadsWorkAloud.
  ///
  /// In en, this message translates to:
  /// **'Read how downloads work aloud'**
  String get readHowDownloadsWorkAloud;

  /// No description provided for @readSubtitleProvidersAloud.
  ///
  /// In en, this message translates to:
  /// **'Read subtitle providers help aloud'**
  String get readSubtitleProvidersAloud;

  /// No description provided for @readWelcomeAloud.
  ///
  /// In en, this message translates to:
  /// **'Read welcome message aloud'**
  String get readWelcomeAloud;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @reportABug.
  ///
  /// In en, this message translates to:
  /// **'Report a Bug'**
  String get reportABug;

  /// No description provided for @reportABugSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open a pre-filled bug report on GitHub'**
  String get reportABugSubtitle;

  /// No description provided for @savedTranslations.
  ///
  /// In en, this message translates to:
  /// **'Saved translations'**
  String get savedTranslations;

  /// No description provided for @savedTranslationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Translations'**
  String get savedTranslationsTitle;

  /// No description provided for @saveTranslation.
  ///
  /// In en, this message translates to:
  /// **'Save translation'**
  String get saveTranslation;

  /// No description provided for @saveTranslationHint.
  ///
  /// In en, this message translates to:
  /// **'Save translation for offline use'**
  String get saveTranslationHint;

  /// No description provided for @searchHelp.
  ///
  /// In en, this message translates to:
  /// **'Search Help'**
  String get searchHelp;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search movies and TV shows…'**
  String get searchHint;

  /// No description provided for @searchSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Search subtitles'**
  String get searchSubtitles;

  /// No description provided for @searchTips.
  ///
  /// In en, this message translates to:
  /// **'Search Tips'**
  String get searchTips;

  /// No description provided for @searchTipsContent.
  ///
  /// In en, this message translates to:
  /// **'Search for movie and TV subtitles by name.\n\nResults from SubDL and Podnapisi are always shown. OpenSubtitles results appear only when you are logged in.\n\nFree OpenSubtitles accounts get 5 downloads per day.'**
  String get searchTipsContent;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Subtitles'**
  String get searchTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Readout Settings'**
  String get settingsTitle;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @speechConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Speech Configuration'**
  String get speechConfiguration;

  /// No description provided for @speechRate.
  ///
  /// In en, this message translates to:
  /// **'Speech Rate'**
  String get speechRate;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @stopSample.
  ///
  /// In en, this message translates to:
  /// **'Stop Sample'**
  String get stopSample;

  /// No description provided for @stopTranslatedSample.
  ///
  /// In en, this message translates to:
  /// **'Stop Translated Sample'**
  String get stopTranslatedSample;

  /// No description provided for @subtitleProviders.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Providers'**
  String get subtitleProviders;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @testTranslatedVoice.
  ///
  /// In en, this message translates to:
  /// **'Test Translated Voice'**
  String get testTranslatedVoice;

  ///
  ///
  /// In en, this message translates to:
  /// **'Translate the first 5 lines to {language} and hear them spoken.'**
  String testTranslatedVoiceDescription(String language);

  /// No description provided for @testVoice.
  ///
  /// In en, this message translates to:
  /// **'Test Voice'**
  String get testVoice;

  ///
  ///
  /// In en, this message translates to:
  /// **'Hear a sample at your current speed ({speed}x) and pitch ({pitch}x).'**
  String testVoiceDescription(String speed, String pitch);

  /// No description provided for @timeHint.
  ///
  /// In en, this message translates to:
  /// **'Format: HH:MM'**
  String get timeHint;

  /// No description provided for @titleAZ.
  ///
  /// In en, this message translates to:
  /// **'Title (A-Z)'**
  String get titleAZ;

  ///
  ///
  /// In en, this message translates to:
  /// **'Translating {current} of {total}…'**
  String translatingEntries(String current, String total);

  /// No description provided for @translationAndLanguage.
  ///
  /// In en, this message translates to:
  /// **'Translation & Language'**
  String get translationAndLanguage;

  /// No description provided for @translationError.
  ///
  /// In en, this message translates to:
  /// **'Translation Error'**
  String get translationError;

  /// No description provided for @translationFailedTap.
  ///
  /// In en, this message translates to:
  /// **'Translation failed: tap for details'**
  String get translationFailedTap;

  /// No description provided for @translationProvider.
  ///
  /// In en, this message translates to:
  /// **'Translation Provider'**
  String get translationProvider;

  /// No description provided for @translationSaved.
  ///
  /// In en, this message translates to:
  /// **'Translation saved'**
  String get translationSaved;

  /// No description provided for @tvEpisodes.
  ///
  /// In en, this message translates to:
  /// **'TV Episodes'**
  String get tvEpisodes;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedError;

  /// No description provided for @unknownVoice.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownVoice;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @voicePitch.
  ///
  /// In en, this message translates to:
  /// **'Voice Pitch'**
  String get voicePitch;

  /// No description provided for @welcomeFullText.
  ///
  /// In en, this message translates to:
  /// **'Welcome to subvocal!\n\nThis app reads subtitles aloud in sync with your video.\n\nTo get started:\n1. Search for a movie or show on the Search tab.\n2. Tap a result to download subtitles.\n3. Playback starts automatically.\n\nYou can also log in to OpenSubtitles in Settings for more results.\n\nNeed help? Check the Help section in Settings.'**
  String get welcomeFullText;

  /// No description provided for @welcomeGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'To get started:'**
  String get welcomeGettingStarted;

  /// No description provided for @welcomeHelpHint.
  ///
  /// In en, this message translates to:
  /// **'Need help? Check the Help section in Settings.'**
  String get welcomeHelpHint;

  /// No description provided for @welcomeIntro.
  ///
  /// In en, this message translates to:
  /// **'This app reads subtitles aloud in sync with your video.'**
  String get welcomeIntro;

  /// No description provided for @welcomeLoginHint.
  ///
  /// In en, this message translates to:
  /// **'You can also log in to OpenSubtitles in Settings for more results.'**
  String get welcomeLoginHint;

  ///
  ///
  /// In en, this message translates to:
  /// **'{number}. {description}'**
  String welcomeStep(String number, String description);

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to subvocal'**
  String get welcomeTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\" ({language})?'**
  String deleteConfirm(String title, String language);

  ///
  ///
  /// In en, this message translates to:
  /// **'Search failed: {message}'**
  String searchError(String message);

  /// No description provided for @welcomeStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Search for a movie or show on the Search tab.'**
  String get welcomeStep1;

  /// No description provided for @welcomeStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Tap a result to download subtitles.'**
  String get welcomeStep2;

  /// No description provided for @welcomeStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Playback starts automatically.'**
  String get welcomeStep3;

  /// No description provided for @noSubtitleLoaded.
  ///
  /// In en, this message translates to:
  /// **'No subtitle loaded'**
  String get noSubtitleLoaded;
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
      <String>['da', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'da':
      return AppLocalizationsDa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
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

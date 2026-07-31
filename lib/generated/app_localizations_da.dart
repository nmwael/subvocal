// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get all => 'Alle';

  @override
  String get alphaBadge => 'ALFA';

  @override
  String get alphaBanner =>
      'Denne app er i alfa. Funktioner kan ændre sig, og fejl forventes.';

  @override
  String get apertium => 'Apertium';

  @override
  String get autoTryAll => 'Auto (prøv alle)';

  @override
  String get azure => 'Azure';

  @override
  String get cancel => 'Annuller';

  @override
  String couldNotLoadVoices(String error) {
    return 'Kunne ikke indlæse stemmer: $error';
  }

  @override
  String get couldNotOpenBugReport => 'Kunne ikke åbne fejlrapport';

  @override
  String get createAccountForMore =>
      'Opret en gratis OpenSubtitles-konto for at få flere resultater.';

  @override
  String get createFreeAccount => 'Opret gratis konto';

  @override
  String get createOsAccount => 'Opret OpenSubtitles-konto';

  @override
  String get defaultLanguageLabel => 'Standardsprog';

  @override
  String get defaultTargetLanguage => 'Standard målsprog';

  @override
  String get delete => 'Slet';

  @override
  String get deleteTranslation => 'Slet oversættelse?';

  @override
  String get dismiss => 'Afvis';

  @override
  String get dontHaveAccount => 'Har du ikke en konto? Opret en';

  @override
  String get emailHelper =>
      'Forøger MyMemorys daglige grænse fra 5.000 til 50.000 tegn';

  @override
  String get emailHint => 'din@email.dk';

  @override
  String get emailOptional => 'E-mail (valgfri)';

  @override
  String get enterSearchQuery => 'Indtast en søgning';

  @override
  String get errorCheckingAuth => 'Fejl ved kontrol af autentificering';

  @override
  String get failedToLoad => 'Kunne ikke indlæse';

  @override
  String get getStarted => 'Kom i gang';

  @override
  String get gotIt => 'Forstået';

  @override
  String get help => 'Hjælp';

  @override
  String get helpCreateAccountFull =>
      'Opret en gratis OpenSubtitles-konto for at få 5 downloads om dagen. Åbn tilmeldingssiden i din browser.';

  @override
  String get helpDownloadsDesc =>
      'Alle udbydere søges parallelt. OpenSubtitles-resultater kræver login. Tryk på et resultat for at downloade og starte afspilning.';

  @override
  String get helpDownloadsFull =>
      'Når du søger, forespørges alle udbydere parallelt. Hvis du ikke er logget ind på OpenSubtitles, vises kun SubDL- og Podnapisi-resultater. Tryk på et resultat for at downloade og afspille. OpenSubtitles-downloads kræver et gratis login.';

  @override
  String get helpProvidersAppDesc =>
      'Denne app søger i tre undertekstudbydere. OpenSubtitles er gratis med 5 downloads om dagen eller ubegrænset med et VIP-abonnement. SubDL giver 2.000 søgninger om dagen med en gratis API-nøgle. Podnapisi kræver ingen autentificering og har ingen daglig grænse.';

  @override
  String get helpProvidersDescription =>
      'OpenSubtitles — gratis konto: 5 downloads/dag, VIP: ubegrænset.\nSubDL — 2.000 søgninger/dag med gratis API-nøgle.\nPodnapisi — ingen autentificering, ingen daglig grænse.';

  @override
  String get homeTagline => 'Vælg undertekster og læs dem højt';

  @override
  String get howDownloadsWork => 'Sådan fungerer downloads';

  @override
  String get language => 'Sprog';

  @override
  String get libreTranslate => 'LibreTranslate';

  @override
  String get loadingSaved => 'Indlæser gemte oversættelser…';

  @override
  String loggedInAs(String username) {
    return 'Logget ind som $username';
  }

  @override
  String get login => 'Log ind';

  @override
  String get loginFailed =>
      'Login mislykkedes. Kontrollér dine legitimationsoplysninger.';

  @override
  String get loginRequired => 'Login påkrævet';

  @override
  String get loginRequiredHelp =>
      'Du skal bruge en gratis OpenSubtitles-konto for at downloade undertekster.\n\nGratis konti får 5 downloads om dagen.\n\nDu kan også bruge SubDL- eller Podnapisi-undertekster uden at logge ind.';

  @override
  String get logout => 'Log ud';

  @override
  String get movies => 'Film';

  @override
  String get myMemory => 'MyMemory';

  @override
  String get newestFirst => 'Nyeste først';

  @override
  String get next => 'Næste';

  @override
  String get noDownloadableResults =>
      'Ingen downloadbare resultater fundet. Opret en gratis OpenSubtitles-konto for at få flere resultater.';

  @override
  String noResultsFound(String query) {
    return 'Ingen resultater fundet for \"$query\".';
  }

  @override
  String get noSavedTranslations => 'Ingen gemte oversættelser endnu.';

  @override
  String get noTranslationsAvailable => 'Ingen oversættelser tilgængelige.';

  @override
  String noVoicesAvailable(String language) {
    return 'Ingen stemmer tilgængelige for $language';
  }

  @override
  String get ok => 'OK';

  @override
  String get oldestFirst => 'Ældste først';

  @override
  String get openSignupPage => 'Åbn tilmeldingsside';

  @override
  String get openSubtitlesAccount => 'OpenSubtitles-konto';

  @override
  String get password => 'Adgangskode';

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Afspil';

  @override
  String get playSample => 'Afspil prøve';

  @override
  String get playTranslatedSample => 'Afspil oversat prøve';

  @override
  String get pleaseEnterBoth => 'Indtast både brugernavn og adgangskode';

  @override
  String get previous => 'Forrige';

  @override
  String get readAccountHelpAloud => 'Læs hjælp til kontoprettelse højt';

  @override
  String get readAccountInfoAloud => 'Læs kontooplysninger højt';

  @override
  String get readAloud => 'Læs højt';

  @override
  String get readHelpAloud => 'Læs hjælp højt';

  @override
  String get readHelpAloudNoResults => 'Læs søgehjælp højt';

  @override
  String get readHowDownloadsWorkAloud => 'Læs hvordan downloads fungerer højt';

  @override
  String get readSubtitleProvidersAloud =>
      'Læs hjælp til undertekstudbydere højt';

  @override
  String get readWelcomeAloud => 'Læs velkomstbesked højt';

  @override
  String get recent => 'Seneste';

  @override
  String get reportABug => 'Rapporter en fejl';

  @override
  String get reportABugSubtitle => 'Åbn en forudfyldt fejlrapport på GitHub';

  @override
  String get savedTranslations => 'Gemte oversættelser';

  @override
  String get savedTranslationsTitle => 'Gemte Oversættelser';

  @override
  String get saveTranslation => 'Gem oversættelse';

  @override
  String get saveTranslationHint => 'Gem oversættelse til offline brug';

  @override
  String get searchHelp => 'Søgehjælp';

  @override
  String get searchHint => 'Søg efter film og tv-serier…';

  @override
  String get searchSubtitles => 'Søg efter undertekster';

  @override
  String get searchTips => 'Søgetips';

  @override
  String get searchTipsContent =>
      'Søg efter film- og tv-undertekster ved navn.\n\nResultater fra SubDL og Podnapisi vises altid. OpenSubtitles-resultater vises kun, når du er logget ind.\n\nGratis OpenSubtitles-konti får 5 downloads om dagen.';

  @override
  String get searchTitle => 'Søg efter undertekster';

  @override
  String get settingsTitle => 'Indstillinger';

  @override
  String get skip => 'Spring over';

  @override
  String get sortBy => 'Sorter efter';

  @override
  String get speechConfiguration => 'Taleindstillinger';

  @override
  String get speechRate => 'Talehastighed';

  @override
  String get speed => 'Hastighed';

  @override
  String get stop => 'Stop';

  @override
  String get stopSample => 'Stop prøve';

  @override
  String get stopTranslatedSample => 'Stop oversat prøve';

  @override
  String get subtitleProviders => 'Undertekstudbydere';

  @override
  String get support => 'Support';

  @override
  String get sync => 'Synkronisering';

  @override
  String get testTranslatedVoice => 'Test oversat stemme';

  @override
  String testTranslatedVoiceDescription(String language) {
    return 'Oversæt de første 5 linjer til $language og hør dem blive talt.';
  }

  @override
  String get testVoice => 'Test stemme';

  @override
  String testVoiceDescription(String speed, String pitch) {
    return 'Hør en prøve ved din nuværende hastighed (${speed}x) og tonehøjde (${pitch}x).';
  }

  @override
  String get timeHint => 'Format: TT:MM';

  @override
  String get titleAZ => 'Titel (A-Å)';

  @override
  String translatingEntries(String current, String total) {
    return 'Oversætter $current af $total…';
  }

  @override
  String get translationAndLanguage => 'Oversættelse og sprog';

  @override
  String get translationError => 'Oversættelsesfejl';

  @override
  String get translationFailedTap =>
      'Oversættelse mislykkedes: tryk for detaljer';

  @override
  String get translationProvider => 'Oversættelsesudbyder';

  @override
  String get translationSaved => 'Oversættelse gemt';

  @override
  String get tvEpisodes => 'Tv-afsnit';

  @override
  String get unexpectedError => 'Der opstod en uventet fejl.';

  @override
  String get unknownVoice => 'Ukendt';

  @override
  String get username => 'Brugernavn';

  @override
  String get voice => 'Stemme';

  @override
  String get voicePitch => 'Tonehøjde';

  @override
  String get welcomeFullText =>
      'Velkommen til subvocal!\n\nDenne app læser undertekster højt i takt med din video.\n\nSådan kommer du i gang:\n1. Søg efter en film eller et program på fanen Søg.\n2. Tryk på et resultat for at downloade undertekster.\n3. Afspilning starter automatisk.\n\nDu kan også logge ind på OpenSubtitles i Indstillinger for flere resultater.\n\nBrug for hjælp? Tjek Hjælp-sektionen i Indstillinger.';

  @override
  String get welcomeGettingStarted => 'Sådan kommer du i gang:';

  @override
  String get welcomeHelpHint =>
      'Brug for hjælp? Tjek Hjælp-sektionen i Indstillinger.';

  @override
  String get welcomeIntro =>
      'Denne app læser undertekster højt i takt med din video.';

  @override
  String get welcomeLoginHint =>
      'Du kan også logge ind på OpenSubtitles i Indstillinger for flere resultater.';

  @override
  String welcomeStep(String number, String description) {
    return '$number. $description';
  }

  @override
  String get welcomeTitle => 'Velkommen til subvocal';

  @override
  String deleteConfirm(String title, String language) {
    return 'Er du sikker på, at du vil slette \"$title\" ($language)?';
  }

  @override
  String searchError(String message) {
    return 'Søgning mislykkedes: $message';
  }

  @override
  String get welcomeStep1 =>
      '1. Søg efter en film eller et program på fanen Søg.';

  @override
  String get welcomeStep2 =>
      '2. Tryk på et resultat for at downloade undertekster.';

  @override
  String get welcomeStep3 => '3. Afspilning starter automatisk.';

  @override
  String get noSubtitleLoaded => 'Ingen undertekster indlæst';
}

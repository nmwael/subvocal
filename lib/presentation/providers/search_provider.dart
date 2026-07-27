import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../domain/services/srt_parser.dart';
import '../../data/datasources/apertium_translate_api.dart';
import '../../data/datasources/azure_translate_api.dart';
import '../../data/datasources/fallback_translation_service.dart';
import '../../data/datasources/google_translate_api.dart';
import '../../data/datasources/libre_translate_api.dart';
import '../../data/datasources/local_file_source.dart';
import '../../data/datasources/my_memory_translate_api.dart';
import '../../data/datasources/opensubtitles_api.dart';
import '../../data/datasources/podnapisi_api.dart';
import '../../data/datasources/subdl_api.dart';
import '../../data/datasources/translation_service.dart';
import '../../data/repositories/subtitle_repository_impl.dart';
import 'settings_provider.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/entities/subtitle.dart';
import '../../domain/usecases/download_subtitle.dart';
import '../../domain/usecases/login_subtitle.dart';
import '../../domain/usecases/search_subtitles.dart';
import '../../domain/usecases/translate_subtitle.dart';

final _httpClientProvider = Provider<http.Client>((ref) => http.Client());

final srtParserProvider = Provider<SrtParser>((ref) => SrtParser());

final _localFileSourceProvider = Provider<LocalFileSource>(
  (ref) => LocalFileSource(),
);

final openSubtitlesApiProvider = Provider<OpenSubtitlesApi>((ref) {
  const apiKey = String.fromEnvironment(
    'OPENSUBTITLES_API_KEY',
    defaultValue: 'PgbtQmDgz18n4zCJKeMMXFwPunhwRMQM',
  );
  return OpenSubtitlesApi(ref.watch(_httpClientProvider), apiKey);
});

final _subdlApiProvider = Provider<SubdlApi?>((ref) {
  const apiKey = String.fromEnvironment('SUBDL_API_KEY', defaultValue: '');
  if (apiKey.isEmpty) return null;
  return SubdlApi(ref.watch(_httpClientProvider), apiKey);
});

final _podnapisiApiProvider = Provider<PodnapisiApi>((ref) {
  return PodnapisiApi(ref.watch(_httpClientProvider));
});

final _myMemoryProvider = Provider<MyMemoryTranslateApi>((ref) {
  final email = ref.watch(settingsProvider.select((s) => s.myMemoryEmail));
  return MyMemoryTranslateApi(ref.watch(_httpClientProvider), email: email);
});

final _apertiumProvider = Provider<ApertiumTranslateApi>((ref) {
  return ApertiumTranslateApi(ref.watch(_httpClientProvider));
});

final _libreTranslateProvider = Provider<LibreTranslateApi>((ref) {
  return LibreTranslateApi(ref.watch(_httpClientProvider));
});

final _translationServiceProvider = Provider<TranslationService>((ref) {
  const googleApiKey = String.fromEnvironment(
    'GOOGLE_TRANSLATE_API_KEY',
    defaultValue: '',
  );
  if (googleApiKey.isNotEmpty) {
    return GoogleTranslateApi(ref.watch(_httpClientProvider), googleApiKey);
  }

  const azureKey = String.fromEnvironment(
    'AZURE_TRANSLATION_KEY',
    defaultValue: '',
  );
  const azureRegion = String.fromEnvironment(
    'AZURE_TRANSLATION_REGION',
    defaultValue: '',
  );
  final hasAzure = azureKey.isNotEmpty && azureRegion.isNotEmpty;

  final providerType = ref.watch(
    settingsProvider.select((s) => s.selectedTranslationProvider),
  );
  final myMemory = ref.watch(_myMemoryProvider);
  final apertium = ref.watch(_apertiumProvider);
  final libreTranslate = ref.watch(_libreTranslateProvider);

  final services = <TranslationService>[];
  if (hasAzure) {
    services.add(
      AzureTranslateApi(
        ref.watch(_httpClientProvider),
        apiKey: azureKey,
        region: azureRegion,
      ),
    );
  }
  services.addAll([myMemory, apertium, libreTranslate]);

  return switch (providerType) {
    TranslationProviderType.azure when hasAzure => services.first,
    TranslationProviderType.myMemory => myMemory,
    TranslationProviderType.apertium => apertium,
    TranslationProviderType.libreTranslate => libreTranslate,
    TranslationProviderType.auto => FallbackTranslationService(services),
    _ => FallbackTranslationService(services),
  };
});

final subtitleRepositoryProvider = Provider<SubtitleRepositoryImpl>((ref) {
  return SubtitleRepositoryImpl(
    api: ref.watch(openSubtitlesApiProvider),
    subdlApi: ref.watch(_subdlApiProvider),
    podnapisiApi: ref.watch(_podnapisiApiProvider),
    localFileSource: ref.watch(_localFileSourceProvider),
    srtParser: ref.watch(srtParserProvider),
    translateService: ref.watch(_translationServiceProvider),
  );
});

final searchSubtitlesProvider = Provider<SearchSubtitles>((ref) {
  return SearchSubtitles(ref.watch(subtitleRepositoryProvider));
});

final downloadSubtitleProvider = Provider<DownloadSubtitle>((ref) {
  return DownloadSubtitle(ref.watch(subtitleRepositoryProvider));
});

final loginSubtitleProvider = Provider<LoginSubtitle>((ref) {
  return LoginSubtitle(ref.watch(subtitleRepositoryProvider));
});

final translateSubtitleProvider = Provider<TranslateSubtitle>((ref) {
  return TranslateSubtitle(ref.watch(subtitleRepositoryProvider));
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchContentTypeProvider = StateProvider<String>((ref) => 'all');

final searchStreamingProvider = StateProvider<String>((ref) => '');

const streamingServiceTags = {
  'NF': 'Netflix',
  'AMZN': 'Amazon Prime',
  'PRIME': 'Amazon Prime',
  'DSNY': 'Disney+',
  'DP': 'Disney+',
  'MAX': 'HBO Max',
  'HMAX': 'HBO Max',
  'HULU': 'Hulu',
  'PCOK': 'Peacock',
  'PMNT': 'Paramount+',
  'ATVP': 'Apple TV+',
};

bool _matchesStreamingTag(String? releaseName, String serviceKey) {
  if (releaseName == null || releaseName.isEmpty) return false;
  final upper = releaseName.toUpperCase();
  final parts = upper.split(RegExp(r'[.\s\-_]'));
  return parts.any((part) {
    final clean = part.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (clean == serviceKey) return true;
    if (serviceKey == 'AMZN' && clean == 'PRIME') return true;
    if (serviceKey == 'PRIME' && clean == 'AMZN') return true;
    if (serviceKey == 'DSNY' && clean == 'DP') return true;
    if (serviceKey == 'DP' && clean == 'DSNY') return true;
    if (serviceKey == 'MAX' && clean == 'HMAX') return true;
    if (serviceKey == 'HMAX' && clean == 'MAX') return true;
    return false;
  });
}

final searchResultsProvider = FutureProvider.autoDispose
    .family<List<SearchResult>, (String, String)>((ref, params) async {
      final (query, contentType) = params;
      if (query.isEmpty) return [];
      final searchSubtitles = ref.watch(searchSubtitlesProvider);
      final preferredLanguage = ref.watch(
        settingsProvider.select((s) => s.selectedLanguage),
      );
      final streamingFilter = ref.watch(searchStreamingProvider);
      final (results, failure) = await searchSubtitles.call(
        query,
        type: contentType,
      );
      if (failure != null) throw failure;
      var items = results ?? [];
      if (streamingFilter.isNotEmpty) {
        items = items
            .where((r) => _matchesStreamingTag(r.releaseName, streamingFilter))
            .toList();
      }
      items.sort((a, b) {
        final aMatches = a.language == preferredLanguage;
        final bMatches = b.language == preferredLanguage;
        if (aMatches && !bMatches) return -1;
        if (!aMatches && bMatches) return 1;
        return 0;
      });
      return items;
    });

final importedSubtitleProvider = StateProvider<Subtitle?>((ref) => null);

final downloadedSubtitleProvider = StateProvider<Subtitle?>((ref) => null);

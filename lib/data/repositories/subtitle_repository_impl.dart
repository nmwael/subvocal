import '../../core/utils/app_logger.dart';
import '../../domain/errors/failures.dart';
import '../../domain/services/srt_parser.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/entities/subtitle.dart';
import '../../domain/entities/subtitle_entry.dart';
import '../../domain/entities/translation_progress.dart';
import '../../domain/repositories/subtitle_repository.dart';
import '../datasources/local_file_source.dart';
import '../datasources/opensubtitles_api.dart';
import '../datasources/podnapisi_api.dart';
import '../datasources/subdl_api.dart';
import '../datasources/translation_service.dart';
import '../repositories/subtitle_provider_aggregator.dart';

class SubtitleRepositoryImpl implements SubtitleRepository {
  final OpenSubtitlesApi api;
  final SubdlApi? subdlApi;
  final PodnapisiApi? podnapisiApi;
  final LocalFileSource localFileSource;
  final SrtParser srtParser;
  final TranslationService translateService;
  late final SubtitleProviderAggregator _aggregator;

  SubtitleRepositoryImpl({
    required this.api,
    this.subdlApi,
    this.podnapisiApi,
    required this.localFileSource,
    required this.srtParser,
    required this.translateService,
  }) {
    _aggregator = SubtitleProviderAggregator(
      opensubtitles: api,
      subdl: subdlApi,
      podnapisi: podnapisiApi,
    );
  }

  @override
  Future<(List<SearchResult>?, Failure?)> search(
    String query, {
    String? language,
    String? type,
  }) async {
    return _aggregator.search(query, language: language, type: type);
  }

  @override
  Future<(Subtitle?, Failure?)> download(int fileId, {String? title}) async {
    final (link, failure) = await api.download(fileId);
    if (failure != null) return (null, failure);
    if (link == null) {
      return (null, const NetworkFailure('Empty download link'));
    }

    final (content, fetchFailure) = await api.fetchContent(link);
    if (fetchFailure != null) return (null, fetchFailure);
    if (content == null) {
      return (null, const NetworkFailure('Empty subtitle content'));
    }

    final entries = srtParser.parse(content);
    if (entries.isEmpty) {
      return (
        null,
        const SrtParseFailure('No valid entries in downloaded subtitle'),
      );
    }

    return (Subtitle(id: fileId, title: title ?? '', entries: entries), null);
  }

  Future<(Subtitle?, Failure?)> downloadFromProvider(
    dynamic fileId,
    String providerSource, {
    String? title,
  }) async {
    if (providerSource == 'SubDL' && subdlApi != null) {
      final (link, failure) = await subdlApi!.download(fileId);
      if (failure != null) return (null, failure);
      if (link == null) {
        return (null, const NetworkFailure('Empty download link'));
      }

      final (content, fetchFailure) = await subdlApi!.fetchContent(link);
      if (fetchFailure != null) return (null, fetchFailure);
      if (content == null) {
        return (null, const NetworkFailure('Empty subtitle content'));
      }

      final entries = srtParser.parse(content);
      if (entries.isEmpty) {
        return (
          null,
          const SrtParseFailure('No valid entries in downloaded subtitle'),
        );
      }

      return (Subtitle(id: fileId, title: title ?? '', entries: entries), null);
    }

    if (providerSource == 'Podnapisi' && podnapisiApi != null) {
      final (link, failure) = await podnapisiApi!.download(fileId);
      if (failure != null) return (null, failure);
      if (link == null) {
        return (null, const NetworkFailure('Empty download link'));
      }

      final (content, fetchFailure) = await podnapisiApi!.fetchContent(link);
      if (fetchFailure != null) return (null, fetchFailure);
      if (content == null) {
        return (null, const NetworkFailure('Empty subtitle content'));
      }

      final entries = srtParser.parse(content);
      if (entries.isEmpty) {
        return (
          null,
          const SrtParseFailure('No valid entries in downloaded subtitle'),
        );
      }

      return (Subtitle(id: fileId, title: title ?? '', entries: entries), null);
    }

    return download(fileId as int, title: title);
  }

  @override
  Future<(Subtitle?, Failure?)> importFromFile(String filePath) async {
    final (content, failure) = await localFileSource.readFile(filePath);
    if (failure != null) return (null, failure);
    if (content == null) return (null, const FileAccessFailure('Empty file'));

    final entries = srtParser.parse(content);
    if (entries.isEmpty) {
      return (null, const SrtParseFailure('No valid entries in file'));
    }

    final fileName = filePath.split('/').last.replaceAll('.srt', '');
    return (Subtitle(title: fileName, entries: entries), null);
  }

  @override
  Future<(String?, Failure?)> login(String username, String password) async {
    final token = await api.login(username, password);
    if (token == null) {
      return (
        null,
        const NetworkFailure('Login failed. Check your credentials.'),
      );
    }
    return (token, null);
  }

  @override
  void setToken(String token) => api.setToken(token);

  @override
  void logout() {
    api.logout();
  }

  @override
  Future<bool> validateToken() => api.validateToken();

  @override
  Future<(Subtitle?, Failure?)> translate(
    Subtitle subtitle,
    String targetLanguage, {
    String? sourceLanguage,
    void Function(TranslationProgress progress)? onProgress,
  }) async {
    final effectiveSource = sourceLanguage ?? subtitle.language;
    if (effectiveSource != null && effectiveSource == targetLanguage) {
      return (subtitle, null);
    }

    const batchSize = 10;
    const maxRetries = 3;
    final total = subtitle.entries.length;
    final translatedEntries = List<SubtitleEntry>.filled(
      total,
      subtitle.entries.first,
    );
    var completed = 0;

    for (var i = 0; i < total; i += batchSize) {
      final batch = subtitle.entries.skip(i).take(batchSize).toList();
      final futures = batch.map((entry) async {
        for (var retry = 0; retry < maxRetries; retry++) {
          final (text, failure) = await translateService.translate(
            entry.text,
            targetLanguage,
            sourceLanguage: effectiveSource,
          );
          if (failure == null && text != null) {
            return SubtitleEntry(
              index: entry.index,
              start: entry.start,
              end: entry.end,
              text: text,
            );
          }
          if (failure?.message.contains('Rate limit') == true &&
              retry < maxRetries - 1) {
            final delay = (1 << retry) * 5;
            await Future.delayed(Duration(seconds: delay));
            continue;
          }
          return null;
        }
        return null;
      });

      final results = await Future.wait(futures);
      for (var j = 0; j < results.length; j++) {
        final result = results[j];
        if (result != null) {
          translatedEntries[i + j] = result;
        } else {
          appLogger.warning(
            'Translation failed for entry ${batch[j].index}, using original',
            source: 'SubtitleRepository',
          );
          translatedEntries[i + j] = batch[j];
        }
      }
      completed += batch.length;
      onProgress?.call(TranslationProgress(completed: completed, total: total));
    }

    return (
      Subtitle(
        id: subtitle.id,
        title: subtitle.title,
        language: targetLanguage,
        entries: translatedEntries,
      ),
      null,
    );
  }
}

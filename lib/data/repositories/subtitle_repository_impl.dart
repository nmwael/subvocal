import '../../domain/errors/failures.dart';
import '../../domain/services/srt_parser.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/entities/subtitle.dart';
import '../../domain/entities/subtitle_entry.dart';
import '../../domain/entities/translation_progress.dart';
import '../../domain/repositories/subtitle_repository.dart';
import '../datasources/local_file_source.dart';
import '../datasources/opensubtitles_api.dart';
import '../datasources/translation_service.dart';
import '../models/search_result_model.dart';

class SubtitleRepositoryImpl implements SubtitleRepository {
  final OpenSubtitlesApi api;
  final LocalFileSource localFileSource;
  final SrtParser srtParser;
  final TranslationService translateService;

  SubtitleRepositoryImpl({
    required this.api,
    required this.localFileSource,
    required this.srtParser,
    required this.translateService,
  });

  @override
  Future<(List<SearchResult>?, Failure?)> search(String query, {String? language}) async {
    final (data, failure) = await api.search(query, language: language);
    if (failure != null) return (null, failure);
    if (data == null) return (<SearchResult>[], null);

    final results = data.map((json) {
      final model = SearchResultModel.fromJson(json);
      return model.toEntity();
    }).toList();

    return (results, null);
  }

  @override
  Future<(Subtitle?, Failure?)> download(int fileId) async {
    final (link, failure) = await api.download(fileId);
    if (failure != null) return (null, failure);
    if (link == null) return (null, const NetworkFailure('Empty download link'));

    final (content, fetchFailure) = await api.fetchContent(link);
    if (fetchFailure != null) return (null, fetchFailure);
    if (content == null) return (null, const NetworkFailure('Empty subtitle content'));

    final entries = srtParser.parse(content);
    if (entries.isEmpty) {
      return (null, const SrtParseFailure('No valid entries in downloaded subtitle'));
    }

    return (Subtitle(id: fileId, title: '', entries: entries), null);
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
      return (null, const NetworkFailure('Login failed. Check your credentials.'));
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
    void Function(TranslationProgress progress)? onProgress,
  }) async {
    const batchSize = 10;
    const maxRetries = 3;
    final total = subtitle.entries.length;
    final translatedEntries = List<SubtitleEntry>.filled(total, subtitle.entries.first);
    var completed = 0;

    for (var i = 0; i < total; i += batchSize) {
      final batch = subtitle.entries.skip(i).take(batchSize).toList();
      final texts = batch.map((e) => e.text).toList();

      List<String>? translatedTexts;
      Failure? lastFailure;
      for (var retry = 0; retry < maxRetries; retry++) {
        final (result, failure) = await translateService.translateBatch(texts, targetLanguage);
        if (failure == null && result != null) {
          translatedTexts = result;
          break;
        }
        lastFailure = failure;
        if (failure?.message.contains('Rate limit') == true && retry < maxRetries - 1) {
          await Future.delayed(Duration(seconds: retry + 1));
          continue;
        }
        break;
      }

      if (translatedTexts == null) {
        return (null, lastFailure ?? const NetworkFailure('Translation failed'));
      }

      for (var j = 0; j < batch.length; j++) {
        translatedEntries[i + j] = SubtitleEntry(
          index: batch[j].index,
          start: batch[j].start,
          end: batch[j].end,
          text: translatedTexts[j],
        );
      }
      completed += batch.length;
      onProgress?.call(TranslationProgress(completed: completed, total: total));
    }

    return (Subtitle(
      id: subtitle.id,
      title: subtitle.title,
      language: targetLanguage,
      entries: translatedEntries,
    ), null);
  }
}

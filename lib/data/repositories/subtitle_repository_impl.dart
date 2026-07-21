import '../../core/errors/failures.dart';
import '../../core/utils/srt_parser.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/entities/subtitle.dart';
import '../../domain/entities/subtitle_entry.dart';
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
  void logout() {
    api.logout();
  }

  @override
  Future<(Subtitle?, Failure?)> translate(Subtitle subtitle, String targetLanguage) async {
    final translatedEntries = <SubtitleEntry>[];
    for (final entry in subtitle.entries) {
      final (translatedText, failure) = await translateService.translate(entry.text, targetLanguage);
      if (failure != null) return (null, failure);
      if (translatedText == null) return (null, const NetworkFailure('Empty translation result'));
      translatedEntries.add(SubtitleEntry(
        index: entry.index,
        start: entry.start,
        end: entry.end,
        text: translatedText,
      ));
    }
    return (Subtitle(
      id: subtitle.id,
      title: subtitle.title,
      language: targetLanguage,
      entries: translatedEntries,
    ), null);
  }
}

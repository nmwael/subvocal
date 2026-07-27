import '../errors/failures.dart';
import '../entities/search_result.dart';
import '../entities/subtitle.dart';
import '../entities/translation_progress.dart';

abstract class SubtitleRepository {
  Future<(List<SearchResult>?, Failure?)> search(
    String query, {
    String? language,
    String? type,
  });
  Future<(Subtitle?, Failure?)> download(int fileId, {String? title});
  Future<(Subtitle?, Failure?)> importFromFile(String filePath);
  Future<(Subtitle?, Failure?)> translate(
    Subtitle subtitle,
    String targetLanguage, {
    String? sourceLanguage,
    void Function(TranslationProgress progress)? onProgress,
  });
  Future<(String?, Failure?)> login(String username, String password);
  void setToken(String token);
  void logout();
  Future<bool> validateToken();
}

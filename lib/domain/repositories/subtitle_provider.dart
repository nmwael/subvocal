import '../entities/search_result.dart';
import '../errors/failures.dart';

abstract class SubtitleProvider {
  String get name;

  Future<(List<SearchResult>?, Failure?)> search(
    String query, {
    String? language,
    String? type,
  });

  Future<(String?, Failure?)> download(dynamic fileId);

  Future<(String?, Failure?)> fetchContent(String url);
}

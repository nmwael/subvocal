import '../../core/errors/failures.dart';
import '../entities/search_result.dart';
import '../entities/subtitle.dart';

abstract class SubtitleRepository {
  Future<(List<SearchResult>?, Failure?)> search(String query, {String? language});
  Future<(Subtitle?, Failure?)> download(int fileId);
  Future<(Subtitle?, Failure?)> importFromFile(String filePath);
}

import '../../core/errors/failures.dart';
import '../entities/search_result.dart';
import '../repositories/subtitle_repository.dart';

class SearchSubtitles {
  final SubtitleRepository _repository;

  SearchSubtitles(this._repository);

  Future<(List<SearchResult>?, Failure?)> call(String query, {String? language}) {
    return _repository.search(query, language: language);
  }
}

import '../../domain/entities/search_result.dart';
import '../../domain/errors/failures.dart';
import '../datasources/opensubtitles_api.dart';
import '../datasources/podnapisi_api.dart';
import '../datasources/subdl_api.dart';
import '../models/search_result_model.dart';

class SubtitleProviderAggregator {
  final OpenSubtitlesApi opensubtitles;
  final SubdlApi? subdl;
  final PodnapisiApi? podnapisi;

  SubtitleProviderAggregator({
    required this.opensubtitles,
    this.subdl,
    this.podnapisi,
  });

  Future<(List<SearchResult>?, Failure?)> search(
    String query, {
    String? language,
    String? type,
  }) async {
    final allResults = <SearchResult>[];

    final (osResults, osFailure) = await opensubtitles.search(
      query,
      language: language,
      type: type,
    );
    if (osResults != null) {
      allResults.addAll(
        osResults.map((r) {
          final model = SearchResultModel.fromJson(r);
          return model.toEntity();
        }),
      );
    }

    if (subdl != null) {
      final (sdResults, sdFailure) = await subdl!.search(
        query,
        language: language,
        type: type,
      );
      if (sdResults != null) {
        allResults.addAll(sdResults);
      }
    }

    if (podnapisi != null) {
      final (pnResults, pnFailure) = await podnapisi!.search(
        query,
        language: language,
        type: type,
      );
      if (pnResults != null) {
        allResults.addAll(pnResults);
      }
    }

    final deduplicated = _deduplicateResults(allResults);
    return (deduplicated, null);
  }

  List<SearchResult> _deduplicateResults(List<SearchResult> results) {
    final seen = <String, SearchResult>{};
    for (final result in results) {
      final key = '${result.title}_${result.year}_${result.language}';
      if (!seen.containsKey(key)) {
        seen[key] = result;
      }
    }
    return seen.values.toList();
  }
}

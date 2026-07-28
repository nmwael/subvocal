import '../../core/utils/app_logger.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/errors/failures.dart';
import '../../domain/repositories/subtitle_provider.dart';

class SubtitleProviderAggregator {
  final List<SubtitleProvider> providers;

  SubtitleProviderAggregator({required this.providers});

  Future<(List<SearchResult>?, Failure?)> search(
    String query, {
    String? language,
    String? type,
  }) async {
    if (providers.isEmpty) return (<SearchResult>[], null);

    final futures = providers.map((provider) async {
      try {
        return await provider.search(query, language: language, type: type);
      } catch (e) {
        appLogger.warning(
          '${provider.name} search threw: $e',
          source: 'SubtitleProviderAggregator',
        );
        return (<SearchResult>[], null);
      }
    }).toList();

    final outcomes = await Future.wait(futures);

    final allResults = <SearchResult>[];
    var failedCount = 0;
    for (var i = 0; i < outcomes.length; i++) {
      final (results, failure) = outcomes[i];
      if (failure != null) {
        failedCount++;
        appLogger.warning(
          '${providers[i].name} search failed: ${failure.message}',
          source: 'SubtitleProviderAggregator',
        );
      }
      if (results != null) {
        allResults.addAll(results);
      }
    }

    if (failedCount == providers.length) {
      appLogger.warning(
        'All ${providers.length} providers failed',
        source: 'SubtitleProviderAggregator',
      );
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

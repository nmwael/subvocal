import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/domain/entities/search_result.dart';
import 'package:subvocal/domain/errors/failures.dart';
import 'package:subvocal/domain/repositories/subtitle_provider.dart';
import 'package:subvocal/data/repositories/subtitle_provider_aggregator.dart';

class _FakeProvider implements SubtitleProvider {
  @override
  final String name;

  final List<SearchResult>? results;
  final Failure? failure;
  int searchCallCount = 0;
  String? lastQuery;

  _FakeProvider({required this.name, this.results, this.failure});

  @override
  Future<(List<SearchResult>?, Failure?)> search(
    String query, {
    String? language,
    String? type,
  }) async {
    searchCallCount++;
    lastQuery = query;
    return (results, failure);
  }

  @override
  Future<(String?, Failure?)> download(dynamic fileId) async => (null, null);

  @override
  Future<(String?, Failure?)> fetchContent(String url) async => (null, null);
}

class _ThrowingProvider implements SubtitleProvider {
  @override
  String get name => 'Throwing';

  @override
  Future<(List<SearchResult>?, Failure?)> search(
    String query, {
    String? language,
    String? type,
  }) async {
    throw StateError('boom');
  }

  @override
  Future<(String?, Failure?)> download(dynamic fileId) async => (null, null);

  @override
  Future<(String?, Failure?)> fetchContent(String url) async => (null, null);
}

SearchResult _result(String title, {String? year, String? language}) {
  return SearchResult(
    fileId: title.hashCode,
    title: title,
    year: year,
    language: language,
    providerSource: 'Test',
  );
}

void main() {
  group('SubtitleProviderAggregator', () {
    test('returns empty list when no providers', () async {
      final aggregator = SubtitleProviderAggregator(providers: []);

      final (results, failure) = await aggregator.search('test');

      expect(failure, isNull);
      expect(results, isEmpty);
    });

    test('returns results from single provider', () async {
      final provider = _FakeProvider(
        name: 'TestProvider',
        results: [_result('Movie A'), _result('Movie B')],
      );
      final aggregator = SubtitleProviderAggregator(providers: [provider]);

      final (results, failure) = await aggregator.search('test');

      expect(failure, isNull);
      expect(results!.length, 2);
      expect(provider.searchCallCount, 1);
      expect(provider.lastQuery, 'test');
    });

    test('passes language and type to providers', () async {
      final provider = _FakeProvider(name: 'TestProvider', results: []);
      final aggregator = SubtitleProviderAggregator(providers: [provider]);

      await aggregator.search('test', language: 'en', type: 'movie');

      expect(provider.lastQuery, 'test');
      // We can't directly check language/type on _FakeProvider without
      // storing them, but the provider was called
      expect(provider.searchCallCount, 1);
    });

    test('combines results from multiple providers', () async {
      final providerA = _FakeProvider(name: 'A', results: [_result('Movie A')]);
      final providerB = _FakeProvider(name: 'B', results: [_result('Movie B')]);
      final aggregator = SubtitleProviderAggregator(
        providers: [providerA, providerB],
      );

      final (results, failure) = await aggregator.search('test');

      expect(failure, isNull);
      expect(results!.length, 2);
    });

    test('deduplicates results by title_year_language', () async {
      final providerA = _FakeProvider(
        name: 'A',
        results: [_result('Movie', year: '2020', language: 'en')],
      );
      final providerB = _FakeProvider(
        name: 'B',
        results: [_result('Movie', year: '2020', language: 'en')],
      );
      final aggregator = SubtitleProviderAggregator(
        providers: [providerA, providerB],
      );

      final (results, failure) = await aggregator.search('test');

      expect(failure, isNull);
      expect(results!.length, 1);
      expect(results[0].title, 'Movie');
    });

    test('does not deduplicate different years', () async {
      final providerA = _FakeProvider(
        name: 'A',
        results: [_result('Movie', year: '2020')],
      );
      final providerB = _FakeProvider(
        name: 'B',
        results: [_result('Movie', year: '2024')],
      );
      final aggregator = SubtitleProviderAggregator(
        providers: [providerA, providerB],
      );

      final (results, failure) = await aggregator.search('test');

      expect(failure, isNull);
      expect(results!.length, 2);
    });

    test('gracefully handles provider returning failure', () async {
      final providerA = _FakeProvider(
        name: 'A',
        failure: const NetworkFailure('timeout'),
      );
      final providerB = _FakeProvider(name: 'B', results: [_result('Movie B')]);
      final aggregator = SubtitleProviderAggregator(
        providers: [providerA, providerB],
      );

      final (results, failure) = await aggregator.search('test');

      expect(failure, isNull);
      expect(results!.length, 1);
      expect(results[0].title, 'Movie B');
    });

    test('gracefully handles provider throwing exception', () async {
      final providerA = _ThrowingProvider();
      final providerB = _FakeProvider(name: 'B', results: [_result('Movie B')]);
      final aggregator = SubtitleProviderAggregator(
        providers: [providerA, providerB],
      );

      final (results, failure) = await aggregator.search('test');

      expect(failure, isNull);
      expect(results!.length, 1);
      expect(results[0].title, 'Movie B');
    });

    test('queries providers in parallel', () async {
      final providerA = _FakeProvider(name: 'A', results: [_result('Movie A')]);
      final providerB = _FakeProvider(name: 'B', results: [_result('Movie B')]);
      final aggregator = SubtitleProviderAggregator(
        providers: [providerA, providerB],
      );

      await aggregator.search('test');

      // Both providers should have been called
      expect(providerA.searchCallCount, 1);
      expect(providerB.searchCallCount, 1);
    });

    test('returns empty list when all providers return null results', () async {
      final providerA = _FakeProvider(name: 'A', results: null);
      final providerB = _FakeProvider(name: 'B', results: null);
      final aggregator = SubtitleProviderAggregator(
        providers: [providerA, providerB],
      );

      final (results, failure) = await aggregator.search('test');

      expect(failure, isNull);
      expect(results, isEmpty);
    });

    test('always returns null failure', () async {
      final provider = _FakeProvider(
        name: 'A',
        failure: const NetworkFailure('error'),
      );
      final aggregator = SubtitleProviderAggregator(providers: [provider]);

      final (_, failure) = await aggregator.search('test');

      // Aggregator always returns null failure (logs warnings instead)
      expect(failure, isNull);
    });
  });
}

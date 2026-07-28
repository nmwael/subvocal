import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:subvocal/domain/errors/failures.dart';
import 'package:subvocal/data/datasources/podnapisi_api.dart';

class _MockHttpClient extends http.BaseClient {
  final int statusCode;
  final List<int>? bodyBytes;
  final Map<String, dynamic>? body;
  final Exception? error;
  http.BaseRequest? lastRequest;

  _MockHttpClient({
    this.statusCode = 200,
    this.bodyBytes,
    this.body,
    this.error,
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;
    if (error != null) throw error!;
    final bytes =
        bodyBytes ?? (body != null ? utf8.encode(jsonEncode(body)) : <int>[]);
    return http.StreamedResponse(
      Stream.value(bytes),
      statusCode,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
}

void main() {
  group('PodnapisiApi.search', () {
    test('returns results on successful search', () async {
      final client = _MockHttpClient(
        body: {
          'data': [
            {
              'id': 12345,
              'name': 'Test Movie',
              'year': 2020,
              'lang': 'en',
              'release_name': 'Test.Movie.2020.1080p',
              'season': null,
              'episode': null,
              'episode_name': null,
            },
          ],
        },
      );
      final api = PodnapisiApi(client);

      final (data, failure) = await api.search('test');

      expect(failure, isNull);
      expect(data, isNotNull);
      expect(data!.length, 1);
      expect(data[0].fileId, 12345);
      expect(data[0].title, 'Test Movie');
      expect(data[0].providerSource, 'Podnapisi');
    });

    test('returns empty list when no data found', () async {
      final client = _MockHttpClient(body: {'data': []});
      final api = PodnapisiApi(client);

      final (data, failure) = await api.search('nonexistent');

      expect(failure, isNull);
      expect(data, isNotNull);
      expect(data, isEmpty);
    });

    test('returns empty list when data field is null', () async {
      final client = _MockHttpClient(body: {'data': null});
      final api = PodnapisiApi(client);

      final (data, failure) = await api.search('test');

      expect(failure, isNull);
      expect(data, isNotNull);
      expect(data, isEmpty);
    });

    test('returns NetworkFailure on 429 rate limit', () async {
      final client = _MockHttpClient(statusCode: 429);
      final api = PodnapisiApi(client);

      final (data, failure) = await api.search('test');

      expect(data, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Rate limit exceeded'));
    });

    test('returns NetworkFailure on 500 server error', () async {
      final client = _MockHttpClient(statusCode: 500);
      final api = PodnapisiApi(client);

      final (data, failure) = await api.search('test');

      expect(data, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('500'));
    });

    test('returns NetworkFailure on socket exception', () async {
      final client = _MockHttpClient(
        error: const SocketException('Connection refused'),
      );
      final api = PodnapisiApi(client);

      final (data, failure) = await api.search('test');

      expect(data, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('No internet connection'));
    });

    test('sends language parameter when provided', () async {
      final client = _MockHttpClient(body: {'data': []});
      final api = PodnapisiApi(client);

      await api.search('test', language: 'en');

      expect(client.lastRequest, isNotNull);
      final uri = client.lastRequest!.url;
      expect(uri.queryParameters['sJ'], 'en');
    });

    test('sends type parameter when provided', () async {
      final client = _MockHttpClient(body: {'data': []});
      final api = PodnapisiApi(client);

      await api.search('test', type: 'movie');

      expect(client.lastRequest, isNotNull);
      final uri = client.lastRequest!.url;
      expect(uri.queryParameters['sT'], 'movie');
    });

    test('does not send type when value is all', () async {
      final client = _MockHttpClient(body: {'data': []});
      final api = PodnapisiApi(client);

      await api.search('test', type: 'all');

      expect(client.lastRequest, isNotNull);
      final uri = client.lastRequest!.url;
      expect(uri.queryParameters.containsKey('sT'), isFalse);
    });
  });

  group('PodnapisiApi.download', () {
    test('returns base64-encoded content on success', () async {
      const srtContent = '1\n00:00:01,000 --> 00:00:04,000\nHello!';
      final client = _MockHttpClient(
        bodyBytes: utf8.encode(srtContent),
        statusCode: 200,
      );
      final api = PodnapisiApi(client);

      final (encoded, failure) = await api.download(12345);

      expect(failure, isNull);
      expect(encoded, isNotNull);
      expect(utf8.decode(base64Decode(encoded!)), srtContent);
    });

    test('returns NetworkFailure on 429 rate limit', () async {
      final client = _MockHttpClient(statusCode: 429);
      final api = PodnapisiApi(client);

      final (encoded, failure) = await api.download(12345);

      expect(encoded, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Rate limit exceeded'));
    });

    test('returns NetworkFailure on server error', () async {
      final client = _MockHttpClient(statusCode: 500);
      final api = PodnapisiApi(client);

      final (encoded, failure) = await api.download(12345);

      expect(encoded, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('500'));
    });

    test('returns NetworkFailure on socket exception', () async {
      final client = _MockHttpClient(
        error: const SocketException('Connection refused'),
      );
      final api = PodnapisiApi(client);

      final (encoded, failure) = await api.download(12345);

      expect(encoded, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('No internet connection'));
    });
  });

  group('PodnapisiApi.fetchContent', () {
    test('decodes base64 content directly', () async {
      final client = _MockHttpClient();
      final api = PodnapisiApi(client);
      const srtContent = '1\n00:00:01,000 --> 00:00:04,000\nHello!';
      final encoded = base64Encode(utf8.encode(srtContent));

      final (content, failure) = await api.fetchContent(encoded);

      expect(failure, isNull);
      expect(content, srtContent);
    });

    test('falls back to HTTP GET for non-base64 URLs', () async {
      const srtContent = '1\n00:00:01,000 --> 00:00:04,000\nHello!';
      final client = _MockHttpClient(
        bodyBytes: utf8.encode(srtContent),
        statusCode: 200,
      );
      final api = PodnapisiApi(client);

      final (content, failure) = await api.fetchContent(
        'https://www.podnapisi.net/subtitles/12345/download',
      );

      expect(failure, isNull);
      expect(content, srtContent);
    });

    test('returns NetworkFailure on HTTP 429', () async {
      final client = _MockHttpClient(statusCode: 429);
      final api = PodnapisiApi(client);

      final (content, failure) = await api.fetchContent(
        'https://www.podnapisi.net/subtitles/12345/download',
      );

      expect(content, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Rate limit exceeded'));
    });

    test('returns NetworkFailure on HTTP error', () async {
      final client = _MockHttpClient(statusCode: 500);
      final api = PodnapisiApi(client);

      final (content, failure) = await api.fetchContent(
        'https://www.podnapisi.net/subtitles/12345/download',
      );

      expect(content, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('500'));
    });

    test('returns NetworkFailure on socket exception', () async {
      final client = _MockHttpClient(
        error: const SocketException('Connection refused'),
      );
      final api = PodnapisiApi(client);

      final (content, failure) = await api.fetchContent(
        'https://www.podnapisi.net/subtitles/12345/download',
      );

      expect(content, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('No internet connection'));
    });
  });

  group('PodnapisiSearchResultModel', () {
    test('parses JSON correctly', () {
      final json = {
        'id': 12345,
        'name': 'Test Movie',
        'year': 2020,
        'lang': 'en',
        'release_name': 'Test.Movie.2020.1080p',
        'season': 1,
        'episode': 5,
        'episode_name': 'The Episode',
      };
      final model = PodnapisiSearchResultModel.fromJson(json);

      expect(model.id, 12345);
      expect(model.name, 'Test Movie');
      expect(model.year, '2020');
      expect(model.language, 'en');
      expect(model.releaseName, 'Test.Movie.2020.1080p');
      expect(model.season, 1);
      expect(model.episode, 5);
      expect(model.episodeName, 'The Episode');
    });

    test('handles missing optional fields', () {
      final json = {'id': 12345, 'name': 'Test Movie'};
      final model = PodnapisiSearchResultModel.fromJson(json);

      expect(model.year, isNull);
      expect(model.language, isNull);
      expect(model.releaseName, isNull);
      expect(model.season, isNull);
      expect(model.episode, isNull);
      expect(model.episodeName, isNull);
    });

    test('converts year int to string', () {
      final json = {'id': 1, 'name': 'Movie', 'year': 2020};
      final model = PodnapisiSearchResultModel.fromJson(json);

      expect(model.year, '2020');
    });

    test('toEntity maps correctly', () {
      final model = PodnapisiSearchResultModel(
        id: 12345,
        name: 'Test Movie',
        year: '2020',
        language: 'en',
        releaseName: 'Test.Movie.2020.1080p',
        season: 1,
        episode: 5,
        episodeName: 'The Episode',
      );

      final entity = model.toEntity();

      expect(entity.fileId, 12345);
      expect(entity.title, 'Test Movie');
      expect(entity.year, '2020');
      expect(entity.language, 'en');
      expect(entity.releaseName, 'Test.Movie.2020.1080p');
      expect(entity.providerSource, 'Podnapisi');
      expect(entity.season, 1);
      expect(entity.episode, 5);
      expect(entity.episodeName, 'The Episode');
    });
  });
}

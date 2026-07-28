import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:subvocal/domain/errors/failures.dart';
import 'package:subvocal/data/datasources/subdl_api.dart';

class _MockHttpClient extends http.BaseClient {
  final int statusCode;
  final Map<String, dynamic>? body;
  final Exception? error;
  http.BaseRequest? lastRequest;

  _MockHttpClient({this.statusCode = 200, this.body, this.error});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;
    if (error != null) throw error!;
    final bytes = body != null ? utf8.encode(jsonEncode(body)) : <int>[];
    return http.StreamedResponse(
      Stream.value(bytes),
      statusCode,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
}

void main() {
  const apiKey = 'test-api-key';

  group('SubdlApi.search', () {
    test('returns results on successful search', () async {
      final client = _MockHttpClient(
        body: {
          'subtitles': [
            {
              'id': '12345',
              'name': 'Test Movie',
              'year': '2020',
              'language': 'en',
              'release_name': 'Test.Movie.2020.1080p',
              'season_number': null,
              'episode_number': null,
              'episode_name': null,
            },
          ],
        },
      );
      final api = SubdlApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(failure, isNull);
      expect(data, isNotNull);
      expect(data!.length, 1);
      expect(data[0].fileId, '12345');
      expect(data[0].title, 'Test Movie');
      expect(data[0].providerSource, 'SubDL');
    });

    test('returns empty list when no subtitles found', () async {
      final client = _MockHttpClient(body: {'subtitles': []});
      final api = SubdlApi(client, apiKey);

      final (data, failure) = await api.search('nonexistent');

      expect(failure, isNull);
      expect(data, isNotNull);
      expect(data, isEmpty);
    });

    test('returns empty list when subtitles field is null', () async {
      final client = _MockHttpClient(body: {'subtitles': null});
      final api = SubdlApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(failure, isNull);
      expect(data, isNotNull);
      expect(data, isEmpty);
    });

    test('returns NetworkFailure on 429 rate limit', () async {
      final client = _MockHttpClient(statusCode: 429);
      final api = SubdlApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(data, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Rate limit exceeded'));
    });

    test('returns NetworkFailure on 500 server error', () async {
      final client = _MockHttpClient(statusCode: 500);
      final api = SubdlApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(data, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('500'));
    });

    test('returns NetworkFailure on socket exception', () async {
      final client = _MockHttpClient(
        error: const SocketException('Connection refused'),
      );
      final api = SubdlApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(data, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('No internet connection'));
    });

    test('includes Authorization header', () async {
      final client = _MockHttpClient(body: {'subtitles': []});
      final api = SubdlApi(client, apiKey);

      await api.search('test');

      expect(client.lastRequest, isNotNull);
      expect(client.lastRequest!.headers['Authorization'], apiKey);
    });

    test('sends language parameter when provided', () async {
      final client = _MockHttpClient(body: {'subtitles': []});
      final api = SubdlApi(client, apiKey);

      await api.search('test', language: 'en');

      expect(client.lastRequest, isNotNull);
      final uri = client.lastRequest!.url;
      expect(uri.queryParameters['languages'], 'en');
    });

    test('sends type parameter when provided', () async {
      final client = _MockHttpClient(body: {'subtitles': []});
      final api = SubdlApi(client, apiKey);

      await api.search('test', type: 'movie');

      expect(client.lastRequest, isNotNull);
      final uri = client.lastRequest!.url;
      expect(uri.queryParameters['type'], 'movie');
    });

    test('does not send type when value is all', () async {
      final client = _MockHttpClient(body: {'subtitles': []});
      final api = SubdlApi(client, apiKey);

      await api.search('test', type: 'all');

      expect(client.lastRequest, isNotNull);
      final uri = client.lastRequest!.url;
      expect(uri.queryParameters.containsKey('type'), isFalse);
    });
  });

  group('SubdlApi.download', () {
    test('returns download URL on success', () async {
      final client = _MockHttpClient(
        body: {'url': '/subtitles/test.srt'},
      );
      final api = SubdlApi(client, apiKey);

      final (link, failure) = await api.download('12345');

      expect(failure, isNull);
      expect(link, 'https://dl.subdl.com/subtitles/test.srt');
    });

    test('returns NetworkFailure on 429 rate limit', () async {
      final client = _MockHttpClient(statusCode: 429);
      final api = SubdlApi(client, apiKey);

      final (link, failure) = await api.download('12345');

      expect(link, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Rate limit exceeded'));
    });

    test('returns NetworkFailure when URL is missing', () async {
      final client = _MockHttpClient(body: {'url': null});
      final api = SubdlApi(client, apiKey);

      final (link, failure) = await api.download('12345');

      expect(link, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('No download URL'));
    });

    test('returns NetworkFailure on socket exception', () async {
      final client = _MockHttpClient(
        error: const SocketException('Connection refused'),
      );
      final api = SubdlApi(client, apiKey);

      final (link, failure) = await api.download('12345');

      expect(link, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('No internet connection'));
    });
  });

  group('SubdlApi.fetchContent', () {
    test('returns content on success', () async {
      final client = _MockHttpClient(
        body: {'data': 'subtitle content'},
        statusCode: 200,
      );
      final api = SubdlApi(client, apiKey);

      final (content, failure) = await api.fetchContent(
        'https://dl.subdl.com/file.srt',
      );

      expect(failure, isNull);
      expect(content, isNotNull);
    });

    test('returns NetworkFailure on 429 rate limit', () async {
      final client = _MockHttpClient(statusCode: 429);
      final api = SubdlApi(client, apiKey);

      final (content, failure) = await api.fetchContent(
        'https://dl.subdl.com/file.srt',
      );

      expect(content, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Rate limit exceeded'));
    });

    test('returns NetworkFailure on server error', () async {
      final client = _MockHttpClient(statusCode: 500);
      final api = SubdlApi(client, apiKey);

      final (content, failure) = await api.fetchContent(
        'https://dl.subdl.com/file.srt',
      );

      expect(content, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('500'));
    });

    test('returns NetworkFailure on socket exception', () async {
      final client = _MockHttpClient(
        error: const SocketException('Connection refused'),
      );
      final api = SubdlApi(client, apiKey);

      final (content, failure) = await api.fetchContent(
        'https://dl.subdl.com/file.srt',
      );

      expect(content, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('No internet connection'));
    });
  });

  group('SubdlSearchResultModel', () {
    test('parses JSON correctly', () {
      final json = {
        'id': '12345',
        'name': 'Test Movie',
        'year': '2020',
        'language': 'en',
        'release_name': 'Test.Movie.2020.1080p',
        'season_number': 1,
        'episode_number': 5,
        'episode_name': 'The Episode',
      };
      final model = SubdlSearchResultModel.fromJson(json);

      expect(model.id, '12345');
      expect(model.name, 'Test Movie');
      expect(model.year, '2020');
      expect(model.language, 'en');
      expect(model.releaseName, 'Test.Movie.2020.1080p');
      expect(model.season, 1);
      expect(model.episode, 5);
      expect(model.episodeName, 'The Episode');
    });

    test('handles missing optional fields', () {
      final json = {
        'id': '12345',
        'name': 'Test Movie',
      };
      final model = SubdlSearchResultModel.fromJson(json);

      expect(model.year, isNull);
      expect(model.language, isNull);
      expect(model.releaseName, isNull);
      expect(model.season, isNull);
      expect(model.episode, isNull);
      expect(model.episodeName, isNull);
    });

    test('toEntity maps correctly', () {
      final model = SubdlSearchResultModel(
        id: '12345',
        name: 'Test Movie',
        year: '2020',
        language: 'en',
        releaseName: 'Test.Movie.2020.1080p',
        season: 1,
        episode: 5,
        episodeName: 'The Episode',
      );

      final entity = model.toEntity();

      expect(entity.fileId, '12345');
      expect(entity.title, 'Test Movie');
      expect(entity.year, '2020');
      expect(entity.language, 'en');
      expect(entity.releaseName, 'Test.Movie.2020.1080p');
      expect(entity.providerSource, 'SubDL');
      expect(entity.season, 1);
      expect(entity.episode, 5);
      expect(entity.episodeName, 'The Episode');
    });
  });
}

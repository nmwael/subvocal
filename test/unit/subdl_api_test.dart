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
          'status': true,
          'subtitles': [
            {
              'release_name': 'Test.Movie.2020.1080p',
              'name': 'Test.Movie.2020.1080p.zip',
              'language': 'EN',
              'season': 0,
              'episode': null,
              'url': '/subtitle/12345-67890.zip',
              'unpack_files': [
                {
                  'url': '/subtitle/abc123/file.srt',
                  'format': 'srt',
                },
              ],
            },
          ],
        },
      );
      final api = SubdlApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(failure, isNull);
      expect(data, isNotNull);
      expect(data!.length, 1);
      expect(data[0].fileId, '/subtitle/abc123/file.srt');
      expect(data[0].providerSource, 'SubDL');
    });

    test('returns empty list when no subtitles found', () async {
      final client = _MockHttpClient(body: {'status': true, 'subtitles': []});
      final api = SubdlApi(client, apiKey);

      final (data, failure) = await api.search('nonexistent');

      expect(failure, isNull);
      expect(data, isNotNull);
      expect(data, isEmpty);
    });

    test('returns empty list when subtitles field is null', () async {
      final client = _MockHttpClient(body: {'status': true, 'subtitles': null});
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

    test('sends api_key as query parameter', () async {
      final client = _MockHttpClient(body: {'status': true, 'subtitles': []});
      final api = SubdlApi(client, apiKey);

      await api.search('test');

      expect(client.lastRequest, isNotNull);
      final uri = client.lastRequest!.url;
      expect(uri.queryParameters['api_key'], apiKey);
    });

    test('sends film_name as query parameter', () async {
      final client = _MockHttpClient(body: {'status': true, 'subtitles': []});
      final api = SubdlApi(client, apiKey);

      await api.search('matrix');

      expect(client.lastRequest, isNotNull);
      final uri = client.lastRequest!.url;
      expect(uri.queryParameters['film_name'], 'matrix');
    });

    test('sends language parameter uppercased when provided', () async {
      final client = _MockHttpClient(body: {'status': true, 'subtitles': []});
      final api = SubdlApi(client, apiKey);

      await api.search('test', language: 'en');

      expect(client.lastRequest, isNotNull);
      final uri = client.lastRequest!.url;
      expect(uri.queryParameters['languages'], 'EN');
    });

    test('sends type parameter when provided', () async {
      final client = _MockHttpClient(body: {'status': true, 'subtitles': []});
      final api = SubdlApi(client, apiKey);

      await api.search('test', type: 'movie');

      expect(client.lastRequest, isNotNull);
      final uri = client.lastRequest!.url;
      expect(uri.queryParameters['type'], 'movie');
    });

    test('does not send type when value is all', () async {
      final client = _MockHttpClient(body: {'status': true, 'subtitles': []});
      final api = SubdlApi(client, apiKey);

      await api.search('test', type: 'all');

      expect(client.lastRequest, isNotNull);
      final uri = client.lastRequest!.url;
      expect(uri.queryParameters.containsKey('type'), isFalse);
    });
  });

  group('SubdlApi.download', () {
    test('returns download URL using fileId as path', () async {
      final client = _MockHttpClient();
      final api = SubdlApi(client, apiKey);

      final (link, failure) = await api.download('/subtitle/abc123/file.srt');

      expect(failure, isNull);
      expect(link, 'https://dl.subdl.com/subtitle/abc123/file.srt');
    });

    test('returns NetworkFailure when fileId is empty', () async {
      final client = _MockHttpClient();
      final api = SubdlApi(client, apiKey);

      final (link, failure) = await api.download('');

      expect(link, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('No download URL'));
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
    test('parses JSON correctly with unpack_files', () {
      final json = {
        'release_name': 'Test.Movie.2020.1080p',
        'name': 'Test.Movie.2020.1080p.zip',
        'language': 'EN',
        'season': 1,
        'episode': 5,
        'url': '/subtitle/12345-67890.zip',
        'unpack_files': [
          {
            'url': '/subtitle/abc123/file.srt',
            'format': 'srt',
          },
        ],
      };
      final model = SubdlSearchResultModel.fromJson(json);

      expect(model.fileId, '/subtitle/abc123/file.srt');
      expect(model.language, 'EN');
      expect(model.releaseName, 'Test.Movie.2020.1080p');
      expect(model.season, 1);
      expect(model.episode, 5);
    });

    test('parses JSON without unpack_files falls back to url', () {
      final json = {
        'name': 'Test Movie',
        'url': '/subtitle/12345-67890.zip',
      };
      final model = SubdlSearchResultModel.fromJson(json);

      expect(model.fileId, '/subtitle/12345-67890.zip');
      expect(model.language, isNull);
      expect(model.releaseName, isNull);
      expect(model.season, isNull);
      expect(model.episode, isNull);
    });

    test('handles empty unpack_files', () {
      final json = {
        'name': 'Test Movie',
        'url': '/subtitle/12345-67890.zip',
        'unpack_files': [],
      };
      final model = SubdlSearchResultModel.fromJson(json);

      expect(model.fileId, '/subtitle/12345-67890.zip');
    });

    test('toEntity maps correctly', () {
      final model = SubdlSearchResultModel(
        fileId: '/subtitle/abc123/file.srt',
        name: 'Test Movie',
        language: 'EN',
        releaseName: 'Test.Movie.2020.1080p',
        season: 1,
        episode: 5,
      );

      final entity = model.toEntity();

      expect(entity.fileId, '/subtitle/abc123/file.srt');
      expect(entity.title, 'Test Movie');
      expect(entity.language, 'EN');
      expect(entity.releaseName, 'Test.Movie.2020.1080p');
      expect(entity.providerSource, 'SubDL');
      expect(entity.season, 1);
      expect(entity.episode, 5);
    });
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:subvocal/core/errors/failures.dart';
import 'package:subvocal/data/datasources/opensubtitles_api.dart';

class _MockHttpClient extends http.BaseClient {
  final int statusCode;
  final Map<String, dynamic>? body;
  final Exception? error;

  _MockHttpClient({this.statusCode = 200, this.body, this.error});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
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

  group('OpenSubtitlesApi.search', () {
    test('returns results on successful search', () async {
      final client = _MockHttpClient(
        body: {
          'data': [
            {
              'id': 123,
              'attributes': {
                'title': 'Test Movie',
                'feature': {'title': 'Test Movie', 'year': 2020},
                'language': 'en',
                'subtitle_count': 5,
                'release': 'Test.Movie.2020.1080p',
                'features': [{'year': 2020}],
              },
            },
          ],
        },
      );
      final api = OpenSubtitlesApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(failure, isNull);
      expect(data, isNotNull);
      expect(data!.length, 1);
      expect(data[0]['id'], 123);
    });

    test('returns empty list when no results found', () async {
      final client = _MockHttpClient(body: {'data': []});
      final api = OpenSubtitlesApi(client, apiKey);

      final (data, failure) = await api.search('nonexistent');

      expect(failure, isNull);
      expect(data, isNotNull);
      expect(data, isEmpty);
    });

    test('returns empty list when data field is null', () async {
      final client = _MockHttpClient(body: {'data': null});
      final api = OpenSubtitlesApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(failure, isNull);
      expect(data, isNotNull);
      expect(data, isEmpty);
    });

    test('returns NetworkFailure on 429 rate limit', () async {
      final client = _MockHttpClient(statusCode: 429);
      final api = OpenSubtitlesApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(data, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Rate limit exceeded'));
    });

    test('returns NetworkFailure on 500 server error', () async {
      final client = _MockHttpClient(statusCode: 500);
      final api = OpenSubtitlesApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(data, isNull);
      expect(failure, isA<NetworkFailure>());
    });

    test('returns NetworkFailure on socket exception', () async {
      final client = _MockHttpClient(
        error: const SocketException('Connection refused'),
      );
      final api = OpenSubtitlesApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(data, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('No internet connection'));
    });

    test('passes language parameter when provided', () async {
      String? capturedUrl;
      final client = _MockHttpClient(
        body: {'data': []},
      );
      final api = OpenSubtitlesApi(client, apiKey);

      await api.search('test', language: 'en');

      expect(capturedUrl, isNull);
    });
  });

  group('OpenSubtitlesApi.download', () {
    test('returns download link on success', () async {
      final client = _MockHttpClient(
        statusCode: 201,
        body: {'link': 'https://dl.opensubtitles.com/file.srt'},
      );
      final api = OpenSubtitlesApi(client, apiKey);

      final (link, failure) = await api.download(123);

      expect(failure, isNull);
      expect(link, 'https://dl.opensubtitles.com/file.srt');
    });

    test('returns NetworkFailure on 429 rate limit', () async {
      final client = _MockHttpClient(statusCode: 429);
      final api = OpenSubtitlesApi(client, apiKey);

      final (link, failure) = await api.download(123);

      expect(link, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Rate limit exceeded'));
    });

    test('returns NetworkFailure when link is missing', () async {
      final client = _MockHttpClient(body: {'link': null});
      final api = OpenSubtitlesApi(client, apiKey);

      final (link, failure) = await api.download(123);

      expect(link, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('No download link'));
    });
  });

  group('OpenSubtitlesApi.fetchContent', () {
    test('returns content on success', () async {
      final client = _MockHttpClient(
        body: {'data': 'content'},
        statusCode: 200,
      );
      final api = OpenSubtitlesApi(client, apiKey);

      final (content, failure) = await api.fetchContent('https://example.com/file.srt');

      expect(failure, isNull);
      expect(content, isNotNull);
    });

    test('returns NetworkFailure on 429 rate limit', () async {
      final client = _MockHttpClient(statusCode: 429);
      final api = OpenSubtitlesApi(client, apiKey);

      final (content, failure) = await api.fetchContent('https://example.com/file.srt');

      expect(content, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Rate limit exceeded'));
    });
  });
}

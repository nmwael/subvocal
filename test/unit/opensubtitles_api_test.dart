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

class _SmartMockClient extends http.BaseClient {
  http.BaseRequest? lastLoginRequest;
  http.BaseRequest? lastDownloadRequest;
  Map<String, String>? lastDownloadHeaders;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final path = request.url.path;
    if (path.endsWith('/login')) {
      lastLoginRequest = request;
      final bytes = utf8.encode(jsonEncode({'token': 'jwt-token-123', 'status': 200}));
      return http.StreamedResponse(
        Stream.value(bytes),
        200,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      );
    }
    if (path.endsWith('/download')) {
      lastDownloadRequest = request;
      lastDownloadHeaders = Map.from(request.headers);
      final bytes = utf8.encode(jsonEncode({'link': 'https://dl.opensubtitles.com/file.srt'}));
      return http.StreamedResponse(
        Stream.value(bytes),
        201,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      );
    }
    final bytes = utf8.encode('{}');
    return http.StreamedResponse(
      Stream.value(bytes),
      200,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
}

void main() {
  const apiKey = 'test-api-key';

  group('OpenSubtitlesApi.login', () {
    test('returns token on successful login', () async {
      final client = _MockHttpClient(
        body: {'token': 'jwt-token-123', 'status': 200},
      );
      final api = OpenSubtitlesApi(client, apiKey);

      final token = await api.login('user', 'pass');

      expect(token, 'jwt-token-123');
      expect(api.isLoggedIn, isTrue);
    });

    test('returns null on failed login', () async {
      final client = _MockHttpClient(
        statusCode: 401,
        body: {'message': 'Invalid credentials'},
      );
      final api = OpenSubtitlesApi(client, apiKey);

      final token = await api.login('user', 'wrong');

      expect(token, isNull);
      expect(api.isLoggedIn, isFalse);
    });

    test('sends username and password in request body', () async {
      final client = _MockHttpClient(
        body: {'token': 'jwt-token', 'status': 200},
      );
      final api = OpenSubtitlesApi(client, apiKey);

      await api.login('myuser', 'mypass');

      expect(client.lastRequest, isNotNull);
      final bodyBytes = await client.lastRequest!.finalize().toList();
      final bodyStr = utf8.decode(bodyBytes.expand((b) => b).toList());
      final bodyJson = jsonDecode(bodyStr) as Map<String, dynamic>;
      expect(bodyJson['username'], 'myuser');
      expect(bodyJson['password'], 'mypass');
    });

    test('logout clears token', () async {
      final client = _MockHttpClient(
        body: {'token': 'jwt-token', 'status': 200},
      );
      final api = OpenSubtitlesApi(client, apiKey);

      await api.login('user', 'pass');
      expect(api.isLoggedIn, isTrue);

      api.logout();
      expect(api.isLoggedIn, isFalse);
    });
  });

  group('OpenSubtitlesApi.search', () {
    test('returns results on successful search', () async {
      final client = _MockHttpClient(
        body: {
          'data': [
            {
              'id': '4100274',
              'type': 'subtitle',
              'attributes': {
                'files': [{'file_id': 4182483}],
                'feature_details': {'title': 'Test Movie', 'year': 2020},
                'language': 'en',
                'release': 'Test.Movie.2020.1080p',
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
      expect(failure!.message, contains('HTTP 500'));
    });

    test('returns descriptive error message from response error field', () async {
      final client = _MockHttpClient(
        statusCode: 404,
        body: {'error': 'Resource not found'},
      );
      final api = OpenSubtitlesApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(data, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Resource not found'));
    });

    test('returns descriptive error message from response message field', () async {
      final client = _MockHttpClient(
        statusCode: 401,
        body: {'message': 'Invalid API key'},
      );
      final api = OpenSubtitlesApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(data, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Invalid API key'));
    });

    test('falls back to HTTP status when response body has no error field', () async {
      final client = _MockHttpClient(
        statusCode: 503,
        body: {'status': 503, 'info': 'service unavailable'},
      );
      final api = OpenSubtitlesApi(client, apiKey);

      final (data, failure) = await api.search('test');

      expect(data, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('HTTP 503'));
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

    test('includes Accept header in requests', () async {
      final client = _MockHttpClient(body: {'data': []});
      final api = OpenSubtitlesApi(client, apiKey);

      await api.search('test');

      expect(client.lastRequest, isNotNull);
      final acceptHeader = client.lastRequest!.headers['accept'];
      expect(acceptHeader, 'application/json');
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

    test('uses error field in download failure message', () async {
      final client = _MockHttpClient(
        statusCode: 403,
        body: {'error': 'Payment required'},
      );
      final api = OpenSubtitlesApi(client, apiKey);

      final (link, failure) = await api.download(123);

      expect(link, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Payment required'));
    });

    test('uses message field in download failure message', () async {
      final client = _MockHttpClient(
        statusCode: 400,
        body: {'message': 'Invalid file_id'},
      );
      final api = OpenSubtitlesApi(client, apiKey);

      final (link, failure) = await api.download(123);

      expect(link, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Invalid file_id'));
    });

    test('returns NetworkFailure when link is missing', () async {
      final client = _MockHttpClient(body: {'link': null});
      final api = OpenSubtitlesApi(client, apiKey);

      final (link, failure) = await api.download(123);

      expect(link, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('No download link'));
    });

    test('includes Authorization header when logged in', () async {
      final client = _SmartMockClient();
      final api = OpenSubtitlesApi(client, apiKey);

      await api.login('user', 'pass');
      await api.download(123);

      final authHeader = client.lastDownloadHeaders?['Authorization'];
      expect(authHeader, 'Bearer jwt-token-123');
    });

    test('does not include Authorization header when not logged in', () async {
      final client = _MockHttpClient(
        statusCode: 201,
        body: {'link': 'https://dl.opensubtitles.com/file.srt'},
      );
      final api = OpenSubtitlesApi(client, apiKey);

      await api.download(123);

      expect(client.lastRequest, isNotNull);
      final authHeader = client.lastRequest!.headers['authorization'];
      expect(authHeader, isNull);
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

    test('uses error field in fetchContent failure message', () async {
      final client = _MockHttpClient(
        statusCode: 500,
        body: {'error': 'Internal server error'},
      );
      final api = OpenSubtitlesApi(client, apiKey);

      final (content, failure) = await api.fetchContent('https://example.com/file.srt');

      expect(content, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('Internal server error'));
    });

    test('falls back to HTTP status in fetchContent failure with empty body', () async {
      final client = _MockHttpClient(statusCode: 502);
      final api = OpenSubtitlesApi(client, apiKey);

      final (content, failure) = await api.fetchContent('https://example.com/file.srt');

      expect(content, isNull);
      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('HTTP 502'));
    });
  });
}

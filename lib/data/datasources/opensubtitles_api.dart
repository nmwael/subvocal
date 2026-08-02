import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/utils/api_error_parser.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/errors/failures.dart';
import '../../domain/repositories/subtitle_provider.dart';
import '../models/search_result_model.dart';

class UserAccountInfo {
  final String level;
  final int remainingDownloads;
  final int allowedDownloads;

  const UserAccountInfo({
    required this.level,
    required this.remainingDownloads,
    required this.allowedDownloads,
  });

  String get summary =>
      '$level — $remainingDownloads/$allowedDownloads downloads remaining today';
}

class OpenSubtitlesApi implements SubtitleProvider {
  static const _baseUrl = 'https://api.opensubtitles.com/api/v1';
  final http.Client _client;
  final String _apiKey;
  String? _token;
  UserAccountInfo? _accountInfo;

  OpenSubtitlesApi(this._client, this._apiKey);

  @override
  String get name => 'OpenSubtitles';

  UserAccountInfo? get accountInfo => _accountInfo;

  Map<String, String> get _baseHeaders => {
    'Api-Key': _apiKey,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'subvocal v1.0',
  };

  bool get isLoggedIn => _token != null;

  String _extractErrorMessage(String body, int statusCode) =>
      extractApiErrorMessage(body, statusCode);

  Future<String?> login(String username, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/login'),
        headers: _baseHeaders,
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      _token = body['token'] as String?;

      final user = body['user'] as Map<String, dynamic>?;
      if (user != null) {
        _accountInfo = UserAccountInfo(
          level: user['level'] as String? ?? 'free',
          remainingDownloads: user['remaining_downloads'] as int? ?? 0,
          allowedDownloads: user['allowed_downloads'] as int? ?? 5,
        );
      }

      return _token;
    } catch (e) {
      appLogger.error('Login failed', source: 'OpenSubtitlesApi', error: e);
      return null;
    }
  }

  void logout() {
    _token = null;
    _accountInfo = null;
  }

  void setToken(String token) {
    _token = token;
  }

  Future<bool> validateToken() async {
    if (_token == null) return false;
    try {
      final headers = <String, String>{
        ..._baseHeaders,
        'Authorization': 'Bearer $_token',
      };
      final response = await _client.get(
        Uri.parse('$_baseUrl/infos/user'),
        headers: headers,
      );
      if (response.statusCode != 200) return false;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      if (data != null) {
        _accountInfo = UserAccountInfo(
          level: data['level'] as String? ?? 'free',
          remainingDownloads: data['remaining_downloads'] as int? ?? 0,
          allowedDownloads: data['allowed_downloads'] as int? ?? 5,
        );
      }
      return true;
    } catch (e) {
      appLogger.error(
        'Token validation failed',
        source: 'OpenSubtitlesApi',
        error: e,
      );
      return false;
    }
  }

  @override
  Future<(List<SearchResult>?, Failure?)> search(
    String query, {
    String? language,
    String? type,
  }) async {
    try {
      final params = <String, String>{'query': query};
      if (language != null && language.isNotEmpty) {
        params['languages'] = language;
      }
      if (type != null && type.isNotEmpty && type != 'all') {
        params['type'] = type;
      }
      final uri = Uri.parse(
        '$_baseUrl/subtitles',
      ).replace(queryParameters: params);
      final response = await _client.get(uri, headers: _baseHeaders);
      if (response.statusCode == 429) {
        return (
          null,
          const NetworkFailure(
            'Rate limit exceeded. Please wait before trying again.',
          ),
        );
      }
      if (response.statusCode != 200) {
        return (
          null,
          NetworkFailure(
            'Search failed: ${_extractErrorMessage(response.body, response.statusCode)}',
          ),
        );
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>?;
      if (data == null || data.isEmpty) {
        return (<SearchResult>[], null);
      }
      final results = data.cast<Map<String, dynamic>>().map((item) {
        final model = SearchResultModel.fromJson(item);
        return model.toEntity();
      }).toList();
      return (results, null);
    } on SocketException catch (e) {
      return (null, NetworkFailure('No internet connection: $e'));
    } catch (e) {
      return (null, NetworkFailure('Search error: $e'));
    }
  }

  @override
  Future<(String?, Failure?)> download(dynamic fileId) async {
    try {
      final headers = <String, String>{..._baseHeaders};
      if (_token != null) headers['Authorization'] = 'Bearer $_token';
      final response = await _client.post(
        Uri.parse('$_baseUrl/download'),
        headers: headers,
        body: jsonEncode({'file_id': fileId}),
      );
      if (response.statusCode == 429) {
        return (
          null,
          const NetworkFailure(
            'Rate limit exceeded. Please wait before trying again.',
          ),
        );
      }
      if (response.statusCode != 200 && response.statusCode != 201) {
        return (
          null,
          NetworkFailure(
            'Download failed: ${_extractErrorMessage(response.body, response.statusCode)}',
          ),
        );
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final link = body['link'] as String?;
      if (link == null) {
        return (null, const NetworkFailure('No download link in response'));
      }
      return (link, null);
    } on SocketException catch (e) {
      return (null, NetworkFailure('No internet connection: $e'));
    } catch (e) {
      return (null, NetworkFailure('Download error: $e'));
    }
  }

  @override
  Future<(String?, Failure?)> fetchContent(String url) async {
    try {
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode == 429) {
        return (
          null,
          const NetworkFailure(
            'Rate limit exceeded. Please wait before trying again.',
          ),
        );
      }
      if (response.statusCode != 200) {
        return (
          null,
          NetworkFailure(
            'Fetch failed: ${_extractErrorMessage(response.body, response.statusCode)}',
          ),
        );
      }
      final bytes = response.bodyBytes;
      String content;
      try {
        content = utf8.decode(bytes);
      } on FormatException {
        content = latin1.decode(bytes);
      }
      return (content, null);
    } on SocketException catch (e) {
      return (null, NetworkFailure('No internet connection: $e'));
    } catch (e) {
      return (null, NetworkFailure('Fetch error: $e'));
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/errors/failures.dart';

class OpenSubtitlesApi {
  static const _baseUrl = 'https://api.opensubtitles.com/api/v2';
  final http.Client _client;
  final String _apiKey;

  OpenSubtitlesApi(this._client, this._apiKey);

  String _extractErrorMessage(String body, int statusCode) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final msg = (json['error'] as String?) ?? (json['message'] as String?);
      if (msg != null && msg.isNotEmpty) return msg;
    } catch (_) {}
    return 'HTTP $statusCode';
  }

  Future<(List<Map<String, dynamic>>?, Failure?)> search(String query, {String? language}) async {
    try {
      final params = <String, String>{'query': query};
      if (language != null && language.isNotEmpty) {
        params['languages'] = language;
      }
      final uri = Uri.parse('$_baseUrl/subtitles').replace(queryParameters: params);
      final response = await _client.get(
        uri,
        headers: {
          'Api-Key': _apiKey,
          'Content-Type': 'application/json',
          'User-Agent': 'subvocal v1.0',
        },
      );
      if (response.statusCode == 429) {
        return (null, const NetworkFailure('Rate limit exceeded. Please wait before trying again.'));
      }
      if (response.statusCode != 200) {
        return (null, NetworkFailure('Search failed: ${_extractErrorMessage(response.body, response.statusCode)}'));
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>?;
      if (data == null || data.isEmpty) {
        return (<Map<String, dynamic>>[], null);
      }
      return (data.cast<Map<String, dynamic>>(), null);
    } on SocketException catch (e) {
      return (null, NetworkFailure('No internet connection: $e'));
    } catch (e) {
      return (null, NetworkFailure('Search error: $e'));
    }
  }

  Future<(String?, Failure?)> download(int fileId) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/download'),
        headers: {
          'Api-Key': _apiKey,
          'Content-Type': 'application/json',
          'User-Agent': 'subvocal v1.0',
        },
        body: jsonEncode({'file_id': fileId}),
      );
      if (response.statusCode == 429) {
        return (null, const NetworkFailure('Rate limit exceeded. Please wait before trying again.'));
      }
      if (response.statusCode != 200 && response.statusCode != 201) {
        return (null, NetworkFailure('Download failed: ${_extractErrorMessage(response.body, response.statusCode)}'));
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

  Future<(String?, Failure?)> fetchContent(String url) async {
    try {
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode == 429) {
        return (null, const NetworkFailure('Rate limit exceeded. Please wait before trying again.'));
      }
      if (response.statusCode != 200) {
        return (null, NetworkFailure('Fetch failed: ${_extractErrorMessage(response.body, response.statusCode)}'));
      }
      return (response.body, null);
    } on SocketException catch (e) {
      return (null, NetworkFailure('No internet connection: $e'));
    } catch (e) {
      return (null, NetworkFailure('Fetch error: $e'));
    }
  }
}

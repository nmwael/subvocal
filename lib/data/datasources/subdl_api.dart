import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../domain/entities/search_result.dart';
import '../../domain/errors/failures.dart';
import '../../domain/repositories/subtitle_provider.dart';

class SubdlApi implements SubtitleProvider {
  static const _baseUrl = 'https://api.subdl.com/api/v1';
  final http.Client _client;
  final String _apiKey;

  SubdlApi(this._client, this._apiKey);

  @override
  String get name => 'SubDL';

  Map<String, String> get _baseHeaders => {
    'Authorization': _apiKey,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

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
        return (null, NetworkFailure('Search failed: ${response.statusCode}'));
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final subtitles = body['subtitles'] as List<dynamic>?;
      if (subtitles == null || subtitles.isEmpty) {
        return (<SearchResult>[], null);
      }

      final results = subtitles.map((item) {
        final model = SubdlSearchResultModel.fromJson(item);
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
      final response = await _client.post(
        Uri.parse('$_baseUrl/download'),
        headers: _baseHeaders,
        body: jsonEncode({'subtitle_id': fileId}),
      );

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
          NetworkFailure('Download failed: ${response.statusCode}'),
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final url = body['url'] as String?;
      if (url == null) {
        return (null, const NetworkFailure('No download URL in response'));
      }

      final fullUrl = 'https://dl.subdl.com$url';
      return (fullUrl, null);
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
        return (null, NetworkFailure('Fetch failed: ${response.statusCode}'));
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

class SubdlSearchResultModel {
  final String id;
  final String name;
  final String? year;
  final String? language;
  final String? releaseName;

  SubdlSearchResultModel({
    required this.id,
    required this.name,
    this.year,
    this.language,
    this.releaseName,
  });

  factory SubdlSearchResultModel.fromJson(Map<String, dynamic> json) {
    return SubdlSearchResultModel(
      id: json['id'] as String,
      name: json['name'] as String,
      year: json['year'] as String?,
      language: json['language'] as String?,
      releaseName: json['release_name'] as String?,
    );
  }

  SearchResult toEntity() {
    return SearchResult(
      fileId: id,
      title: name,
      year: year,
      language: language,
      releaseName: releaseName,
      providerSource: 'SubDL',
    );
  }
}

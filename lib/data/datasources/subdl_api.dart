import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../domain/entities/search_result.dart';
import '../../domain/errors/failures.dart';
import '../../domain/repositories/subtitle_provider.dart';

class SubdlApi implements SubtitleProvider {
  static const _baseUrl = 'https://api.subdl.com/api/v1';
  static const _dlBaseUrl = 'https://dl.subdl.com';
  final http.Client _client;
  final String _apiKey;

  SubdlApi(this._client, this._apiKey);

  @override
  String get name => 'SubDL';

  Map<String, String> get _baseHeaders => {
    'Accept': 'application/json',
  };

  @override
  Future<(List<SearchResult>?, Failure?)> search(
    String query, {
    String? language,
    String? type,
  }) async {
    try {
      final params = <String, String>{
        'api_key': _apiKey,
        'film_name': query,
        'unpack': '1',
      };
      if (language != null && language.isNotEmpty) {
        params['languages'] = language.toUpperCase();
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
      if (body['status'] != true) {
        return (null, NetworkFailure('Search failed: ${body['error']}'));
      }

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
      final url = fileId as String;
      if (url.isEmpty) {
        return (null, const NetworkFailure('No download URL'));
      }
      final fullUrl = '$_dlBaseUrl$url';
      return (fullUrl, null);
    } catch (e) {
      return (null, NetworkFailure('Download error: $e'));
    }
  }

  @override
  Future<(String?, Failure?)> fetchContent(String url) async {
    try {
      final response = await _client.get(Uri.parse(url), headers: _baseHeaders);

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
  final String fileId;
  final String name;
  final String? language;
  final String? releaseName;
  final int? season;
  final int? episode;

  SubdlSearchResultModel({
    required this.fileId,
    required this.name,
    this.language,
    this.releaseName,
    this.season,
    this.episode,
  });

  factory SubdlSearchResultModel.fromJson(Map<String, dynamic> json) {
    final unpackFiles = json['unpack_files'] as List<dynamic>?;
    final fileId = (unpackFiles != null && unpackFiles.isNotEmpty)
        ? (unpackFiles[0] as Map<String, dynamic>)['url'] as String?
        : null;
    return SubdlSearchResultModel(
      fileId: fileId ?? json['url'] as String? ?? '',
      name: json['name'] as String? ?? '',
      language: json['language'] as String?,
      releaseName: json['release_name'] as String?,
      season: json['season'] as int?,
      episode: json['episode'] as int?,
    );
  }

  SearchResult toEntity() {
    return SearchResult(
      fileId: fileId,
      title: name,
      language: language,
      releaseName: releaseName,
      providerSource: 'SubDL',
      season: season,
      episode: episode,
    );
  }
}

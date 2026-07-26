import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../domain/entities/search_result.dart';
import '../../domain/errors/failures.dart';
import '../../domain/repositories/subtitle_provider.dart';

class PodnapisiApi implements SubtitleProvider {
  static const _baseUrl = 'https://www.podnapisi.net/ppodnapisi';
  final http.Client _client;

  PodnapisiApi(this._client);

  @override
  String get name => 'Podnapisi';

  @override
  Future<(List<SearchResult>?, Failure?)> search(
    String query, {
    String? language,
    String? type,
  }) async {
    try {
      final params = <String, String>{'sK': query};
      if (language != null && language.isNotEmpty) {
        params['sJ'] = language;
      }
      if (type != null && type.isNotEmpty && type != 'all') {
        params['sT'] = type;
      }
      final uri = Uri.parse(
        '$_baseUrl/search',
      ).replace(queryParameters: params);
      final response = await _client.get(uri);

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
      final subtitles = body['data'] as List<dynamic>?;
      if (subtitles == null || subtitles.isEmpty) {
        return (<SearchResult>[], null);
      }

      final results = subtitles.map((item) {
        final model = PodnapisiSearchResultModel.fromJson(item);
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
      final response = await _client.get(
        Uri.parse('https://www.podnapisi.net/subtitles/$fileId/download'),
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

      final bytes = response.bodyBytes;
      return (base64Encode(bytes), null);
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

class PodnapisiSearchResultModel {
  final int id;
  final String name;
  final String? year;
  final String? language;
  final String? releaseName;

  PodnapisiSearchResultModel({
    required this.id,
    required this.name,
    this.year,
    this.language,
    this.releaseName,
  });

  factory PodnapisiSearchResultModel.fromJson(Map<String, dynamic> json) {
    return PodnapisiSearchResultModel(
      id: json['id'] as int,
      name: json['name'] as String,
      year: json['year']?.toString(),
      language: json['lang'] as String?,
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
      providerSource: 'Podnapisi',
    );
  }
}

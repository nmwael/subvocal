import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/search_result.dart';
import '../../domain/errors/failures.dart';
import '../../domain/repositories/subtitle_provider.dart';

class SubdlApi implements SubtitleProvider {
  static const _baseUrl = 'https://api.subdl.com/api/v1';
  static const _dlBaseUrl = 'https://dl.subdl.com';

  /// Hard limits guarding against zip bombs / OOM on mobile (CWE-409).
  /// Subtitle downloads are user-uploaded content, so a small malicious
  /// archive could otherwise expand to hundreds of MB.
  static const _maxCompressedBytes = 10 * 1024 * 1024; // 10 MB compressed
  static const _maxArchiveFiles = 20; // max entries per archive
  static const _maxFileBytes = 5 * 1024 * 1024; // 5 MB per decompressed file
  static const _maxTotalDecompressedBytes = 20 * 1024 * 1024; // 20 MB total

  static const _requestTimeout = Duration(seconds: 20);

  final http.Client _client;
  final String _apiKey;

  SubdlApi(this._client, this._apiKey);

  @override
  String get name => 'SubDL';

  Map<String, String> get _baseHeaders => {'Accept': 'application/json'};

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
      final response = await _client
          .get(uri, headers: _baseHeaders)
          .timeout(_requestTimeout);

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
    } on TimeoutException {
      return (null, const NetworkFailure('Search timed out'));
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
      final response = await _client
          .get(Uri.parse(url), headers: _baseHeaders)
          .timeout(_requestTimeout);

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
      // Guard 1: cap the compressed payload size before any decompression.
      if (bytes.length > _maxCompressedBytes) {
        return (null, const NetworkFailure('Subtitle download too large'));
      }

      String content;
      if (bytes.length >= 4 &&
          bytes[0] == 0x50 &&
          bytes[1] == 0x4B &&
          bytes[2] == 0x03 &&
          bytes[3] == 0x04) {
        // SubDL serves subtitle downloads as ZIP archives. Extract the first
        // .srt file (fallback: .sub) and decode it instead of trying to read
        // the binary payload as text.
        final archive = ZipDecoder().decodeBytes(bytes);

        // Guard 2: cap the number of entries in the archive.
        if (archive.files.length > _maxArchiveFiles) {
          return (
            null,
            const NetworkFailure('Subtitle archive has too many files'),
          );
        }

        // Guard 3: cap per-file and total decompressed sizes (zip-bomb guard).
        //
        // Pass 1 — size checks from the central directory (no full
        // materialization). `ArchiveFile.size` is populated by `ZipDecoder`
        // from the zip header's declared uncompressed size, so a single tiny
        // compressed entry that *declares* a huge size is rejected here
        // without ever touching `file.content` (touching it is what triggers
        // decompression into memory). Some encoders write 0 for the declared
        // size; in that case fall back to the materialized content length as a
        // backstop (a genuinely 0-byte file is below the cap, so it passes).
        var totalDecompressedBytes = 0;
        for (final file in archive.files) {
          final declared = file.size > 0 ? file.size : file.content.length;
          if (declared > _maxFileBytes) {
            return (null, const NetworkFailure('Subtitle file too large'));
          }
          totalDecompressedBytes += declared;
        }
        if (totalDecompressedBytes > _maxTotalDecompressedBytes) {
          return (null, const NetworkFailure('Subtitle archive too large'));
        }

        // Pass 2 — pick and decode the subtitle file. Keep a per-file
        // backstop on the materialized bytes: declared sizes can be
        // unreliable, and by this point only the picked file is decompressed.
        final subtitleFile = _pickSubtitleFile(archive);
        if (subtitleFile == null) {
          content = '';
        } else {
          final contentBytes = subtitleFile.content as List<int>;
          if (contentBytes.length > _maxFileBytes) {
            return (null, const NetworkFailure('Subtitle file too large'));
          }
          try {
            content = utf8.decode(contentBytes);
          } on FormatException {
            content = latin1.decode(contentBytes);
          }
        }
      } else {
        try {
          content = utf8.decode(bytes);
        } on FormatException {
          content = latin1.decode(bytes);
        }
      }

      return (content, null);
    } on TimeoutException {
      return (null, const NetworkFailure('Fetch timed out'));
    } on SocketException catch (e) {
      return (null, NetworkFailure('No internet connection: $e'));
    } catch (e) {
      return (null, NetworkFailure('Fetch error: $e'));
    }
  }

  /// Picks the subtitle file inside a ZIP archive: the first file whose name
  /// ends in `.srt`, falling back to `.sub`. Returns null if the archive
  /// contains neither (no content is returned in that case).
  static ArchiveFile? _pickSubtitleFile(Archive archive) {
    for (final file in archive.files) {
      if (file.name.endsWith('.srt')) return file;
    }
    for (final file in archive.files) {
      if (file.name.endsWith('.sub')) return file;
    }
    return null;
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
    final unpackFiles = json['unpack_files'];
    String? fileId;
    if (unpackFiles is List && unpackFiles.isNotEmpty) {
      // Prefer the first unpack_file that is (or points to) an .srt subtitle,
      // since SubDL serves the actual subtitles as direct .srt files.
      // Malformed entries (non-map, non-string url/format) are skipped so a
      // single bad entry cannot fail the whole search.
      for (final entry in unpackFiles) {
        if (entry is! Map<String, dynamic>) continue;
        final url = entry['url'];
        final format = entry['format'];
        if (url != null && url is! String) continue;
        if (format != null && format is! String) continue;
        if (format == 'srt' || (url is String && url.endsWith('.srt'))) {
          fileId = url;
          break;
        }
      }
    }
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

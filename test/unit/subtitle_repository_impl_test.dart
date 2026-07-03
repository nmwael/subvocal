import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:subvocal/core/errors/failures.dart';
import 'package:subvocal/core/utils/srt_parser.dart';
import 'package:subvocal/data/datasources/local_file_source.dart';
import 'package:subvocal/data/datasources/opensubtitles_api.dart';
import 'package:subvocal/data/repositories/subtitle_repository_impl.dart';

class _MockHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream.value([]),
      200,
    );
  }
}

class _MockApi extends OpenSubtitlesApi {
  _MockApi() : super(_MockHttpClient(), '');

  @override
  Future<(List<Map<String, dynamic>>?, Failure?)> search(String query, {String? language}) async {
    return (null, null);
  }

  @override
  Future<(String?, Failure?)> download(int fileId) async {
    return (null, null);
  }

  @override
  Future<(String?, Failure?)> fetchContent(String url) async {
    return (null, null);
  }
}

void main() {
  late SubtitleRepositoryImpl repository;
  late LocalFileSource localFileSource;
  late SrtParser srtParser;

  setUp(() {
    localFileSource = LocalFileSource();
    srtParser = SrtParser();
    repository = SubtitleRepositoryImpl(
      api: _MockApi(),
      localFileSource: localFileSource,
      srtParser: srtParser,
    );
  });

  group('importFromFile', () {
    test('imports valid SRT file', () async {
      final tempDir = Directory.systemTemp.createTempSync('subvocal_test_');
      final file = File('${tempDir.path}/test.srt');
      await file.writeAsString('1\n00:00:01,000 --> 00:00:04,000\nHello, world!');

      final (subtitle, failure) = await repository.importFromFile(file.path);

      expect(failure, isNull);
      expect(subtitle, isNotNull);
      expect(subtitle!.title, 'test');
      expect(subtitle.entries.length, 1);
      expect(subtitle.entries[0].text, 'Hello, world!');

      await tempDir.delete(recursive: true);
    });

    test('returns failure for non-existent file', () async {
      final (subtitle, failure) = await repository.importFromFile('/nonexistent/file.srt');

      expect(subtitle, isNull);
      expect(failure, isA<FileAccessFailure>());
    });

    test('returns failure for empty file', () async {
      final tempDir = Directory.systemTemp.createTempSync('subvocal_test_');
      final file = File('${tempDir.path}/empty.srt');
      await file.writeAsString('');

      final (subtitle, failure) = await repository.importFromFile(file.path);

      expect(subtitle, isNull);
      expect(failure, isA<SrtParseFailure>());

      await tempDir.delete(recursive: true);
    });

    test('returns failure for file with no valid subtitle entries', () async {
      final tempDir = Directory.systemTemp.createTempSync('subvocal_test_');
      final file = File('${tempDir.path}/invalid.srt');
      await file.writeAsString('not a valid srt file');

      final (subtitle, failure) = await repository.importFromFile(file.path);

      expect(subtitle, isNull);
      expect(failure, isA<SrtParseFailure>());

      await tempDir.delete(recursive: true);
    });

    test('handles UTF-8 encoded file', () async {
      final tempDir = Directory.systemTemp.createTempSync('subvocal_test_');
      final file = File('${tempDir.path}/utf8.srt');
      await file.writeAsString(
        '1\n00:00:01,000 --> 00:00:04,000\n\u00e9 \u00e0\n',
        encoding: utf8,
      );

      final (subtitle, failure) = await repository.importFromFile(file.path);

      expect(failure, isNull);
      expect(subtitle, isNotNull);
      expect(subtitle!.entries[0].text, '\u00e9 \u00e0');

      await tempDir.delete(recursive: true);
    });
  });
}

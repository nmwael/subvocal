import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/core/errors/failures.dart';
import 'package:subvocal/data/datasources/local_file_source.dart';

void main() {
  late LocalFileSource localFileSource;

  setUp(() {
    localFileSource = LocalFileSource();
  });

  group('LocalFileSource', () {
    test('reads existing file', () async {
      final tempDir = Directory.systemTemp.createTempSync('subvocal_test_');
      final file = File('${tempDir.path}/test.srt');
      await file.writeAsString('1\n00:00:01,000 --> 00:00:04,000\nHello');

      final (content, failure) = await localFileSource.readFile(file.path);

      expect(failure, isNull);
      expect(content, '1\n00:00:01,000 --> 00:00:04,000\nHello');

      await tempDir.delete(recursive: true);
    });

    test('returns failure for non-existent file', () async {
      final (content, failure) = await localFileSource.readFile('/nonexistent/file.srt');

      expect(content, isNull);
      expect(failure, isA<FileAccessFailure>());
      expect(failure!.message, contains('File not found'));
    });

    test('returns failure for directory path', () async {
      final tempDir = Directory.systemTemp.createTempSync('subvocal_test_');

      final (content, failure) = await localFileSource.readFile(tempDir.path);

      expect(content, isNull);
      expect(failure, isA<FileAccessFailure>());

      await tempDir.delete(recursive: true);
    });
  });
}

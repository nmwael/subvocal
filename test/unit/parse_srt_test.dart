import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/core/errors/failures.dart';
import 'package:subvocal/core/utils/srt_parser.dart';
import 'package:subvocal/domain/usecases/parse_srt.dart';

void main() {
  late SrtParser parser;
  late ParseSrt parseSrt;

  setUp(() {
    parser = SrtParser();
    parseSrt = ParseSrt(parser);
  });

  group('ParseSrt', () {
    test('returns entries for valid SRT content', () {
      const srt = '1\n00:00:01,000 --> 00:00:04,000\nHello, world!';
      final (entries, failure) = parseSrt(srt);

      expect(failure, isNull);
      expect(entries, isNotNull);
      expect(entries!.length, 1);
      expect(entries[0].index, 1);
      expect(entries[0].text, 'Hello, world!');
    });

    test('returns failure for empty content', () {
      const srt = '';
      final (entries, failure) = parseSrt(srt);

      expect(entries, isNull);
      expect(failure, isA<SrtParseFailure>());
      expect(failure!.message, 'No valid subtitle entries found');
    });

    test('returns failure for content with no valid entries', () {
      const srt = 'not a valid srt';
      final (entries, failure) = parseSrt(srt);

      expect(entries, isNull);
      expect(failure, isA<SrtParseFailure>());
      expect(failure!.message, 'No valid subtitle entries found');
    });

    test('returns failure for malformed blocks', () {
      const srt = 'garbage\n\n1\n00:00:01,000 --> 00:00:04,000\nValid';
      final (entries, failure) = parseSrt(srt);

      expect(entries, isNotNull);
      expect(failure, isNull);
      expect(entries!.length, 1);
      expect(entries[0].text, 'Valid');
    });
  });
}

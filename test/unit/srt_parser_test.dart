import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/core/utils/srt_parser.dart';

void main() {
  late SrtParser parser;

  setUp(() {
    parser = SrtParser();
  });

  group('SrtParser', () {
    test('parses a single subtitle entry', () {
      const srt = '1\n00:00:01,000 --> 00:00:04,000\nHello, world!';
      final entries = parser.parse(srt);
      expect(entries.length, 1);
      expect(entries[0].index, 1);
      expect(entries[0].start, const Duration(seconds: 1));
      expect(entries[0].end, const Duration(seconds: 4));
      expect(entries[0].text, 'Hello, world!');
    });

    test('parses multiple subtitle entries', () {
      const srt = '1\n00:00:01,000 --> 00:00:04,000\nFirst line\n\n'
          '2\n00:00:05,000 --> 00:00:08,000\nSecond line';
      final entries = parser.parse(srt);
      expect(entries.length, 2);
      expect(entries[0].index, 1);
      expect(entries[0].text, 'First line');
      expect(entries[1].index, 2);
      expect(entries[1].text, 'Second line');
    });

    test('handles multi-line text', () {
      const srt = '1\n00:00:01,000 --> 00:00:04,000\nLine one\nLine two';
      final entries = parser.parse(srt);
      expect(entries.length, 1);
      expect(entries[0].text, 'Line one\nLine two');
    });

    test('handles dot as millisecond separator', () {
      const srt = '1\n00:00:01.000 --> 00:00:04.500\nHello';
      final entries = parser.parse(srt);
      expect(entries[0].start, const Duration(seconds: 1));
      expect(entries[0].end, const Duration(milliseconds: 4500));
    });

    test('returns empty list for empty input', () {
      expect(parser.parse(''), isEmpty);
    });

    test('returns empty list for invalid input', () {
      expect(parser.parse('not a valid srt'), isEmpty);
    });

    test('skips malformed blocks', () {
      const srt = 'garbage\n\n1\n00:00:01,000 --> 00:00:04,000\nValid';
      final entries = parser.parse(srt);
      expect(entries.length, 1);
      expect(entries[0].text, 'Valid');
    });

    test('handles timestamps with hours', () {
      const srt = '1\n01:02:03,004 --> 02:03:04,005\nLong content';
      final entries = parser.parse(srt);
      expect(entries[0].start,
          const Duration(hours: 1, minutes: 2, seconds: 3, milliseconds: 4));
      expect(entries[0].end,
          const Duration(hours: 2, minutes: 3, seconds: 4, milliseconds: 5));
    });
  });

  group('SubtitleEntry', () {
    test('computes duration correctly', () {
      const srt = '1\n00:00:01,000 --> 00:00:05,000\nTest';
      final entries = parser.parse(srt);
      expect(entries[0].duration, const Duration(seconds: 4));
    });
  });
}

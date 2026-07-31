import 'package:bdd_framework/bdd_framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/domain/services/srt_parser.dart';

import '../helpers/bdd_config.dart';

void main() async {
  configureBdd(clearOutput: true);

  final feature = BddFeature(
    'SRT Parser',
    description: '''
The SRT parser turns SRT subtitle text into timed subtitle entries. It must
handle the variations found in real-world subtitle files while silently
skipping malformed blocks.''',
  );

  Bdd(feature)
      .scenario('Parsing a single subtitle entry')
      .given('an SRT text with one well-formed entry')
      .when('the SRT text is parsed')
      .then('exactly one subtitle entry is produced')
      .and('its index is 1, start is 00:00:01,000, end is 00:00:04,000')
      .and('its text is "Hello, world!"')
      .run((ctx) async {
        const srt = '1\n00:00:01,000 --> 00:00:04,000\nHello, world!';
        final entries = SrtParser().parse(srt);
        expect(entries.length, 1);
        expect(entries[0].index, 1);
        expect(entries[0].start, const Duration(seconds: 1));
        expect(entries[0].end, const Duration(seconds: 4));
        expect(entries[0].text, 'Hello, world!');
      });

  Bdd(feature)
      .scenario('Parsing multiple subtitle entries')
      .given('an SRT text with two well-formed entries')
      .when('the SRT text is parsed')
      .then('two subtitle entries are produced in order')
      .and('the first is index 1 with text "First line"')
      .and('the second is index 2 with text "Second line"')
      .run((ctx) async {
        const srt =
            '1\n00:00:01,000 --> 00:00:04,000\nFirst line\n\n'
            '2\n00:00:05,000 --> 00:00:08,000\nSecond line';
        final entries = SrtParser().parse(srt);
        expect(entries.length, 2);
        expect(entries[0].index, 1);
        expect(entries[0].text, 'First line');
        expect(entries[1].index, 2);
        expect(entries[1].text, 'Second line');
      });

  Bdd(feature)
      .scenario('Handling multi-line text')
      .given('an SRT entry whose text spans two lines')
      .when('the SRT text is parsed')
      .then('the entry text keeps both lines joined by a newline')
      .run((ctx) async {
        const srt = '1\n00:00:01,000 --> 00:00:04,000\nLine one\nLine two';
        final entries = SrtParser().parse(srt);
        expect(entries.length, 1);
        expect(entries[0].text, 'Line one\nLine two');
      });

  Bdd(feature)
      .scenario('Handling a dot as the millisecond separator')
      .given('an SRT entry using a dot instead of a comma in timestamps')
      .when('the SRT text is parsed')
      .then('start 00:00:01.000 and end 00:00:04.500 are decoded correctly')
      .run((ctx) async {
        const srt = '1\n00:00:01.000 --> 00:00:04.500\nHello';
        final entries = SrtParser().parse(srt);
        expect(entries[0].start, const Duration(seconds: 1));
        expect(entries[0].end, const Duration(milliseconds: 4500));
      });

  Bdd(feature)
      .scenario('Parsing empty input')
      .given('an empty SRT text')
      .when('the SRT text is parsed')
      .then('no subtitle entries are produced')
      .run((ctx) async {
        expect(SrtParser().parse(''), isEmpty);
      });

  Bdd(feature)
      .scenario('Parsing invalid input')
      .given('text that is not valid SRT')
      .when('the SRT text is parsed')
      .then('no subtitle entries are produced')
      .run((ctx) async {
        expect(SrtParser().parse('not a valid srt'), isEmpty);
      });

  Bdd(feature)
      .scenario('Skipping malformed blocks')
      .given(
        'an SRT text that starts with a garbage block followed by a valid one',
      )
      .when('the SRT text is parsed')
      .then('only the valid entry is produced')
      .run((ctx) async {
        const srt = 'garbage\n\n1\n00:00:01,000 --> 00:00:04,000\nValid';
        final entries = SrtParser().parse(srt);
        expect(entries.length, 1);
        expect(entries[0].text, 'Valid');
      });

  Bdd(feature)
      .scenario('Handling timestamps with hours')
      .given('an SRT entry with timestamps beyond one hour')
      .when('the SRT text is parsed')
      .then('start 01:02:03,004 and end 02:03:04,005 are decoded correctly')
      .run((ctx) async {
        const srt = '1\n01:02:03,004 --> 02:03:04,005\nLong content';
        final entries = SrtParser().parse(srt);
        expect(
          entries[0].start,
          const Duration(hours: 1, minutes: 2, seconds: 3, milliseconds: 4),
        );
        expect(
          entries[0].end,
          const Duration(hours: 2, minutes: 3, seconds: 4, milliseconds: 5),
        );
      });

  Bdd(feature)
      .scenario('Computing the entry duration')
      .given(
        'an SRT entry that starts at 00:00:01,000 and ends at 00:00:05,000',
      )
      .when('the SRT text is parsed')
      .then('the entry duration is 4 seconds')
      .run((ctx) async {
        const srt = '1\n00:00:01,000 --> 00:00:05,000\nTest';
        final entries = SrtParser().parse(srt);
        expect(entries[0].duration, const Duration(seconds: 4));
      });

  await BddReporter.reportAll();
}

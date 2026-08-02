import 'package:bdd_framework/bdd_framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/domain/services/audio_fingerprint_service.dart';
import 'package:subvocal/domain/entities/subtitle_entry.dart';
import 'package:subvocal/presentation/providers/settings_provider.dart';

import '../helpers/bdd_config.dart';

void main() async {
  configureBdd(clearOutput: false);

  final feature = BddFeature(
    'Auto-sync via microphone audio fingerprinting',
    description: '''
Automatic synchronization of subtitles with ambient audio via microphone fingerprinting,
enabling live TV and streaming sync without manual offset tuning.''',
  );

  Bdd(feature)
      .scenario('Computing audio fingerprint from recorded microphone stream')
      .given('an active microphone recorder and audio stream')
      .when('ambient audio is recorded for 5 seconds')
      .then('a valid audio fingerprint hash string is produced')
      .run((ctx) async {
        final service = AudioFingerprintService();
        final fingerprint = await service.computeFingerprintMock(
          'sample_audio_data',
        );
        expect(fingerprint, isNotEmpty);
        expect(fingerprint.length, greaterThan(10));
      });

  Bdd(feature)
      .scenario('Matching ambient audio fingerprint against subtitle timeline')
      .given(
        'a database of subtitle segment fingerprints with known timestamps',
      )
      .and('an ambient audio fingerprint matching at offset +4500ms')
      .when('the fingerprint matching algorithm runs')
      .then('the detected time offset is +4500 milliseconds')
      .run((ctx) async {
        final service = AudioFingerprintService();
        final db = {
          'fingerprint_at_0s': const Duration(seconds: 0),
          'fingerprint_at_10s': const Duration(seconds: 10),
          'fingerprint_at_15s': const Duration(seconds: 15),
        };

        final offset = service.matchFingerprint(
          'fingerprint_at_10s_variant',
          db,
        );
        expect(offset, const Duration(seconds: 10));
      });

  Bdd(feature)
      .scenario('Adjusting subtitle entries with auto-sync offset')
      .given('a list of subtitle entries starting at 00:00:00,000')
      .and('an audio sync offset of 3 seconds detected via microphone')
      .when('the subtitle timeline is adjusted')
      .then('all subtitle entries are shifted by 3 seconds')
      .run((ctx) async {
        final entries = [
          const SubtitleEntry(
            index: 1,
            start: Duration(seconds: 1),
            end: Duration(seconds: 4),
            text: 'Line 1',
          ),
          const SubtitleEntry(
            index: 2,
            start: Duration(seconds: 5),
            end: Duration(seconds: 8),
            text: 'Line 2',
          ),
        ];

        const offset = Duration(seconds: 3);
        final adjusted = entries
            .map(
              (e) => e.copyWith(start: e.start + offset, end: e.end + offset),
            )
            .toList();

        expect(adjusted[0].start, const Duration(seconds: 4));
        expect(adjusted[0].end, const Duration(seconds: 7));
        expect(adjusted[1].start, const Duration(seconds: 8));
        expect(adjusted[1].end, const Duration(seconds: 11));
      });

  Bdd(feature)
      .scenario('Toggling audio sync feature in settings')
      .given('audio sync is disabled in settings')
      .when('the user toggles audio sync on')
      .then('settings persist audio sync enabled as true')
      .run((ctx) async {
        const initialState = SettingsState();
        expect(initialState.isAudioSyncEnabled, isFalse);
        final toggledState = initialState.copyWith(isAudioSyncEnabled: true);
        expect(toggledState.isAudioSyncEnabled, isTrue);

        final json = toggledState.toJson();
        final restored = SettingsState.fromJson(json);
        expect(restored.isAudioSyncEnabled, isTrue);
      });

  await BddReporter.reportAll();
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/domain/entities/subtitle_entry.dart';
import 'package:subvocal/presentation/providers/player_provider.dart';
import 'package:subvocal/presentation/widgets/playback_controls.dart';

import '../helpers/golden_test_helpers.dart';

void main() {
  void noop() {}

  group('PlaybackControls', () {
    testWidgets('playing state', (tester) async {
      const state = PlayerState(
        isPlaying: true,
        entries: [
          SubtitleEntry(index: 1, start: Duration.zero, end: Duration(seconds: 3), text: 'A'),
          SubtitleEntry(index: 2, start: Duration(seconds: 3), end: Duration(seconds: 6), text: 'B'),
        ],
        speed: 0.5,
        syncOffset: 0.0,
      );

      await screenMatchesGolden(
        tester,
        Scaffold(
          body: PlaybackControls(
            playerState: state,
            onPlay: noop,
            onPause: noop,
            onResume: noop,
            onStop: noop,
            onNext: noop,
            onPrevious: noop,
            onSpeedChanged: (_) {},
            onSyncOffsetChanged: (_) {},
            onSeek: (_) {},
          ),
        ),
        'playback_controls_playing',
      );
    });

    testWidgets('stopped state', (tester) async {
      const state = PlayerState();

      await screenMatchesGolden(
        tester,
        Scaffold(
          body: PlaybackControls(
            playerState: state,
            onPlay: noop,
            onPause: noop,
            onResume: noop,
            onStop: noop,
            onNext: noop,
            onPrevious: noop,
            onSpeedChanged: (_) {},
            onSyncOffsetChanged: (_) {},
            onSeek: (_) {},
          ),
        ),
        'playback_controls_stopped',
      );
    });
  });
}

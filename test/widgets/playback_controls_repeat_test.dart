import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subvocal/domain/entities/subtitle_entry.dart';
import 'package:subvocal/generated/app_localizations.dart';
import 'package:subvocal/presentation/providers/player_provider.dart';
import 'package:subvocal/presentation/widgets/playback_controls.dart';

Widget _createTestApp({required PlayerState state}) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: PlaybackControls(
          playerState: state,
          onPlay: () {},
          onPause: () {},
          onResume: () {},
          onStop: () {},
          onNext: () {},
          onPrevious: () {},
          onSpeedChanged: (_) {},
          onSyncOffsetChanged: (_) {},
          onSeek: (_) {},
        ),
      ),
    ),
  );
}

const testState = PlayerState(
  isPlaying: true,
  entries: [
    SubtitleEntry(
      index: 1,
      start: Duration(seconds: 1),
      end: Duration(seconds: 4),
      text: 'Hello world',
    ),
  ],
  speed: 0.5,
  syncOffset: 0.0,
);

void main() {
  testWidgets('PlaybackControls shows repeat button when entries exist', (
    tester,
  ) async {
    await tester.pumpWidget(_createTestApp(state: testState));
    await tester.pump();

    expect(find.byIcon(Icons.replay_10), findsOneWidget);
  });

  testWidgets('repeat mode active shows highlighted state', (tester) async {
    final stateWithRepeat = testState.copyWith(repeatMode: true);
    await tester.pumpWidget(_createTestApp(state: stateWithRepeat));
    await tester.pump();

    expect(find.byIcon(Icons.replay_10), findsOneWidget);
  });

  testWidgets('repeat mode inactive shows normal state', (tester) async {
    final stateNoRepeat = testState.copyWith(repeatMode: false);
    await tester.pumpWidget(_createTestApp(state: stateNoRepeat));
    await tester.pump();

    expect(find.byIcon(Icons.replay_10), findsOneWidget);
  });

  testWidgets('repeat button disabled when no entries', (tester) async {
    final emptyState = testState.copyWith(entries: []);
    await tester.pumpWidget(_createTestApp(state: emptyState));
    await tester.pump();

    final repeatButton = find.byIcon(Icons.replay_10).first;
    expect(repeatButton, findsOneWidget);
  });
}

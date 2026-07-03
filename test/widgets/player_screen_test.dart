import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:subvocal/data/repositories/tts_repository_impl.dart';
import 'package:subvocal/domain/entities/subtitle.dart';
import 'package:subvocal/domain/entities/subtitle_entry.dart';
import 'package:subvocal/domain/usecases/play_subtitle_sequence.dart';
import 'package:subvocal/presentation/providers/player_provider.dart';
import 'package:subvocal/presentation/screens/player_screen.dart';

class _MockFlutterTts extends FlutterTts {
  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {}

  @override
  Future<dynamic> stop() async {}

  @override
  Future<dynamic> setSpeechRate(double rate) async {}

  @override
  Future<dynamic> setPitch(double pitch) async {}
}

Widget _createTestApp(Subtitle subtitle) {
  return ProviderScope(
    overrides: [
      playerProvider.overrideWith((ref) {
        final tts = _MockFlutterTts();
        final repo = TtsRepositoryImpl(tts);
        final sequence = PlaySubtitleSequence(repo);
        return PlayerNotifier(sequence, repo);
      }),
    ],
    child: MaterialApp(
      home: PlayerScreen(subtitle: subtitle),
    ),
  );
}

void main() {
  final testSubtitle = Subtitle(
    title: 'Test Subtitle',
    entries: [
      SubtitleEntry(
        index: 1,
        start: const Duration(seconds: 1),
        end: const Duration(seconds: 4),
        text: 'Hello, world!',
      ),
      SubtitleEntry(
        index: 2,
        start: const Duration(seconds: 5),
        end: const Duration(seconds: 8),
        text: 'Second subtitle line',
      ),
    ],
  );

  testWidgets('renders subtitle title in app bar', (tester) async {
    await tester.pumpWidget(_createTestApp(testSubtitle));
    await tester.pump();

    expect(find.text('Test Subtitle'), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('renders play and skip controls', (tester) async {
    await tester.pumpWidget(_createTestApp(testSubtitle));
    await tester.pump();
    await tester.pump();

    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsWidgets);
    expect(find.byIcon(Icons.skip_previous), findsOneWidget);
    expect(find.byIcon(Icons.skip_next), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('shows subtitle text when playing', (tester) async {
    await tester.pumpWidget(_createTestApp(testSubtitle));
    await tester.pump();

    expect(find.text('Hello, world!'), findsWidgets);
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('shows speed and sync sliders', (tester) async {
    await tester.pumpWidget(_createTestApp(testSubtitle));
    await tester.pump();

    expect(find.text('Speed'), findsOneWidget);
    expect(find.text('Sync'), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/domain/entities/subtitle.dart';
import 'package:subvocal/domain/entities/subtitle_entry.dart';
import 'package:subvocal/domain/entities/translation_progress.dart';
import 'package:subvocal/domain/errors/failures.dart';
import 'package:subvocal/domain/repositories/tts_repository.dart';
import 'package:subvocal/generated/app_localizations.dart';
import 'package:subvocal/presentation/providers/player_provider.dart';
import 'package:subvocal/presentation/screens/player_screen.dart';

class _MockTtsRepository implements TtsRepository {
  @override
  Stream<int> get onIndexChanged => const Stream.empty();
  @override
  Future<Failure?> init() async => null;
  @override
  Future<Failure?> speak(List<SubtitleEntry> entries) async => null;
  @override
  Future<void> play() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  Future<void> seek(Duration position) async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> setSpeed(double rate) async {}
  @override
  Future<void> setOffset(Duration offset) async {}
  @override
  Future<void> setLanguage(String languageCode) async {}
  @override
  Future<List<Map<String, String>>> getVoices() async => [];
  @override
  Future<void> setVoice(Map<String, String> voice) async {}

  @override
  bool get isPlaying => false;
  @override
  int get currentIndex => 0;
  @override
  Duration get currentPosition => Duration.zero;
  @override
  Stream<void> get onPlaybackComplete => const Stream.empty();
}

const _testSubtitle = Subtitle(
  title: 'The Matrix',
  entries: [
    SubtitleEntry(
      index: 1,
      start: Duration(seconds: 1),
      end: Duration(seconds: 4),
      text: 'Hello, world!',
    ),
    SubtitleEntry(
      index: 2,
      start: Duration(seconds: 5),
      end: Duration(seconds: 8),
      text: 'Second subtitle line',
    ),
  ],
);

Widget _buildPlayerScreen({
  bool isPlaying = true,
  bool isTranslating = false,
  String? error,
  TranslationProgress? progress,
  Subtitle? translatedSubtitle,
}) {
  return ProviderScope(
    overrides: [
      ttsRepositoryProvider.overrideWith((ref) => _MockTtsRepository()),
      playerProvider.overrideWith((ref) {
        final notifier = PlayerNotifier(ref.read(ttsRepositoryProvider));
        notifier.state = PlayerState(
          isPlaying: isPlaying,
          isTranslating: isTranslating,
          entries: _testSubtitle.entries,
          error: error,
          translationProgress: progress,
          translatedSubtitle: translatedSubtitle,
          currentIndex: 0,
        );
        return notifier;
      }),
    ],
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: PlayerScreen(subtitle: _testSubtitle),
    ),
  );
}

void main() {
  group('PlayerScreen', () {
    testWidgets('playing state', (tester) async {
      await tester.pumpWidget(_buildPlayerScreen(isPlaying: true));
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/player_screen_playing.png'),
      );
    });

    testWidgets('error state', (tester) async {
      await tester.pumpWidget(
        _buildPlayerScreen(
          isPlaying: false,
          error: 'Translation failed: Rate limit exceeded',
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/player_screen_error.png'),
      );
    });

    testWidgets('translating state', (tester) async {
      await tester.pumpWidget(
        _buildPlayerScreen(
          isPlaying: false,
          isTranslating: true,
          progress: const TranslationProgress(completed: 5, total: 10),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/player_screen_translating.png'),
      );
    });

    testWidgets('with translated subtitle', (tester) async {
      await tester.pumpWidget(
        _buildPlayerScreen(
          isPlaying: true,
          translatedSubtitle: const Subtitle(
            title: 'The Matrix',
            language: 'es',
            entries: [
              SubtitleEntry(
                index: 1,
                start: Duration(seconds: 1),
                end: Duration(seconds: 4),
                text: 'Hola, mundo!',
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/player_screen_with_translation.png'),
      );
    });
  });
}

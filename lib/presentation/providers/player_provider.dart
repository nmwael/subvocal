import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../data/repositories/tts_repository_impl.dart';
import '../../domain/entities/subtitle.dart';
import '../../domain/entities/subtitle_entry.dart';
import '../../domain/entities/translation_progress.dart';
import '../../domain/repositories/tts_repository.dart';
import '../../domain/repositories/subtitle_repository.dart';
import '../../domain/services/srt_parser.dart';
import 'search_provider.dart';

final flutterTtsProvider = Provider<FlutterTts>((ref) => FlutterTts());

final ttsRepositoryProvider = Provider<TtsRepository>((ref) {
  return TtsRepositoryImpl(ref.watch(flutterTtsProvider));
});

class PlayerState {
  final bool isPlaying;
  final bool isPaused;
  final bool isTranslating;
  final TranslationProgress? translationProgress;
  final Subtitle? translatedSubtitle;
  final int currentIndex;
  final Duration currentPosition;
  final double speed;
  final double syncOffset;
  final List<SubtitleEntry> entries;
  final String? error;
  final String? year;
  final int? season;
  final int? episode;

  const PlayerState({
    this.isPlaying = false,
    this.isPaused = false,
    this.isTranslating = false,
    this.translationProgress,
    this.translatedSubtitle,
    this.currentIndex = 0,
    this.currentPosition = Duration.zero,
    this.speed = 0.5,
    this.syncOffset = 0.0,
    this.entries = const [],
    this.error,
    this.year,
    this.season,
    this.episode,
  });

  double get seekProgress {
    if (entries.isEmpty) return 0.0;
    return currentIndex / entries.length;
  }

  Duration get totalDuration {
    if (entries.isEmpty) return Duration.zero;
    return entries.last.end;
  }

  PlayerState copyWith({
    bool? isPlaying,
    bool? isPaused,
    bool? isTranslating,
    TranslationProgress? translationProgress,
    Subtitle? translatedSubtitle,
    int? currentIndex,
    Duration? currentPosition,
    double? speed,
    double? syncOffset,
    List<SubtitleEntry>? entries,
    String? error,
    String? year,
    int? season,
    int? episode,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      isTranslating: isTranslating ?? this.isTranslating,
      translationProgress: translationProgress ?? this.translationProgress,
      translatedSubtitle: translatedSubtitle ?? this.translatedSubtitle,
      currentIndex: currentIndex ?? this.currentIndex,
      currentPosition: currentPosition ?? this.currentPosition,
      speed: speed ?? this.speed,
      syncOffset: syncOffset ?? this.syncOffset,
      entries: entries ?? this.entries,
      error: error ?? this.error,
      year: year ?? this.year,
      season: season ?? this.season,
      episode: episode ?? this.episode,
    );
  }
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  final TtsRepository _ttsRepository;
  final SubtitleRepository? _subtitleRepository;
  StreamSubscription<int>? _indexSubscription;
  StreamSubscription<void>? _completionSubscription;
  Timer? _positionTimer;
  Duration _entryStartOffset = Duration.zero;
  DateTime? _entryStartWallClock;

  PlayerNotifier(this._ttsRepository, [this._subtitleRepository])
    : super(const PlayerState()) {
    _indexSubscription = _ttsRepository.onIndexChanged.listen((index) {
      final entryStart = _ttsRepository.currentPosition;
      _entryStartOffset = entryStart;
      _entryStartWallClock = DateTime.now();
      state = state.copyWith(currentIndex: index, currentPosition: entryStart);
    });
    _completionSubscription = _ttsRepository.onPlaybackComplete.listen((_) {
      _positionTimer?.cancel();
      state = state.copyWith(isPlaying: false, isPaused: false);
    });
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_entryStartWallClock != null) {
        final elapsed = DateTime.now().difference(_entryStartWallClock!);
        final position = _entryStartOffset + elapsed;
        state = state.copyWith(currentPosition: position);
      }
    });
  }

  @override
  void dispose() {
    _indexSubscription?.cancel();
    _completionSubscription?.cancel();
    _positionTimer?.cancel();
    super.dispose();
  }

  Future<void> load(
    List<SubtitleEntry> entries, {
    String? language,
    String? voice,
    String? sourceLanguage,
    String? title,
    String? year,
    int? season,
    int? episode,
  }) async {
    _positionTimer?.cancel();
    _entryStartWallClock = null;
    if (state.isPlaying || state.isPaused) {
      await _ttsRepository.stop();
    }
    state = const PlayerState();

    if (language != null) {
      await _ttsRepository.setLanguage(language);
    }
    if (voice != null) {
      await _ttsRepository.setVoice({'name': voice, 'locale': language ?? ''});
    }

    var playEntries = entries.map((e) {
      return SubtitleEntry(
        index: e.index,
        start: e.start,
        end: e.end,
        text: SrtParser.sanitize(e.text),
      );
    }).toList();
    final shouldTranslate =
        language != null &&
        language.isNotEmpty &&
        _subtitleRepository != null &&
        sourceLanguage != language;

    if (shouldTranslate) {
      state = state.copyWith(
        isTranslating: true,
        translationProgress: const TranslationProgress(completed: 0, total: 0),
      );
      try {
        final (translated, failure) = await _subtitleRepository.translate(
          Subtitle(id: null, title: title ?? '', entries: entries),
          language,
          sourceLanguage: sourceLanguage,
          onProgress: (progress) {
            state = state.copyWith(translationProgress: progress);
          },
        );
        state = state.copyWith(isTranslating: false);
        if (failure != null) {
          state = state.copyWith(
            error: 'Translation failed: ${failure.message}',
          );
          return;
        }
        if (translated != null) {
          playEntries = translated.entries;
          state = state.copyWith(translatedSubtitle: translated);
        }
      } catch (e) {
        state = state.copyWith(
          isTranslating: false,
          error: 'Translation error: $e',
        );
        return;
      }
    }

    final failure = await _ttsRepository.speak(playEntries);
    if (failure != null) {
      state = state.copyWith(error: failure.message);
      return;
    }
    state = PlayerState(
      isPlaying: true,
      entries: playEntries,
      speed: state.speed,
      translatedSubtitle: state.translatedSubtitle,
      year: year,
      season: season,
      episode: episode,
    );
    _startPositionTimer();
  }

  void play() {
    _ttsRepository.play();
    state = state.copyWith(isPlaying: true, isPaused: false);
    _startPositionTimer();
  }

  void pause() {
    _ttsRepository.pause();
    state = state.copyWith(isPlaying: false, isPaused: true);
    _positionTimer?.cancel();
  }

  void resume() {
    _ttsRepository.resume();
    state = state.copyWith(isPlaying: true, isPaused: false);
    _startPositionTimer();
  }

  void stop() {
    _ttsRepository.stop();
    _positionTimer?.cancel();
    state = const PlayerState();
  }

  void next() {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.entries.length) return;
    final nextEntry = state.entries[nextIndex];
    seek(nextEntry.start);
  }

  void previous() {
    final prevIndex = state.currentIndex - 1;
    if (prevIndex < 0) return;
    final prevEntry = state.entries[prevIndex];
    seek(prevEntry.start);
  }

  void seek(Duration position) {
    _ttsRepository.seek(position);
    _entryStartOffset = position;
    _entryStartWallClock = DateTime.now();
    state = state.copyWith(currentPosition: position);
  }

  void setSpeed(double speed) {
    _ttsRepository.setSpeed(speed);
    state = state.copyWith(speed: speed);
  }

  void setSyncOffset(double offsetSeconds) {
    state = state.copyWith(syncOffset: offsetSeconds);
    _ttsRepository.setOffset(
      Duration(milliseconds: (offsetSeconds * 1000).round()),
    );
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((
  ref,
) {
  final ttsRepo = ref.watch(ttsRepositoryProvider);
  final subtitleRepo = ref.watch(subtitleRepositoryProvider);
  return PlayerNotifier(ttsRepo, subtitleRepo);
});

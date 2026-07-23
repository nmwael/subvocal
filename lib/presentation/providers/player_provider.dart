import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../data/repositories/tts_repository_impl.dart';
import '../../domain/entities/subtitle.dart';
import '../../domain/entities/subtitle_entry.dart';
import '../../domain/repositories/subtitle_repository.dart';
import '../../domain/usecases/play_subtitle_sequence.dart';
import 'search_provider.dart';

final flutterTtsProvider = Provider<FlutterTts>((ref) => FlutterTts());

final ttsRepositoryProvider = Provider<TtsRepositoryImpl>((ref) {
  return TtsRepositoryImpl(ref.watch(flutterTtsProvider));
});

final playSubtitleSequenceProvider = Provider<PlaySubtitleSequence>((ref) {
  return PlaySubtitleSequence(ref.watch(ttsRepositoryProvider));
});

class PlayerState {
  final bool isPlaying;
  final bool isPaused;
  final int currentIndex;
  final Duration currentPosition;
  final double speed;
  final double syncOffset;
  final List<SubtitleEntry> entries;
  final String? error;

  const PlayerState({
    this.isPlaying = false,
    this.isPaused = false,
    this.currentIndex = 0,
    this.currentPosition = Duration.zero,
    this.speed = 0.5,
    this.syncOffset = 0.0,
    this.entries = const [],
    this.error,
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
    int? currentIndex,
    Duration? currentPosition,
    double? speed,
    double? syncOffset,
    List<SubtitleEntry>? entries,
    String? error,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      currentIndex: currentIndex ?? this.currentIndex,
      currentPosition: currentPosition ?? this.currentPosition,
      speed: speed ?? this.speed,
      syncOffset: syncOffset ?? this.syncOffset,
      entries: entries ?? this.entries,
      error: error,
    );
  }
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  final PlaySubtitleSequence _playSubtitleSequence;
  final TtsRepositoryImpl _ttsRepository;
  final SubtitleRepository? _subtitleRepository;
  StreamSubscription<int>? _indexSubscription;

  PlayerNotifier(this._playSubtitleSequence, this._ttsRepository,
      [this._subtitleRepository])
      : super(const PlayerState()) {
    _indexSubscription = _ttsRepository.onIndexChanged.listen((index) {
      state = state.copyWith(
        currentIndex: index,
        currentPosition: _ttsRepository.currentPosition,
      );
    });
  }

  @override
  void dispose() {
    _indexSubscription?.cancel();
    super.dispose();
  }

  Future<void> load(List<SubtitleEntry> entries, {String? language, String? voice}) async {
    if (language != null) {
      await _ttsRepository.setLanguage(language);
    }
    if (voice != null) {
      await _ttsRepository.setVoice({'name': voice, 'locale': language ?? ''});
    }

    var playEntries = entries;
    if (language != null && language.isNotEmpty && _subtitleRepository != null) {
      try {
        final (translated, failure) = await _subtitleRepository.translate(
          Subtitle(id: null, title: '', entries: entries),
          language,
        );
        if (failure == null && translated != null) {
          playEntries = translated.entries;
        }
      } catch (_) {}
    }

    final failure = await _playSubtitleSequence.call(playEntries);
    if (failure != null) {
      state = state.copyWith(error: failure.message);
      return;
    }
    state = PlayerState(
      isPlaying: true,
      entries: entries,
      speed: state.speed,
    );
  }

  void play() {
    _playSubtitleSequence.play();
    state = state.copyWith(isPlaying: true, isPaused: false);
  }

  void pause() {
    _playSubtitleSequence.pause();
    state = state.copyWith(isPlaying: false, isPaused: true);
  }

  void resume() {
    _playSubtitleSequence.resume();
    state = state.copyWith(isPlaying: true, isPaused: false);
  }

  void stop() {
    _playSubtitleSequence.stop();
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
    _playSubtitleSequence.seek(position);
    state = state.copyWith(currentPosition: position);
  }

  void setSpeed(double speed) {
    _playSubtitleSequence.setSpeed(speed);
    state = state.copyWith(speed: speed);
  }

  void setSyncOffset(double offsetSeconds) {
    state = state.copyWith(syncOffset: offsetSeconds);
    _ttsRepository.setOffset(Duration(
      milliseconds: (offsetSeconds * 1000).round(),
    ));
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  final sequence = ref.watch(playSubtitleSequenceProvider);
  final ttsRepo = ref.watch(ttsRepositoryProvider);
  final subtitleRepo = ref.watch(subtitleRepositoryProvider);
  return PlayerNotifier(sequence, ttsRepo, subtitleRepo);
});

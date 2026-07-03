import 'dart:async';

import '../../core/errors/failures.dart';
import '../entities/subtitle_entry.dart';
import '../repositories/tts_repository.dart';

class PlaySubtitleSequence {
  final TtsRepository _ttsRepository;

  PlaySubtitleSequence(this._ttsRepository);

  Future<Failure?> call(List<SubtitleEntry> entries) {
    return _ttsRepository.speak(entries);
  }

  Future<void> play() => _ttsRepository.play();
  Future<void> pause() => _ttsRepository.pause();
  Future<void> resume() => _ttsRepository.resume();
  Future<void> stop() => _ttsRepository.stop();
  Future<void> seek(Duration position) => _ttsRepository.seek(position);
  Future<void> setSpeed(double rate) => _ttsRepository.setSpeed(rate);
  Future<void> setOffset(Duration offset) => _ttsRepository.setOffset(offset);

  bool get isPlaying => _ttsRepository.isPlaying;
  int get currentIndex => _ttsRepository.currentIndex;
  Duration get currentPosition => _ttsRepository.currentPosition;
  Stream<int> get onIndexChanged => _ttsRepository.onIndexChanged;
  Stream<void> get onPlaybackComplete => _ttsRepository.onPlaybackComplete;
}

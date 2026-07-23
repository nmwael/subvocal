import '../../core/errors/failures.dart';
import '../entities/subtitle_entry.dart';

abstract class TtsRepository {
  Future<Failure?> init();
  Future<Failure?> speak(List<SubtitleEntry> entries);
  Future<void> play();
  Future<void> pause();
  Future<void> resume();
  Future<void> seek(Duration position);
  Future<void> stop();
  Future<void> setSpeed(double rate);
  Future<void> setOffset(Duration offset);
  Future<void> setLanguage(String languageCode);
  Future<List<Map<String, String>>> getVoices();
  Future<void> setVoice(Map<String, String> voice);

  bool get isPlaying;
  int get currentIndex;
  Duration get currentPosition;
  Stream<int> get onIndexChanged;
  Stream<void> get onPlaybackComplete;
}

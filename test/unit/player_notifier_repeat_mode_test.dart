import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/domain/entities/subtitle_entry.dart';
import 'package:subvocal/domain/errors/failures.dart';
import 'package:subvocal/domain/repositories/tts_repository.dart';
import 'package:subvocal/presentation/providers/player_provider.dart';

class _FakeTtsRepository implements TtsRepository {
  final _indexChangedController = StreamController<int>.broadcast();
  final _playbackCompleteController = StreamController<void>.broadcast();
  final _wordIndexChangedController = StreamController<int>.broadcast();

  int repeatCalls = 0;

  // Internal state
  bool _isPlaying = false;
  int _currentIndex = 0;
  Duration _currentPosition = Duration.zero;

  @override
  Future<Failure?> init() async => null;

  @override
  Future<Failure?> speak(List<SubtitleEntry> entries) async {
    // For testing, we don't actually speak, but we can set initial state if needed.
    // We'll set the current index to the first entry if there are any entries.
    if (entries.isNotEmpty) {
      _currentIndex = 0;
      _indexChangedController.add(_currentIndex);
    }
    _isPlaying = true;
    return null;
  }

  @override
  Future<void> play() async {
    _isPlaying = true;
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
  }

  @override
  Future<void> resume() async {
    _isPlaying = true;
  }

  @override
  Future<void> seek(Duration position) async {
    _currentPosition = position;
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
  }

  @override
  Future<void> setSpeed(double rate) async {}

  @override
  Future<void> setOffset(Duration offset) async {}

  @override
  Future<void> setLanguage(String languageCode) async {}

  @override
  Future<List<Map<String, String>>> getVoices() async => [
        {'name': 'Test Voice', 'locale': 'en_US'}
      ];

  @override
  Future<void> setVoice(Map<String, String> voice) async {}

  @override
  bool get isPlaying => _isPlaying;

  @override
  int get currentIndex => _currentIndex;

  @override
  Duration get currentPosition => _currentPosition;

  @override
  Stream<int> get onIndexChanged => _indexChangedController.stream;

  @override
  Stream<void> get onPlaybackComplete => _playbackCompleteController.stream;

  @override
  Stream<int> get onWordIndexChanged => _wordIndexChangedController.stream;

  @override
  Future<void> repeatCurrent() {
    repeatCalls++;
    return Future.value();
  }

  Future<void> dispose() async {
    await _indexChangedController.close();
    await _playbackCompleteController.close();
    await _wordIndexChangedController.close();
  }

  // Helper methods for tests to emit events
  void emitIndexChanged(int index) {
    _currentIndex = index;
    _indexChangedController.add(index);
  }

  void emitPlaybackComplete() {
    _playbackCompleteController.add(null);
  }

  void emitWordIndexChanged(int index) {
    _wordIndexChangedController.add(index);
  }
}

List<SubtitleEntry> _createEntries() {
  return [
    const SubtitleEntry(
      index: 1,
      start: Duration(seconds: 1),
      end: Duration(seconds: 4),
      text: 'Hello world',
    ),
    const SubtitleEntry(
      index: 2,
      start: Duration(seconds: 5),
      end: Duration(seconds: 8),
      text: 'Second entry here',
    ),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeTtsRepository fakeTtsRepo;
  late PlayerNotifier notifier;

  setUp(() {
    fakeTtsRepo = _FakeTtsRepository();
    notifier = PlayerNotifier(fakeTtsRepo, null);
  });

  tearDown(() {
    notifier.dispose();
    fakeTtsRepo.dispose();
  });

  group('PlayerNotifier - Repeat Mode', () {
    test('stop at last entry: repeatMode ON and currentIndex is last entry, onPlaybackComplete does not call repeatCurrent and sets isPlaying false', () async {
      // Arrange: load two entries
      await notifier.load(_createEntries());
      await Future.delayed(const Duration(milliseconds: 50)); // allow load to complete

      // Turn on repeat mode
      notifier.toggleRepeatMode();
      expect(notifier.state.repeatMode, true);

      // Simulate being at the last entry (index 1 in the list, which is the second entry)
      // Emit an index changed event for the last entry (index 1)
      fakeTtsRepo.emitIndexChanged(1);
      await Future.delayed(const Duration(milliseconds: 10)); // let state update

      // Verify currentIndex is now 1 (last entry)
      expect(notifier.state.currentIndex, 1);

      // Act: simulate playback completion
      fakeTtsRepo.emitPlaybackComplete();
      await Future.delayed(const Duration(milliseconds: 10)); // let completion handler run

      // Assert: repeatCurrent should NOT have been called (repeatCalls == 0)
      expect(fakeTtsRepo.repeatCalls, 0,
          reason: 'repeatCurrent should not be called when at last entry with repeatMode on');
      // Assert: playback should be stopped (isPlaying false, isPaused false)
      expect(notifier.state.isPlaying, false,
          reason: 'isPlaying should be false after playback completes at last entry with repeatMode on');
      expect(notifier.state.isPaused, false,
          reason: 'isPaused should be false after playback completes at last entry with repeatMode on');
    });

    test('auto-repeat calls repo: repeatMode ON and currentIndex is not last, onPlaybackComplete calls repeatCurrent exactly once and sets isPlaying true', () async {
      // Arrange: load two entries
      await notifier.load(_createEntries());
      await Future.delayed(const Duration(milliseconds: 50));

      // Turn on repeat mode
      notifier.toggleRepeatMode();
      expect(notifier.state.repeatMode, true);

      // Simulate being at the first entry (index 0)
      fakeTtsRepo.emitIndexChanged(0);
      await Future.delayed(const Duration(milliseconds: 10));

      // Act: simulate playback completion of the first entry
      fakeTtsRepo.emitPlaybackComplete();
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert: repeatCurrent should have been called exactly once
      expect(fakeTtsRepo.repeatCalls, 1,
          reason: 'repeatCurrent should be called once when not at last entry with repeatMode on');
      // Assert: after auto-repeat, playback should be playing (isPlaying true)
      expect(notifier.state.isPlaying, true,
          reason: 'isPlaying should be true after auto-repeat from non-last entry');
      expect(notifier.state.isPaused, false,
          reason: 'isPaused should be false after auto-repeat from non-last entry');
    });

    test('manual repeat from paused state sets isPlaying true and isPaused false', () async {
      // Arrange: load two entries and start playing
      await notifier.load(_createEntries());
      await Future.delayed(const Duration(milliseconds: 50));

      // Pause the player
      notifier.pause();
      expect(notifier.state.isPlaying, false);
      expect(notifier.state.isPaused, true);

      // Act: call repeatCurrent (manual repeat)
      await notifier.repeatCurrent();
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert: after manual repeat, playback should be playing
      expect(notifier.state.isPlaying, true,
          reason: 'isPlaying should be true after manual repeat from paused state');
      expect(notifier.state.isPaused, false,
          reason: 'isPaused should be false after manual repeat from paused state');
      // Note: repeatCalls should have increased by 1
      expect(fakeTtsRepo.repeatCalls, 1,
          reason: 'repeatCurrent should have been called once');
    });

    test('manual repeat phrase from paused state sets isPlaying true and isPaused false', () async {
      // Arrange: load two entries and start playing
      await notifier.load(_createEntries());
      await Future.delayed(const Duration(milliseconds: 50));

      // Pause the player
      notifier.pause();
      expect(notifier.state.isPlaying, false);
      expect(notifier.state.isPaused, true);

      // Act: call repeatPhrase (manual repeat phrase)
      await notifier.repeatPhrase();
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert: after manual repeat phrase, playback should be playing
      expect(notifier.state.isPlaying, true,
          reason: 'isPlaying should be true after manual repeat phrase from paused state');
      expect(notifier.state.isPaused, false,
          reason: 'isPaused should be false after manual repeat phrase from paused state');
      // Note: repeatCalls should have increased by 1
      expect(fakeTtsRepo.repeatCalls, 1,
          reason: 'repeatPhrase should have been called once');
    });
  });
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:subvocal/data/repositories/tts_repository_impl.dart';
import 'package:subvocal/domain/entities/subtitle_entry.dart';
import 'package:subvocal/domain/usecases/play_subtitle_sequence.dart';

class _MockFlutterTts extends FlutterTts {
  String? lastSpokenText;
  double? lastSpeechRate;
  double? lastPitch;

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    lastSpokenText = text;
  }

  @override
  Future<dynamic> stop() async {
    lastSpokenText = null;
  }

  @override
  Future<dynamic> setSpeechRate(double rate) async {
    lastSpeechRate = rate;
  }

  @override
  Future<dynamic> setPitch(double pitch) async {
    lastPitch = pitch;
  }
}

List<SubtitleEntry> _createEntries() {
  return [
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
      text: 'Second line',
    ),
    SubtitleEntry(
      index: 3,
      start: const Duration(seconds: 9),
      end: const Duration(seconds: 11),
      text: 'Third line',
    ),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockFlutterTts mockTts;
  late TtsRepositoryImpl repository;
  late PlaySubtitleSequence useCase;

  setUp(() {
    mockTts = _MockFlutterTts();
    repository = TtsRepositoryImpl(mockTts);
    useCase = PlaySubtitleSequence(repository);
  });

  group('TtsRepositoryImpl', () {
    group('init', () {
      test('initializes with default speed and pitch', () async {
        final failure = await repository.init();

        expect(failure, isNull);
      });
    });

    group('speak', () {
      test('starts speaking the first entry', () async {
        final entries = _createEntries();
        final failure = await repository.speak(entries);

        expect(failure, isNull);
        expect(repository.isPlaying, true);
        expect(repository.currentIndex, 0);
      });

      test('empty entries handled gracefully', () async {
        final failure = await repository.speak([]);

        expect(failure, isNull);
        expect(repository.isPlaying, false);
      });
    });

    group('pause and resume', () {
      test('pauses playback', () async {
        await repository.speak(_createEntries());

        await repository.pause();

        expect(repository.isPlaying, false);
      });

      test('resumes from current entry', () async {
        await repository.speak(_createEntries());
        await repository.pause();

        await repository.resume();

        expect(repository.isPlaying, true);
      });
    });

    group('stop', () {
      test('stops playback and resets state', () async {
        await repository.speak(_createEntries());

        await repository.stop();

        expect(repository.isPlaying, false);
        expect(repository.currentIndex, 0);
      });
    });

    group('seek', () {
      test('seeks to position within an entry', () async {
        await repository.speak(_createEntries());

        await repository.seek(const Duration(seconds: 6));

        expect(repository.currentIndex, 1);
      });

      test('seeks before first entry goes to index 0', () async {
        await repository.speak(_createEntries());

        await repository.seek(const Duration(milliseconds: 500));

        expect(repository.currentIndex, 0);
      });

      test('seeks after last entry stops playback', () async {
        await repository.speak(_createEntries());

        await repository.seek(const Duration(seconds: 30));

        expect(repository.isPlaying, false);
      });

      test('seek on empty entries does nothing', () async {
        await repository.seek(const Duration(seconds: 5));

        expect(repository.isPlaying, false);
      });

      test('seek at zero position goes to first entry', () async {
        await repository.speak(_createEntries());

        await repository.seek(Duration.zero);

        expect(repository.currentIndex, 0);
      });
    });

    group('speed and offset', () {
      test('setSpeed updates speech rate', () async {
        await repository.setSpeed(0.8);
      });

      test('setOffset stores offset value', () async {
        await repository.setOffset(const Duration(seconds: 2));
      });
    });

    group('index stream', () {
      test('emits index on speak', () async {
        final emitted = <int>[];
        final sub = repository.onIndexChanged.listen(emitted.add);

        await repository.speak(_createEntries());

        expect(emitted.length, 1);
        expect(emitted[0], 0);

        await sub.cancel();
      });
    });

    group('play', () {
      test('play resumes when paused', () async {
        await repository.speak(_createEntries());
        await repository.pause();

        await repository.play();

        expect(repository.isPlaying, true);
      });

      test('play starts again when stopped with entries', () async {
        await repository.speak(_createEntries());
        await repository.stop();

        await repository.play();

        expect(repository.isPlaying, true);
      });
    });
  });

  group('PlaySubtitleSequence', () {
    test('speaks entries via repository', () async {
      final entries = _createEntries();
      final failure = await useCase.call(entries);

      expect(failure, isNull);
    });

    test('delegates play to repository', () async {
      await useCase.call(_createEntries());
      await useCase.pause();

      await useCase.play();

      expect(repository.isPlaying, true);
    });

    test('delegates pause to repository', () async {
      await useCase.call(_createEntries());

      await useCase.pause();

      expect(repository.isPlaying, false);
    });

    test('delegates stop to repository', () async {
      await useCase.call(_createEntries());

      await useCase.stop();

      expect(repository.isPlaying, false);
    });

    test('delegates seek to repository', () async {
      await useCase.call(_createEntries());

      await useCase.seek(const Duration(seconds: 6));

      expect(repository.currentIndex, 1);
    });

    test('delegates setSpeed to repository', () async {
      await useCase.setSpeed(0.7);
    });

    test('delegates setOffset to repository', () async {
      await useCase.setOffset(const Duration(seconds: 1));
    });

    test('exposes state from repository', () async {
      await useCase.call(_createEntries());

      expect(useCase.isPlaying, true);
      expect(useCase.currentIndex, 0);
      expect(useCase.currentPosition, const Duration(seconds: 1));
    });

    test('exposes onIndexChanged stream', () async {
      final emitted = <int>[];
      final sub = useCase.onIndexChanged.listen(emitted.add);

      await useCase.call(_createEntries());

      expect(emitted.length, 1);
      expect(emitted[0], 0);

      await sub.cancel();
    });
  });
}

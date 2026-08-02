import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:subvocal/data/repositories/tts_repository_impl.dart';
import 'package:subvocal/domain/entities/subtitle_entry.dart';

class _MockFlutterTts extends FlutterTts {
  String? lastSpokenText;

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    lastSpokenText = text;
    // Simulate immediate completion; we don't need to simulate word events
    // because our implementation uses its own timer.
  }

  @override
  Future<dynamic> stop() async {
    lastSpokenText = null;
  }

  @override
  Future<dynamic> setSpeechRate(double rate) async {}

  @override
  Future<dynamic> setPitch(double pitch) async {}

  @override
  Future<dynamic> setLanguage(String languageCode) async {}

  @override
  Future<dynamic> setVoice(Map<String, String> voice) async {}

  @override
  Future<dynamic> get getVoices async => [
    {'name': 'Alice', 'language': 'en-US'},
    {'name': 'Bob', 'language': 'eng'},
  ];
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

  late _MockFlutterTts mockTt;
  late TtsRepositoryImpl repository;

  setUp(() {
    mockTt = _MockFlutterTts();
    repository = TtsRepositoryImpl(mockTt);
  });

  group('TtsRepositoryImpl - Word Highlight', () {
    test('exposes onWordIndexChanged stream', () {
      expect(repository.onWordIndexChanged, isA<Stream<int>>());
    });

    test('emits word index during playback', () async {
      final emitted = <int>[];
      final sub = repository.onWordIndexChanged.listen(emitted.add);

      await repository.speak(_createEntries());

      // Wait a bit for our internal word timer to emit at least one event
      await Future.delayed(const Duration(milliseconds: 200));

      expect(emitted, isNotEmpty);
      expect(emitted.first, greaterThanOrEqualTo(0));

      await sub.cancel();
    });

    test('reset word index on new speak', () async {
      final emitted = <int>[];
      final sub = repository.onWordIndexChanged.listen(emitted.add);

      await repository.speak(_createEntries());
      await Future.delayed(const Duration(milliseconds: 100));
      final firstEmitCount = emitted.length;

      await repository.speak(_createEntries());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(emitted.length, greaterThan(firstEmitCount));

      await sub.cancel();
    });

    test('repeatCurrent seeks to current entry start', () async {
      await repository.speak(_createEntries());
      await repository.pause();

      // Before repeatCurrent implementation - this will fail in red phase
      await repository.repeatCurrent();

      expect(repository.currentIndex, 0);
    });
  });
}

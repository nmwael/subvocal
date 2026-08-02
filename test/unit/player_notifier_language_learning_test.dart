import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:subvocal/data/repositories/tts_repository_impl.dart';
import 'package:subvocal/domain/entities/subtitle_entry.dart';
import 'package:subvocal/presentation/providers/player_provider.dart';

class _MockFlutterTts extends FlutterTts {
  String? lastSpokenText;
  int lastWordIndex = -1;

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    lastSpokenText = text;
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

  late _MockFlutterTts mockTts;
  late TtsRepositoryImpl ttsRepo;
  late PlayerNotifier notifier;

  setUp(() {
    mockTts = _MockFlutterTts();
    ttsRepo = TtsRepositoryImpl(mockTts);
    notifier = PlayerNotifier(ttsRepo, null);
  });

  tearDown(() {
    notifier.dispose();
  });

  group('PlayerNotifier - Language Learning Features', () {
    test('PlayerState has currentWordIndex default -1', () {
      expect(notifier.state.currentWordIndex, -1);
    });

    test('PlayerState has repeatMode default false', () {
      expect(notifier.state.repeatMode, false);
    });

    test('repeatCurrent calls ttsRepository.repeatCurrent', () async {
      await notifier.load(_createEntries());
      await Future.delayed(const Duration(milliseconds: 50));

      await notifier.repeatCurrent();

      expect(notifier.state.currentIndex, 0);
    });

    test('toggleRepeatMode flips repeatMode', () async {
      expect(notifier.state.repeatMode, false);

      notifier.toggleRepeatMode();
      expect(notifier.state.repeatMode, true);

      notifier.toggleRepeatMode();
      expect(notifier.state.repeatMode, false);
    });

    test('word index from ttsRepository propagates to state', () async {
      final emitted = <int>[];
      final sub = notifier.state.onWordIndexChanged?.listen(emitted.add);

      await notifier.load(_createEntries());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(emitted, isNotEmpty);

      await sub?.cancel();
    });
  });
}

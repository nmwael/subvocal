import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:subvocal/data/datasources/settings_local_source.dart';
import 'package:subvocal/presentation/providers/player_provider.dart';
import 'package:subvocal/presentation/providers/settings_provider.dart';
import 'package:subvocal/presentation/screens/settings_screen.dart';

class _MockSettingsLocalSource extends SettingsLocalSource {
  @override
  Future<SettingsState?> load() async => null;
  @override
  Future<void> save(SettingsState settings) async {}
}

class _MockFlutterTts extends FlutterTts {
  final List<Map<String, dynamic>>? voicesResult;
  _MockFlutterTts({this.voicesResult}) : super();
  @override
  Future<dynamic> get getVoices async => voicesResult;
}

Future<List<Map<String, String>>> readVoices({
  required List<Map<String, dynamic>>? voices,
  required String language,
}) async {
  final localSource = _MockSettingsLocalSource();
  final settingsNotifier = SettingsNotifier(localSource);
  if (language != 'en') {
    settingsNotifier.setSelectedLanguage(language);
  }

  final container = ProviderContainer(
    overrides: [
      flutterTtsProvider.overrideWith(
        (ref) => _MockFlutterTts(voicesResult: voices),
      ),
      settingsProvider.overrideWith((ref) => settingsNotifier),
    ],
  );
  final result = await container.read(availableVoicesProvider.future);
  container.dispose();
  return result;
}

void main() {
  testWidgets('filters voices by locale key on Android', (tester) async {
    await tester.runAsync(() async {
      final voices = await readVoices(
        voices: [
          {'name': 'English US', 'locale': 'en-US'},
          {'name': 'Spanish ES', 'locale': 'es-ES'},
          {'name': 'Danish DK', 'locale': 'da-DK'},
        ],
        language: 'en',
      );

      expect(voices, hasLength(1));
      expect(voices[0]['name'], 'English US');
    });
  });

  testWidgets('filters voices by language key on iOS', (tester) async {
    await tester.runAsync(() async {
      final voices = await readVoices(
        voices: [
          {'name': 'English UK', 'language': 'en-GB'},
          {'name': 'French FR', 'language': 'fr-FR'},
        ],
        language: 'en',
      );

      expect(voices, hasLength(1));
      expect(voices[0]['name'], 'English UK');
    });
  });

  testWidgets('prefers language key over locale key', (tester) async {
    await tester.runAsync(() async {
      final voices = await readVoices(
        voices: [
          {'name': 'Conflict', 'locale': 'en-US', 'language': 'es-ES'},
        ],
        language: 'en',
      );

      expect(voices, isEmpty);
    });
  });

  testWidgets('filters for different target languages', (tester) async {
    await tester.runAsync(() async {
      final voices = await readVoices(
        voices: [
          {'name': 'English US', 'locale': 'en-US'},
          {'name': 'Spanish ES', 'locale': 'es-ES'},
          {'name': 'French FR', 'locale': 'fr-FR'},
        ],
        language: 'fr',
      );

      expect(voices, hasLength(1));
      expect(voices[0]['name'], 'French FR');
    });
  });

  testWidgets('returns empty when getVoices returns null', (tester) async {
    await tester.runAsync(() async {
      final voices = await readVoices(voices: null, language: 'en');
      expect(voices, isEmpty);
    });
  });

  testWidgets('returns empty when no voices match language', (tester) async {
    await tester.runAsync(() async {
      final voices = await readVoices(
        voices: [
          {'name': 'Danish DK', 'locale': 'da-DK'},
        ],
        language: 'en',
      );
      expect(voices, isEmpty);
    });
  });
}

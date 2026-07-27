import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/data/datasources/settings_local_source.dart';
import 'package:subvocal/presentation/providers/settings_provider.dart';

class _MockSettingsLocalSource extends SettingsLocalSource {
  @override
  Future<SettingsState?> load() async => null;

  @override
  Future<void> save(SettingsState settings) async {}
}

void main() {
  group('SettingsNotifier Tests', () {
    test('initial state has default values', () {
      final notifier = SettingsNotifier(_MockSettingsLocalSource());
      expect(notifier.state.speechRate, 0.5);
      expect(notifier.state.pitch, 1.0);
      expect(notifier.state.selectedLanguage, 'en');
      expect(notifier.state.selectedVoice, null);
    });

    test('setSpeechRate updates speech rate', () {
      final notifier = SettingsNotifier(_MockSettingsLocalSource());
      notifier.setSpeechRate(1.2);
      expect(notifier.state.speechRate, 1.2);
    });

    test('setPitch updates pitch', () {
      final notifier = SettingsNotifier(_MockSettingsLocalSource());
      notifier.setPitch(1.5);
      expect(notifier.state.pitch, 1.5);
    });

    test('setSelectedLanguage updates language', () {
      final notifier = SettingsNotifier(_MockSettingsLocalSource());
      notifier.setSelectedLanguage('da');
      expect(notifier.state.selectedLanguage, 'da');
    });

    test('setSelectedVoice updates voice', () {
      final notifier = SettingsNotifier(_MockSettingsLocalSource());
      notifier.setSelectedVoice('voice_1');
      expect(notifier.state.selectedVoice, 'voice_1');
    });
  });
}

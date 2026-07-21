import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/presentation/providers/settings_provider.dart';

void main() {
  group('SettingsNotifier Tests', () {
    test('initial state has default values', () {
      final notifier = SettingsNotifier();
      expect(notifier.state.speechRate, 0.5);
      expect(notifier.state.pitch, 1.0);
      expect(notifier.state.selectedLanguage, 'en');
      expect(notifier.state.selectedVoice, null);
    });

    test('setSpeechRate updates speech rate', () {
      final notifier = SettingsNotifier();
      notifier.setSpeechRate(1.2);
      expect(notifier.state.speechRate, 1.2);
    });

    test('setPitch updates pitch', () {
      final notifier = SettingsNotifier();
      notifier.setPitch(1.5);
      expect(notifier.state.pitch, 1.5);
    });

    test('setSelectedLanguage updates language', () {
      final notifier = SettingsNotifier();
      notifier.setSelectedLanguage('da');
      expect(notifier.state.selectedLanguage, 'da');
    });

    test('setSelectedVoice updates voice', () {
      final notifier = SettingsNotifier();
      notifier.setSelectedVoice('voice_1');
      expect(notifier.state.selectedVoice, 'voice_1');
    });
  });
}

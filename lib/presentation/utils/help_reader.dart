import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/utils/app_logger.dart';
import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';

class HelpReader {
  final FlutterTts _tts;
  final String _language;
  final double _rate;

  HelpReader(this._tts, this._language, this._rate);

  static HelpReader from(WidgetRef ref) {
    final tts = ref.read(flutterTtsProvider);
    final lang = ref.read(settingsProvider).selectedLanguage;
    final rate = ref.read(settingsProvider).speechRate;
    return HelpReader(tts, lang, rate);
  }

  Future<void> read(String text) async {
    try {
      await _tts.setLanguage(_language);
      await _tts.setSpeechRate(_rate);
      await _tts.speak(text);
    } catch (e) {
      appLogger.error('HelpReader TTS error', source: 'HelpReader', error: e);
    }
  }
}

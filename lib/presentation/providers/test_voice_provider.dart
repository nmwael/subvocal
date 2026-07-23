import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/utils/srt_parser.dart';
import '../../domain/entities/subtitle.dart';
import '../../domain/entities/subtitle_entry.dart';
import 'player_provider.dart';
import 'search_provider.dart';
import 'settings_provider.dart';

final testVoiceEntriesProvider = FutureProvider<List<SubtitleEntry>>((ref) async {
  final content = await rootBundle.loadString(
    'test/fixtures/Harry.Potter.And.The.Sorcerers.Stone.2001.EXTENDED.720p.BluRay.H264.AAC-RARBG.srt',
  );
  final parser = SrtParser();
  final entries = parser.parse(content);
  return entries.take(5).toList();
});

final testVoicePlayingProvider = StateProvider<bool>((ref) => false);

final translatedTestPlayingProvider = StateProvider<bool>((ref) => false);

final translatedTestPreviewProvider = FutureProvider.autoDispose.family<List<String>, String>((ref, language) async {
  final entries = await ref.watch(testVoiceEntriesProvider.future);
  if (entries.isEmpty) return [];

  final subtitle = Subtitle(title: 'Test', entries: entries);
  final translate = ref.read(translateSubtitleProvider);
  final (translated, failure) = await translate(subtitle, language);
  if (failure != null || translated == null) return [];
  return translated.entries.map((e) => e.text).toList();
});

class TestVoiceController {
  final FlutterTts _tts;
  final Ref _ref;

  TestVoiceController(this._tts, this._ref);

  Future<void> playSample(double rate, double pitch, {String? voice}) async {
    final entries = _ref.read(testVoiceEntriesProvider).valueOrNull;
    if (entries == null || entries.isEmpty) return;

    _ref.read(testVoicePlayingProvider.notifier).state = true;

    await _tts.setSpeechRate(rate);
    await _tts.setPitch(pitch);
    if (voice != null) {
      final language = _ref.read(settingsProvider).selectedLanguage;
      await _tts.setVoice({'name': voice, 'locale': language});
    }

    for (final entry in entries) {
      if (!_ref.read(testVoicePlayingProvider)) break;
      await _tts.speak(entry.text);
      await Future.delayed(entry.duration + const Duration(milliseconds: 200));
    }

    _ref.read(testVoicePlayingProvider.notifier).state = false;
  }

  Future<void> playTranslatedSample(double rate, double pitch, String language, {String? voice}) async {
    final entries = _ref.read(testVoiceEntriesProvider).valueOrNull;
    if (entries == null || entries.isEmpty) return;

    _ref.read(translatedTestPlayingProvider.notifier).state = true;

    await _tts.setSpeechRate(rate);
    await _tts.setPitch(pitch);
    await _tts.setLanguage(language);
    if (voice != null) {
      await _tts.setVoice({'name': voice, 'locale': language});
    }

    final subtitle = Subtitle(title: 'Test', entries: entries);
    final translate = _ref.read(translateSubtitleProvider);
    final (translated, failure) = await translate(subtitle, language);

    if (failure != null || translated == null) {
      _ref.read(translatedTestPlayingProvider.notifier).state = false;
      return;
    }

    for (final entry in translated.entries) {
      if (!_ref.read(translatedTestPlayingProvider)) break;
      await _tts.speak(entry.text);
      await Future.delayed(entry.duration + const Duration(milliseconds: 200));
    }

    _ref.read(translatedTestPlayingProvider.notifier).state = false;
  }

  Future<void> stop() async {
    _ref.read(testVoicePlayingProvider.notifier).state = false;
    _ref.read(translatedTestPlayingProvider.notifier).state = false;
    await _tts.stop();
  }
}

final testVoiceControllerProvider = Provider<TestVoiceController>((ref) {
  return TestVoiceController(ref.watch(flutterTtsProvider), ref);
});

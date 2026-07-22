import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/utils/srt_parser.dart';
import '../../domain/entities/subtitle_entry.dart';

final _flutterTtsProvider = Provider<FlutterTts>((ref) => FlutterTts());

final testVoiceEntriesProvider = FutureProvider<List<SubtitleEntry>>((ref) async {
  final content = await rootBundle.loadString(
    'test/fixtures/Harry.Potter.And.The.Sorcerers.Stone.2001.EXTENDED.720p.BluRay.H264.AAC-RARBG.srt',
  );
  final parser = SrtParser();
  final entries = parser.parse(content);
  return entries.take(5).toList();
});

final testVoicePlayingProvider = StateProvider<bool>((ref) => false);

class TestVoiceController {
  final FlutterTts _tts;
  final Ref _ref;

  TestVoiceController(this._tts, this._ref);

  Future<void> playSample(double rate, double pitch) async {
    final entries = _ref.read(testVoiceEntriesProvider).valueOrNull;
    if (entries == null || entries.isEmpty) return;

    _ref.read(testVoicePlayingProvider.notifier).state = true;

    await _tts.setSpeechRate(rate);
    await _tts.setPitch(pitch);

    for (final entry in entries) {
      if (!_ref.read(testVoicePlayingProvider)) break;
      await _tts.speak(entry.text);
      // Wait for speech to finish (approximate by entry duration)
      await Future.delayed(entry.duration + const Duration(milliseconds: 200));
    }

    _ref.read(testVoicePlayingProvider.notifier).state = false;
  }

  Future<void> stop() async {
    _ref.read(testVoicePlayingProvider.notifier).state = false;
    await _tts.stop();
  }
}

final testVoiceControllerProvider = Provider<TestVoiceController>((ref) {
  return TestVoiceController(ref.watch(_flutterTtsProvider), ref);
});

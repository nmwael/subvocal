import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/subtitle_entry.dart';
import '../../domain/repositories/tts_repository.dart';

class TtsRepositoryImpl implements TtsRepository {
  final FlutterTts _tts;
  List<SubtitleEntry> _entries = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isPaused = false;
  double _speed = 0.5;
  Duration _offset = Duration.zero;
  Timer? _scheduleTimer;
  final StreamController<int> _indexController = StreamController<int>.broadcast();
  final StreamController<void> _completionController = StreamController<void>.broadcast();

  TtsRepositoryImpl(this._tts);

  @override
  Future<Failure?> init() async {
    try {
      await _tts.setSpeechRate(_speed);
      await _tts.setPitch(1.0);
      return null;
    } catch (e) {
      return TtsFailure('Failed to initialize TTS: $e');
    }
  }

  @override
  Future<Failure?> speak(List<SubtitleEntry> entries) async {
    try {
      stop();
      _entries = entries;
      _currentIndex = 0;
      _isPaused = false;
      await _speakCurrent();
      return null;
    } catch (e) {
      return TtsFailure('Failed to start playback: $e');
    }
  }

  Future<void> _speakCurrent() async {
    if (_currentIndex >= _entries.length) {
      _isPlaying = false;
      _isPaused = false;
      _completionController.add(null);
      return;
    }

    _isPlaying = true;
    
    final entry = _entries[_currentIndex];
    _indexController.add(_currentIndex);

    await _tts.speak(entry.text);

    _scheduleNext(entry);
  }

  void _scheduleNext(SubtitleEntry entry) {
    final nextIndex = _currentIndex + 1;
    if (nextIndex >= _entries.length) {
      _scheduleTimer = Timer(entry.duration, () {
        _isPlaying = false;
        _isPaused = false;
        _completionController.add(null);
      });
      return;
    }

    final nextEntry = _entries[nextIndex];
    final delay = nextEntry.start - entry.start;
    final adjustedDelay = delay - _offset;

    if (adjustedDelay <= Duration.zero) {
      _currentIndex = nextIndex;
      _scheduleTimer = Timer.periodic(
        const Duration(milliseconds: 50),
            (timer) {
          timer.cancel();
          
          _speakCurrent();
        },
      );
      return;
    }

    _scheduleTimer = Timer(adjustedDelay, () {
      _currentIndex = nextIndex;
      
      _speakCurrent();
    });
  }

  @override
  Future<void> play() async {
    if (!_isPlaying && _isPaused) {
      _isPaused = false;
      _isPlaying = true;
      
      await _speakCurrent();
    } else if (!_isPlaying && _entries.isNotEmpty) {
      await speak(_entries);
    }
  }

  @override
  Future<void> pause() async {
    _isPaused = true;
    _isPlaying = false;
    _scheduleTimer?.cancel();
    await _tts.stop();
  }

  @override
  Future<void> resume() async {
    if (_isPaused) {
      _isPaused = false;
      _isPlaying = true;
      
      await _speakCurrent();
    }
  }

  @override
  Future<void> seek(Duration position) async {
    _scheduleTimer?.cancel();
    await _tts.stop();

    if (_entries.isEmpty) return;

    if (position >= _entries.last.end) {
      _isPlaying = false;
      _isPaused = false;
      _currentIndex = _entries.length;
      _completionController.add(null);
      return;
    }

    if (position <= Duration.zero) {
      _currentIndex = 0;
      _isPaused = false;
      if (_isPlaying) {
        
        await _speakCurrent();
      }
      return;
    }

    int newIndex = 0;
    for (int i = 0; i < _entries.length; i++) {
      if (_entries[i].start <= position && _entries[i].end > position) {
        newIndex = i;
        break;
      }
      if (_entries[i].start > position) {
        newIndex = i > 0 ? i - 1 : 0;
        break;
      }
    }

    _currentIndex = newIndex;
    _isPaused = false;

    if (_isPlaying) {
      
      await _speakCurrent();
    }
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
    _isPaused = false;
    _currentIndex = 0;
    _scheduleTimer?.cancel();
    await _tts.stop();
  }

  @override
  Future<void> setSpeed(double rate) async {
    _speed = rate;
    await _tts.setSpeechRate(rate);
  }

  @override
  Future<void> setOffset(Duration offset) async {
    _offset = offset;
  }

  @override
  Future<void> setLanguage(String languageCode) async {
    await _tts.setLanguage(languageCode);
  }

  @override
  Future<List<Map<String, String>>> getVoices() async {
    final raw = await _tts.getVoices;
    if (raw is! List) return [];
    return raw.whereType<Map>().map((v) =>
        v.map((key, value) => MapEntry(key.toString(), value.toString()))).toList();
  }

  @override
  Future<void> setVoice(Map<String, String> voice) async {
    await _tts.setVoice(voice);
  }

  @override
  bool get isPlaying => _isPlaying;

  @override
  int get currentIndex => _currentIndex;

  @override
  Duration get currentPosition =>
      _currentIndex < _entries.length ? _entries[_currentIndex].start : Duration.zero;

  @override
  Stream<int> get onIndexChanged => _indexController.stream;

  @override
  Stream<void> get onPlaybackComplete => _completionController.stream;
}

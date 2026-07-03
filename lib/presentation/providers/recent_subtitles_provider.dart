import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/subtitle.dart';

class RecentSubtitleInfo {
  final String title;
  final String filePath;
  final String? language;
  final DateTime addedAt;

  const RecentSubtitleInfo({
    required this.title,
    required this.filePath,
    this.language,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'filePath': filePath,
    'language': language,
    'addedAt': addedAt.toIso8601String(),
  };

  factory RecentSubtitleInfo.fromJson(Map<String, dynamic> json) => RecentSubtitleInfo(
    title: json['title'] as String? ?? 'Unknown',
    filePath: json['filePath'] as String? ?? '',
    language: json['language'] as String?,
    addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class RecentSubtitlesNotifier extends StateNotifier<List<RecentSubtitleInfo>> {
  RecentSubtitlesNotifier() : super([]) {
    _load();
  }

  Future<String> get _filePath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/recent_subtitles.json';
  }

  Future<void> _load() async {
    try {
      final path = await _filePath;
      final file = File(path);
      if (!await file.exists()) return;
      final content = await file.readAsString();
      final list = (jsonDecode(content) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(RecentSubtitleInfo.fromJson)
          .toList();
      state = list;
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final path = await _filePath;
      final file = File(path);
      await file.writeAsString(jsonEncode(state.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> add(Subtitle subtitle, {String? path}) async {
    final info = RecentSubtitleInfo(
      title: subtitle.title,
      filePath: path ?? '',
      language: subtitle.language,
      addedAt: DateTime.now(),
    );
    state = [info, ...state.take(19)];
    await _save();
  }

  Future<void> remove(int index) async {
    if (index >= 0 && index < state.length) {
      state = [...state.take(index), ...state.skip(index + 1)];
      await _save();
    }
  }

  Future<void> clear() async {
    state = [];
    await _save();
  }
}

final recentSubtitlesProvider = StateNotifierProvider<RecentSubtitlesNotifier, List<RecentSubtitleInfo>>((ref) {
  return RecentSubtitlesNotifier();
});

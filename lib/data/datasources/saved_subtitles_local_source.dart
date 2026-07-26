import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../core/utils/app_logger.dart';
import '../../domain/entities/saved_subtitle.dart';
import '../../domain/entities/subtitle.dart';

class SavedSubtitlesLocalSource {
  Future<String> get _filePath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/saved_subtitles.json';
  }

  Future<List<SavedSubtitle>> load() async {
    try {
      final path = await _filePath;
      final file = File(path);
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      return (jsonDecode(content) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(SavedSubtitle.fromJson)
          .toList();
    } catch (e) {
      appLogger.error(
        'Failed to load saved subtitles',
        source: 'SavedSubtitlesLocalSource',
        error: e,
      );
      return [];
    }
  }

  Future<SavedSubtitle> save(
    Subtitle subtitle,
    String language, {
    String? year,
    int? season,
    int? episode,
  }) async {
    final sanitizedTitle = subtitle.title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final id = sanitizedTitle.isNotEmpty
        ? '${sanitizedTitle}_$language'
        : 'subtitle_${DateTime.now().microsecondsSinceEpoch}';

    final saved = SavedSubtitle(
      id: id,
      title: subtitle.title,
      language: language,
      entryCount: subtitle.entries.length,
      savedAt: DateTime.now(),
      entries: subtitle.entries,
      year: year,
      season: season,
      episode: episode,
    );
    final items = await load();
    items.insert(0, saved);
    await _writeItems(items);
    return saved;
  }

  Future<void> delete(String id) async {
    final items = await load();
    items.removeWhere((s) => s.id == id);
    await _writeItems(items);
  }

  Future<void> _writeItems(List<SavedSubtitle> items) async {
    try {
      final path = await _filePath;
      final file = File(path);
      await file.writeAsString(
        jsonEncode(items.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      appLogger.error(
        'Failed to write saved subtitles',
        source: 'SavedSubtitlesLocalSource',
        error: e,
      );
    }
  }
}

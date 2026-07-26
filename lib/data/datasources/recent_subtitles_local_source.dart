import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../core/utils/app_logger.dart';
import '../../domain/entities/recent_subtitle_info.dart';

class RecentSubtitlesLocalSource {
  Future<String> get _filePath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/recent_subtitles.json';
  }

  Future<List<RecentSubtitleInfo>> load() async {
    try {
      final path = await _filePath;
      final file = File(path);
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      return (jsonDecode(content) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(RecentSubtitleInfo.fromJson)
          .toList();
    } catch (e) {
      appLogger.error(
        'Failed to load recent subtitles',
        source: 'RecentSubtitlesLocalSource',
        error: e,
      );
      return [];
    }
  }

  Future<void> save(List<RecentSubtitleInfo> items) async {
    try {
      final path = await _filePath;
      final file = File(path);
      await file.writeAsString(
        jsonEncode(items.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      appLogger.error(
        'Failed to write recent subtitles',
        source: 'RecentSubtitlesLocalSource',
        error: e,
      );
    }
  }
}

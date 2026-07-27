import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../core/utils/app_logger.dart';
import '../../presentation/providers/settings_provider.dart';

class SettingsLocalSource {
  Future<String> get _filePath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/settings.json';
  }

  Future<SettingsState?> load() async {
    try {
      final path = await _filePath;
      final file = File(path);
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      return SettingsState.fromJson(
        jsonDecode(content) as Map<String, dynamic>,
      );
    } catch (e) {
      appLogger.error(
        'Failed to load settings',
        source: 'SettingsLocalSource',
        error: e,
      );
      return null;
    }
  }

  Future<void> save(SettingsState settings) async {
    try {
      final path = await _filePath;
      final file = File(path);
      await file.writeAsString(jsonEncode(settings.toJson()));
    } catch (e) {
      appLogger.error(
        'Failed to save settings',
        source: 'SettingsLocalSource',
        error: e,
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'help_reader.dart';

class WelcomeHelper {
  static const _key = 'welcome_dialog_seen';

  static Future<bool> get shouldShow async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_key) ?? false);
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  static Future<void> showIfFirstLaunch(BuildContext context, WidgetRef ref) async {
    if (!await shouldShow) return;

    const helpContent = 'Welcome to subvocal!\n\n'
        'This app reads subtitles aloud in sync with your video.\n\n'
        'To get started:\n'
        '1. Search for a movie or show on the Search tab.\n'
        '2. Tap a result to download subtitles.\n'
        '3. Playback starts automatically.\n\n'
        'You can also log in to OpenSubtitles in Settings for more results.\n\n'
        'Need help? Check the Help section in Settings.';

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Welcome to subvocal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(helpContent),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.hearing, size: 20),
                tooltip: 'Read aloud',
                onPressed: () => HelpReader.from(ref).read(helpContent),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              markSeen();
            },
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }
}

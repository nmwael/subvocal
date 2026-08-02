import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../widgets/locale_picker.dart';
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

  static Future<void> showIfFirstLaunch(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (!await shouldShow) return;
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final helpContent = l10n.welcomeFullText;
    final notifier = ref.read(settingsProvider.notifier);
    final initialAppLocale = ref.read(settingsProvider).appLocale;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInnerState) {
          final currentSettings = ref.read(settingsProvider);
          return AlertDialog(
            title: Text(l10n.welcomeTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.welcomeIntro),
                  const SizedBox(height: 16),
                  Text(
                    l10n.welcomeGettingStarted,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.welcomeStep1),
                  Text(l10n.welcomeStep2),
                  Text(l10n.welcomeStep3),
                  const SizedBox(height: 16),
                  Text(l10n.welcomeLoginHint),
                  const SizedBox(height: 16),
                  Text(l10n.welcomeHelpHint),
                  const SizedBox(height: 16),
                  const Divider(),
                  Text(
                    l10n.language,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  LocalePicker(
                    value: currentSettings.appLocale,
                    onChanged: (v) {
                      notifier.setAppLocale(v);
                      setInnerState(() {});
                    },
                    locales: appLocales,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Semantics(
                      label: l10n.readWelcomeAloud,
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.hearing, size: 20),
                        tooltip: l10n.readAloud,
                        onPressed: () => HelpReader.from(ref).read(helpContent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  markSeen();
                },
                child: Text(l10n.getStarted),
              ),
              TextButton(
                onPressed: () {
                  notifier.setAppLocale(initialAppLocale);
                  Navigator.of(ctx).pop();
                  markSeen();
                },
                child: Text(l10n.skip),
              ),
            ],
          );
        },
      ),
    );
  }
}

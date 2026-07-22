import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Readout Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Speech Configuration',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Speech Rate (Speed)'),
                      Text('${settings.speechRate.toStringAsFixed(2)}x'),
                    ],
                  ),
                  Slider(
                    value: settings.speechRate,
                    min: 0.1,
                    max: 2.0,
                    divisions: 19,
                    label: '${settings.speechRate.toStringAsFixed(2)}x',
                    onChanged: (value) => notifier.setSpeechRate(value),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Voice Pitch'),
                      Text('${settings.pitch.toStringAsFixed(1)}x'),
                    ],
                  ),
                  Slider(
                    value: settings.pitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: '${settings.pitch.toStringAsFixed(1)}x',
                    onChanged: (value) => notifier.setPitch(value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Translation & Language',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Default Target Language'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: settings.selectedLanguage,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English (en)')),
                      DropdownMenuItem(value: 'es', child: Text('Spanish (es)')),
                      DropdownMenuItem(value: 'da', child: Text('Danish (da)')),
                      DropdownMenuItem(value: 'fr', child: Text('French (fr)')),
                      DropdownMenuItem(value: 'de', child: Text('German (de)')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        notifier.setSelectedLanguage(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

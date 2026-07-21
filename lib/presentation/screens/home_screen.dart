import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/recent_subtitles_provider.dart';
import '../providers/search_provider.dart';
import 'player_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSubtitles = ref.watch(recentSubtitlesProvider);
    final importedSubtitle = ref.watch(importedSubtitleProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('subvocal'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 48),
                  Icon(
                    Icons.subtitles,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Pick subtitles and read them aloud',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  FilledButton.icon(
                    onPressed: () => _importFile(context, ref),
                    icon: const Icon(Icons.file_open),
                    label: const Text('Import .SRT file'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Search OpenSubtitles'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                  if (importedSubtitle != null) ...[
                    const SizedBox(height: 24),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.subtitles),
                        title: Text(importedSubtitle.title),
                        trailing: const Icon(Icons.play_arrow),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PlayerScreen(subtitle: importedSubtitle),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (recentSubtitles.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Recent',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentSubtitles.length,
                itemBuilder: (context, index) {
                  final item = recentSubtitles[index];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(item.language ?? 'SRT', style: theme.textTheme.bodySmall),
                    trailing: const Icon(Icons.play_arrow),
                    onTap: () => _openRecent(context, ref, item),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _importFile(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt'],
    );

    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.first.path;
    if (filePath == null) return;

    final subtitleRepo = ref.read(subtitleRepositoryProvider);
    final (subtitle, failure) = await subtitleRepo.importFromFile(filePath);

    if (failure != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      }
      return;
    }

    if (subtitle != null && context.mounted) {
      await ref.read(recentSubtitlesProvider.notifier).add(subtitle, path: filePath);
      if (!context.mounted) return;
      ref.read(importedSubtitleProvider.notifier).state = subtitle;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlayerScreen(subtitle: subtitle),
        ),
      );
    }
  }

  void _openRecent(BuildContext context, WidgetRef ref, RecentSubtitleInfo info) {
    if (info.filePath.isNotEmpty) {
      ref.read(subtitleRepositoryProvider).importFromFile(info.filePath).then(
        (result) {
          final (subtitle, failure) = result;
          if (failure != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
            return;
          }
          if (subtitle != null && context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PlayerScreen(subtitle: subtitle),
              ),
            );
          }
        },
      );
    }
  }
}

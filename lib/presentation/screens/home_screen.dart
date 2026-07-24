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
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Search subtitles'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
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

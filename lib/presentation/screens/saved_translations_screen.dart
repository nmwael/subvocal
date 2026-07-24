import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/saved_subtitle.dart';
import '../providers/saved_subtitles_provider.dart';
import 'player_screen.dart';

class SavedTranslationsScreen extends ConsumerWidget {
  const SavedTranslationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedSubtitlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Translations'),
        centerTitle: true,
      ),
      body: savedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No saved translations', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text(
                    'Save a translation from the player screen',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _SavedSubtitleTile(item: item);
            },
          );
        },
      ),
    );
  }
}

class _SavedSubtitleTile extends ConsumerWidget {
  final SavedSubtitle item;

  const _SavedSubtitleTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateStr = '${item.savedAt.day}/${item.savedAt.month}/${item.savedAt.year}';

    return ListTile(
      leading: const Icon(Icons.subtitles),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${item.language.toUpperCase()} - ${item.entryCount} entries - $dateStr',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Play',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PlayerScreen(subtitle: item.toSubtitle()),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete translation?'),
                  content: Text('Delete "${item.title}" (${item.language.toUpperCase()})?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                ref.read(savedSubtitlesProvider.notifier).delete(item.id);
              }
            },
          ),
        ],
      ),
    );
  }
}

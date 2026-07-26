import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/saved_subtitle.dart';
import '../providers/saved_subtitles_provider.dart';
import 'player_screen.dart';

enum SortOption { titleAsc, dateNewest, dateOldest, language }

final sortOptionProvider = StateProvider<SortOption>(
  (ref) => SortOption.dateNewest,
);

class SavedTranslationsScreen extends ConsumerWidget {
  const SavedTranslationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedSubtitlesProvider);
    final sortOption = ref.watch(sortOptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Translations'),
        centerTitle: true,
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort by',
            onSelected: (option) {
              ref.read(sortOptionProvider.notifier).state = option;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortOption.titleAsc,
                child: Text('Title A-Z'),
              ),
              const PopupMenuItem(
                value: SortOption.dateNewest,
                child: Text('Newest First'),
              ),
              const PopupMenuItem(
                value: SortOption.dateOldest,
                child: Text('Oldest First'),
              ),
              const PopupMenuItem(
                value: SortOption.language,
                child: Text('Language'),
              ),
            ],
          ),
        ],
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
                  Text(
                    'No saved translations',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Save a translation from the player screen',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }
          final sortedItems = _sortItems(items, sortOption);
          return ListView.builder(
            itemCount: sortedItems.length,
            itemBuilder: (context, index) {
              final item = sortedItems[index];
              return _SavedSubtitleTile(item: item);
            },
          );
        },
      ),
    );
  }

  List<SavedSubtitle> _sortItems(List<SavedSubtitle> items, SortOption option) {
    final sorted = List<SavedSubtitle>.from(items);
    switch (option) {
      case SortOption.titleAsc:
        sorted.sort((a, b) => a.title.compareTo(b.title));
      case SortOption.dateNewest:
        sorted.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      case SortOption.dateOldest:
        sorted.sort((a, b) => a.savedAt.compareTo(b.savedAt));
      case SortOption.language:
        sorted.sort((a, b) => a.language.compareTo(b.language));
    }
    return sorted;
  }
}

class _SavedSubtitleTile extends ConsumerWidget {
  final SavedSubtitle item;

  const _SavedSubtitleTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateStr =
        '${item.savedAt.day}/${item.savedAt.month}/${item.savedAt.year}';

    String displayTitle;
    if (item.isTvShow) {
      displayTitle = '[TV] ${item.title}';
      if (item.year != null) {
        displayTitle = '$displayTitle (${item.year})';
      }
    } else {
      displayTitle = item.title;
      if (item.year != null) {
        displayTitle = '$displayTitle (${item.year})';
      }
    }

    return ListTile(
      leading: Icon(
        item.isTvShow ? Icons.tv : Icons.movie,
        color: item.isTvShow ? Colors.blue : null,
      ),
      title: Text(displayTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
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
                  content: Text(
                    'Delete "${item.title}" (${item.language.toUpperCase()})?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
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

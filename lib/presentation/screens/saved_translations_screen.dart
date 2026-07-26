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
              _buildSortMenuItem(
                context,
                SortOption.titleAsc,
                'Title A-Z',
                sortOption == SortOption.titleAsc,
              ),
              _buildSortMenuItem(
                context,
                SortOption.dateNewest,
                'Newest First',
                sortOption == SortOption.dateNewest,
              ),
              _buildSortMenuItem(
                context,
                SortOption.dateOldest,
                'Oldest First',
                sortOption == SortOption.dateOldest,
              ),
              _buildSortMenuItem(
                context,
                SortOption.language,
                'Language',
                sortOption == SortOption.language,
              ),
            ],
          ),
        ],
      ),
      body: savedAsync.when(
        loading: () => Semantics(
          label: 'Loading saved translations',
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => _ErrorState(error: e.toString()),
        data: (items) {
          if (items.isEmpty) {
            return _EmptyState();
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

  PopupMenuEntry<SortOption> _buildSortMenuItem(
    BuildContext context,
    SortOption option,
    String label,
    bool isSelected,
  ) {
    return PopupMenuItem<SortOption>(
      value: option,
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (isSelected)
            Icon(
              Icons.check,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
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

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load translations',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: 'No saved translations',
            child: const Icon(
              Icons.bookmark_border,
              size: 64,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No saved translations',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Save a translation from the player screen',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SavedSubtitleTile extends ConsumerWidget {
  final SavedSubtitle item;

  const _SavedSubtitleTile({required this.item});

  String _formatSeasonEpisode(int season, int episode) {
    return 'S${season.toString().padLeft(2, '0')}E${episode.toString().padLeft(2, '0')}';
  }

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
      if (item.season != null && item.episode != null) {
        displayTitle =
            '$displayTitle ${_formatSeasonEpisode(item.season!, item.episode!)}';
      }
    } else {
      displayTitle = item.title;
      if (item.year != null) {
        displayTitle = '$displayTitle (${item.year})';
      }
    }

    final badgeLabel = item.isTvShow ? 'TV show' : 'Movie';
    final badgeColor = item.isTvShow ? Colors.blue : Colors.orange;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: badgeColor.withValues(alpha: 0.15),
        child: Semantics(
          label: badgeLabel,
          child: Icon(
            item.isTvShow ? Icons.tv : Icons.movie,
            color: badgeColor,
            size: 20,
          ),
        ),
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

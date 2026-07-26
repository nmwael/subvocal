import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/errors/failures.dart';
import '../../domain/entities/search_result.dart';
import '../providers/auth_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/subtitle_list_tile.dart';
import 'player_screen.dart';
import 'settings_screen.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
          'You need to log in to download subtitles.\n\n'
          'Free accounts get 5 downloads per day.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final contentType = ref.watch(searchContentTypeProvider);
    final resultsAsync = query.isNotEmpty
        ? ref.watch(searchResultsProvider((query, contentType)))
        : const AsyncData<List<SearchResult>>([]);

    return Scaffold(
      appBar: AppBar(title: const Text('Search Subtitles')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by movie or show name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            ref.read(searchQueryProvider.notifier).state = '',
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) =>
                  ref.read(searchQueryProvider.notifier).state = value,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('All')),
                ButtonSegment(value: 'movie', label: Text('Movies')),
                ButtonSegment(value: 'episode', label: Text('TV Episodes')),
              ],
              selected: {contentType},
              onSelectionChanged: (selected) {
                ref.read(searchContentTypeProvider.notifier).state =
                    selected.first;
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: resultsAsync.when(
              data: (results) {
                if (query.isEmpty) {
                  return Center(
                    child: Text(
                      'Enter a movie or show name to search',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }
                if (results.isEmpty) {
                  return Center(
                    child: Text(
                      'No results found for "$query"',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return SubtitleListTile(
                      result: result,
                      onTap: () async {
                        final auth = ref.read(authProvider).valueOrNull;
                        if (auth?.status != AuthStatus.authenticated) {
                          if (context.mounted) _showLoginPrompt(context);
                          return;
                        }

                        final download = ref.read(downloadSubtitleProvider);
                        final (subtitle, failure) = await download.call(
                          result.fileId,
                        );
                        if (failure != null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(failure.message)),
                            );
                          }
                          return;
                        }
                        if (subtitle != null && context.mounted) {
                          final langSubtitle = subtitle.copyWith(
                            language: result.language,
                          );
                          ref.read(importedSubtitleProvider.notifier).state =
                              langSubtitle;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  PlayerScreen(subtitle: langSubtitle),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${error is Failure ? error.message : 'An unexpected error occurred'}',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

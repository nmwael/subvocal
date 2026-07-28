import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/help_reader.dart';
import '../../domain/errors/failures.dart';
import '../../domain/entities/search_result.dart';
import '../providers/auth_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/subtitle_list_tile.dart';
import 'player_screen.dart';
import 'settings_screen.dart';

const _openSubtitlesSignupUrl = 'https://www.opensubtitles.com/en/signup';

const _streamingServices = [
  ('', 'All'),
  ('NF', 'Netflix'),
  ('AMZN', 'Prime'),
  ('DSNY', 'Disney+'),
  ('MAX', 'HBO Max'),
  ('HULU', 'Hulu'),
  ('PCOK', 'Peacock'),
  ('PMNT', 'Paramount+'),
  ('ATVP', 'Apple TV+'),
];

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  void _showLoginPrompt(BuildContext context, WidgetRef ref) {
    const helpText = 'You need a free OpenSubtitles account to download subtitles.\n\n'
        'Free accounts get 5 downloads per day.\n\n'
        'You can also use SubDL or Podnapisi subtitles without logging in.';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Required'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(helpText),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Semantics(
                  label: 'Read help aloud',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.hearing, size: 20),
                    tooltip: 'Read aloud',
                    onPressed: () => HelpReader.from(ref).read(helpText),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final url = Uri.parse(_openSubtitlesSignupUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Create Free Account'),
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

  void _showHelpDialog(BuildContext context, WidgetRef ref) {
    const helpContent = 'Search for movie and TV subtitles by name.\n\n'
        'Results from SubDL and Podnapisi are always shown. '
        'OpenSubtitles results appear only when you are logged in.\n\n'
        'Free OpenSubtitles accounts get 5 downloads per day.';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Search Tips'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(helpContent),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Semantics(
                  label: 'Read help aloud',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.hearing, size: 20),
                    tooltip: 'Read aloud',
                    onPressed: () => HelpReader.from(ref).read(helpContent),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final url = Uri.parse(_openSubtitlesSignupUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Create Free Account'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final contentType = ref.watch(searchContentTypeProvider);
    final streamingFilter = ref.watch(searchStreamingProvider);
    final isLoggedIn = ref.watch(authProvider).valueOrNull?.status ==
        AuthStatus.authenticated;
    final resultsAsync = query.isNotEmpty
        ? ref.watch(searchResultsProvider((query, contentType)))
        : const AsyncData<List<SearchResult>>([]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Subtitles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () => _showHelpDialog(context, ref),
          ),
        ],
      ),
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
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _streamingServices.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final (tag, label) = _streamingServices[index];
                final isSelected = streamingFilter == tag;
                return FilterChip(
                  label: Text(label, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (_) {
                    ref.read(searchStreamingProvider.notifier).state = tag;
                  },
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: resultsAsync.when(
              data: (results) {
                final visibleResults = isLoggedIn
                    ? results
                    : results
                        .where((r) => r.providerSource != 'OpenSubtitles')
                        .toList();
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
                if (visibleResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          results.isEmpty
                              ? 'No results found for "$query"'
                              : 'No downloadable results found.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        if (results.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final url = Uri.parse(_openSubtitlesSignupUrl);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Text(
                              'Create a free OpenSubtitles account to unlock more results.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Semantics(
                            label: 'Read help aloud',
                            button: true,
                            child: IconButton(
                              icon: const Icon(Icons.hearing, size: 18),
                              tooltip: 'Read aloud',
                              onPressed: () => HelpReader.from(ref).read(
                                'No downloadable results found. '
                                'Create a free OpenSubtitles account to unlock more results.',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: visibleResults.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final result = visibleResults[index];
                    return SubtitleListTile(
                      result: result,
                      onTap: () async {
                        if (result.providerSource == 'OpenSubtitles') {
                          final auth = ref.read(authProvider).valueOrNull;
                          if (auth?.status != AuthStatus.authenticated) {
                            if (context.mounted) _showLoginPrompt(context, ref);
                            return;
                          }
                        }

                        final download = ref.read(downloadSubtitleProvider);
                        final (subtitle, failure) = await download.call(
                          result.fileId,
                          title: result.formattedTitle,
                          providerSource: result.providerSource,
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
                              builder: (_) => PlayerScreen(
                                subtitle: langSubtitle,
                                year: result.year,
                                season: result.season,
                                episode: result.episode,
                              ),
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

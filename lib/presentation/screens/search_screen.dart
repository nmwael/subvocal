import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final helpText = l10n.loginRequiredHelp;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.loginRequired),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(helpText),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Semantics(
                  label: l10n.readHelpAloud,
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.hearing, size: 20),
                    tooltip: l10n.readAloud,
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
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final url = Uri.parse(_openSubtitlesSignupUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(l10n.createFreeAccount),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            child: Text(l10n.login),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final helpContent = l10n.searchTipsContent;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.searchTips),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(helpContent),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Semantics(
                  label: l10n.readHelpAloud,
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
            onPressed: () async {
              final url = Uri.parse(_openSubtitlesSignupUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(l10n.createFreeAccount),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
        title: Text(l10n.searchTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n.searchHelp,
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
                hintText: l10n.searchHint,
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
              segments: [
                ButtonSegment(value: 'all', label: Text(l10n.all)),
                ButtonSegment(value: 'movie', label: Text(l10n.movies)),
                ButtonSegment(value: 'episode', label: Text(l10n.tvEpisodes)),
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
                final chipLabel = tag.isEmpty ? l10n.all : label;
                return FilterChip(
                  label: Text(chipLabel, style: const TextStyle(fontSize: 12)),
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
                        l10n.enterSearchQuery,
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
                                ? l10n.noResultsFound(query)
                                : l10n.noDownloadableResults,
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
                              l10n.createAccountForMore,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Semantics(
                            label: l10n.readHelpAloud,
                            button: true,
                            child: IconButton(
                              icon: const Icon(Icons.hearing, size: 18),
                              tooltip: l10n.readAloud,
                              onPressed: () => HelpReader.from(ref).read(
                                l10n.readHelpAloudNoResults,
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
                      error is Failure
                          ? l10n.searchError(error.message)
                          : l10n.unexpectedError,
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

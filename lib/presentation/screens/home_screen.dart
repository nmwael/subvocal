import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../generated/app_localizations.dart';
import '../utils/welcome_helper.dart';
import '../../domain/entities/recent_subtitle_info.dart';
import '../providers/recent_subtitles_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/alpha_chip.dart';
import '../widgets/alpha_notice_banner.dart';
import 'player_screen.dart';
import 'saved_translations_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WelcomeHelper.showIfFirstLaunch(context, ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recentSubtitles = ref.watch(recentSubtitlesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [Text('subvocal'), SizedBox(width: 8), AlphaChip()],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AlphaNoticeBanner(),
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
                    l10n.homeTagline,
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
                    label: Text(l10n.searchSubtitles),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SavedTranslationsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bookmark),
                    label: Text(l10n.savedTranslations),
                    style: OutlinedButton.styleFrom(
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
                  l10n.recent,
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
                    title: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      item.language ?? l10n.defaultLanguageLabel,
                      style: theme.textTheme.bodySmall,
                    ),
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

  void _openRecent(
    BuildContext context,
    WidgetRef ref,
    RecentSubtitleInfo info,
  ) {
    if (info.filePath.isNotEmpty) {
      ref.read(subtitleRepositoryProvider).importFromFile(info.filePath).then((
        result,
      ) {
        final (subtitle, failure) = result;
        if (failure != null && context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
          return;
        }
        if (subtitle != null && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PlayerScreen(subtitle: subtitle)),
          );
        }
      });
    }
  }
}

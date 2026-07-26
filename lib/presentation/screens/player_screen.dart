import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/subtitle.dart';
import '../../domain/entities/translation_progress.dart';
import '../providers/player_provider.dart';
import '../providers/saved_subtitles_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/playback_controls.dart';
import '../widgets/subtitle_display.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final Subtitle subtitle;
  final String? year;
  final int? season;
  final int? episode;

  const PlayerScreen({
    super.key,
    required this.subtitle,
    this.year,
    this.season,
    this.episode,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  StreamSubscription<int>? _indexSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider);
      ref
          .read(playerProvider.notifier)
          .load(
            widget.subtitle.entries,
            language: settings.selectedLanguage,
            voice: settings.selectedVoice,
            sourceLanguage: widget.subtitle.language,
            title: widget.subtitle.title,
            year: widget.year,
            season: widget.season,
            episode: widget.episode,
          );
    });
  }

  @override
  void dispose() {
    _indexSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    final playerNotifier = ref.read(playerProvider.notifier);

    final currentEntry =
        playerState.entries.isNotEmpty &&
            playerState.currentIndex < playerState.entries.length
        ? playerState.entries[playerState.currentIndex]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subtitle.title),
        actions: [
          if (playerState.translatedSubtitle != null)
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save translation',
              onPressed: () async {
                final saved = ref.read(savedSubtitlesProvider.notifier);
                await saved.save(
                  playerState.translatedSubtitle!,
                  playerState.translatedSubtitle!.language ?? '',
                  year: playerState.year,
                  season: playerState.season,
                  episode: playerState.episode,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Translation saved')),
                  );
                }
              },
            ),
          if (playerState.isPlaying || playerState.isPaused)
            IconButton(
              icon: const Icon(Icons.stop),
              tooltip: 'Stop',
              onPressed: playerNotifier.stop,
            ),
        ],
      ),
      body: Column(
        children: [
          if (playerState.error != null)
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Translation Error'),
                  content: SingleChildScrollView(
                    child: Text(playerState.error!),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Theme.of(context).colorScheme.errorContainer,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        playerState.error!.split('\n').first,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          if (playerState.isTranslating)
            _TranslationProgressIndicator(
              progress: playerState.translationProgress,
            ),
          Expanded(child: SubtitleDisplay(currentEntry: currentEntry)),
          if (playerState.entries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Slider(
                value: playerState.seekProgress,
                onChanged: (value) {
                  final index = (value * (playerState.entries.length - 1))
                      .round();
                  final entry = playerState.entries[index];
                  playerNotifier.seek(entry.start);
                },
              ),
            ),
          PlaybackControls(
            playerState: playerState,
            onPlay: playerNotifier.play,
            onPause: playerNotifier.pause,
            onResume: playerNotifier.resume,
            onStop: playerNotifier.stop,
            onNext: playerNotifier.next,
            onPrevious: playerNotifier.previous,
            onSpeedChanged: playerNotifier.setSpeed,
            onSyncOffsetChanged: playerNotifier.setSyncOffset,
            onSeek: playerNotifier.seek,
          ),
        ],
      ),
    );
  }
}

class _TranslationProgressIndicator extends StatelessWidget {
  final TranslationProgress? progress;

  const _TranslationProgressIndicator({this.progress});

  @override
  Widget build(BuildContext context) {
    final completed = progress?.completed ?? 0;
    final total = progress?.total ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: progress?.fraction ?? 0.0),
          const SizedBox(height: 8),
          Text(
            'Translating $completed/$total entries...',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

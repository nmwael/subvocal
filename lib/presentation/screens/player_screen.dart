import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/subtitle.dart';
import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/playback_controls.dart';
import '../widgets/subtitle_display.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final Subtitle subtitle;

  const PlayerScreen({super.key, required this.subtitle});

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
      ref.read(playerProvider.notifier).load(
            widget.subtitle.entries,
            language: settings.selectedLanguage,
            voice: settings.selectedVoice,
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

    final currentEntry = playerState.entries.isNotEmpty &&
            playerState.currentIndex < playerState.entries.length
        ? playerState.entries[playerState.currentIndex]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subtitle.title),
        actions: [
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Text(
                playerState.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          Expanded(
            child: SubtitleDisplay(currentEntry: currentEntry),
          ),
          if (playerState.entries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Slider(
                value: playerState.seekProgress,
                onChanged: (value) {
                  final index = (value * (playerState.entries.length - 1)).round();
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

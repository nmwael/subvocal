import 'package:flutter/material.dart';

import '../providers/player_provider.dart';

class PlaybackControls extends StatelessWidget {
  final PlayerState playerState;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<double> onSyncOffsetChanged;

  const PlaybackControls({
    super.key,
    required this.playerState,
    required this.onPlay,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onNext,
    required this.onPrevious,
    required this.onSpeedChanged,
    required this.onSyncOffsetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasEntries = playerState.entries.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ControlButton(
                  icon: Icons.skip_previous,
                  onPressed: hasEntries ? onPrevious : null,
                  tooltip: 'Previous',
                ),
                const SizedBox(width: 16),
                _ControlButton(
                  icon: playerState.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 48,
                  onPressed: hasEntries
                      ? () {
                          if (playerState.isPlaying) {
                            onPause();
                          } else if (playerState.isPaused) {
                            onResume();
                          } else {
                            onPlay();
                          }
                        }
                      : null,
                  tooltip: playerState.isPlaying ? 'Pause' : 'Play',
                ),
                const SizedBox(width: 16),
                _ControlButton(
                  icon: Icons.skip_next,
                  onPressed: hasEntries ? onNext : null,
                  tooltip: 'Next',
                ),
                const SizedBox(width: 16),
                _ControlButton(
                  icon: Icons.stop,
                  onPressed: hasEntries ? onStop : null,
                  tooltip: 'Stop',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Sync'),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: playerState.syncOffset,
                    min: -5.0,
                    max: 5.0,
                    divisions: 20,
                    label: '${playerState.syncOffset.toStringAsFixed(1)}s',
                    onChanged: hasEntries ? onSyncOffsetChanged : null,
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${playerState.syncOffset.toStringAsFixed(1)}s',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Speed'),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: playerState.speed,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    label: '${(playerState.speed * 100).round()}%',
                    onChanged: hasEntries ? onSpeedChanged : null,
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${(playerState.speed * 100).round()}%',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback? onPressed;
  final String tooltip;

  const _ControlButton({
    required this.icon,
    this.size = 36,
    this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon),
        iconSize: size,
        onPressed: onPressed,
      ),
    );
  }
}

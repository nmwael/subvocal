import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../providers/player_provider.dart';

class PlaybackControls extends StatefulWidget {
  final PlayerState playerState;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<double> onSyncOffsetChanged;
  final ValueChanged<Duration> onSeek;

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
    required this.onSeek,
  });

  @override
  State<PlaybackControls> createState() => _PlaybackControlsState();
}

class _PlaybackControlsState extends State<PlaybackControls> {
  final _timeController = TextEditingController();
  bool _isEditingTime = false;

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Duration? _parseTimestamp(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    final parts = trimmed.split(':');
    if (parts.length == 3) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final s = int.tryParse(parts[2]);
      if (h == null || m == null || s == null) return null;
      if (m > 59 || s > 59) return null;
      return Duration(hours: h, minutes: m, seconds: s);
    }
    if (parts.length == 2) {
      final m = int.tryParse(parts[0]);
      final s = int.tryParse(parts[1]);
      if (m == null || s == null) return null;
      if (s > 59) return null;
      return Duration(minutes: m, seconds: s);
    }
    final totalSeconds = int.tryParse(trimmed);
    if (totalSeconds != null) return Duration(seconds: totalSeconds);

    return null;
  }

  void _submitTimestamp() {
    final duration = _parseTimestamp(_timeController.text);
    if (duration != null) {
      widget.onSeek(duration);
    }
    setState(() => _isEditingTime = false);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final hasEntries = widget.playerState.entries.isNotEmpty;

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
                  onPressed: hasEntries ? widget.onPrevious : null,
                  tooltip: 'Previous',
                ),
                const SizedBox(width: 16),
                _ControlButton(
                  icon: widget.playerState.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 48,
                  onPressed: hasEntries
                      ? () {
                          if (widget.playerState.isPlaying) {
                            widget.onPause();
                          } else if (widget.playerState.isPaused) {
                            widget.onResume();
                          } else {
                            widget.onPlay();
                          }
                        }
                      : null,
                  tooltip: widget.playerState.isPlaying ? 'Pause' : 'Play',
                ),
                const SizedBox(width: 16),
                _ControlButton(
                  icon: Icons.skip_next,
                  onPressed: hasEntries ? widget.onNext : null,
                  tooltip: 'Next',
                ),
                const SizedBox(width: 16),
                _ControlButton(
                  icon: Icons.stop,
                  onPressed: hasEntries ? widget.onStop : null,
                  tooltip: 'Stop',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: _isEditingTime
                      ? TextField(
                          controller: _timeController,
                          keyboardType: const TextInputType.numberWithOptions(),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                          ],
                          decoration: InputDecoration(
                            hintText: 'e.g. 5:30 or 1:02:15',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          autofocus: true,
                          onEditingComplete: _submitTimestamp,
                          onSubmitted: (_) => _submitTimestamp(),
                        )
                      : GestureDetector(
                          onTap: hasEntries
                              ? () {
                                  _timeController.text =
                                      _formatDuration(widget.playerState.currentPosition);
                                  setState(() => _isEditingTime = true);
                                }
                              : null,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: const Icon(Icons.edit, size: 16),
                            ),
                            child: Text(
                              _formatDuration(widget.playerState.currentPosition),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Sync'),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: widget.playerState.syncOffset,
                    min: -5.0,
                    max: 5.0,
                    divisions: 20,
                    label: '${widget.playerState.syncOffset.toStringAsFixed(1)}s',
                    onChanged: hasEntries ? widget.onSyncOffsetChanged : null,
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${widget.playerState.syncOffset.toStringAsFixed(1)}s',
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
                    value: widget.playerState.speed,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    label: '${(widget.playerState.speed * 100).round()}%',
                    onChanged: hasEntries ? widget.onSpeedChanged : null,
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${(widget.playerState.speed * 100).round()}%',
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

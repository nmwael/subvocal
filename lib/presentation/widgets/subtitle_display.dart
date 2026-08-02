import 'package:flutter/material.dart';

import '../../domain/entities/subtitle_entry.dart';
import '../../generated/app_localizations.dart';

class SubtitleDisplay extends StatelessWidget {
  final SubtitleEntry? currentEntry;
  final int currentWordIndex; // -1 indicates not speaking or between words

  const SubtitleDisplay({
    super.key,
    this.currentEntry,
    this.currentWordIndex = -1,
  });

  @override
  Widget build(BuildContext context) {
    if (currentEntry == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.subtitles_off,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noSubtitleLoaded,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    final entry = currentEntry!;
    final words = entry.text.split(' ');
    final hasWordHighlight =
        currentWordIndex >= 0 && currentWordIndex < words.length;

    final wordStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            hasWordHighlight
                ? Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      for (int i = 0; i < words.length; i++)
                        Text(
                          words[i],
                          style: i == currentWordIndex
                              ? wordStyle?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withValues(alpha: 0.2),
                                )
                              : wordStyle,
                          textAlign: TextAlign.center,
                        ),
                    ],
                  )
                : Text(
                    entry.text,
                    style: wordStyle,
                    textAlign: TextAlign.center,
                  ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_formatTimestamp(entry.start)} → ${_formatTimestamp(entry.end)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

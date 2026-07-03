import 'package:flutter/material.dart';

import '../../domain/entities/search_result.dart';

class SubtitleListTile extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const SubtitleListTile({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(Icons.subtitles, color: theme.colorScheme.onPrimaryContainer),
      ),
      title: Text(
        result.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Row(
        children: [
          if (result.year != null) ...[
            Text(result.year!),
            const SizedBox(width: 8),
          ],
          if (result.language != null)
            Chip(
              label: Text(result.language!, style: const TextStyle(fontSize: 11)),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
        ],
      ),
      trailing: const Icon(Icons.download),
      onTap: onTap,
    );
  }
}

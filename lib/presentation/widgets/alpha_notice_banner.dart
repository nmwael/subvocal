import 'package:flutter/material.dart';

import '../../generated/app_localizations.dart';

class AlphaNoticeBanner extends StatefulWidget {
  const AlphaNoticeBanner({super.key});

  @override
  State<AlphaNoticeBanner> createState() => _AlphaNoticeBannerState();
}

class _AlphaNoticeBannerState extends State<AlphaNoticeBanner> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: MaterialBanner(
        leading: Icon(Icons.info_outline, color: theme.colorScheme.tertiary),
        content: Text(
          l10n.alphaBanner,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.colorScheme.tertiaryContainer,
        actions: [
          TextButton(
            onPressed: () => setState(() => _visible = false),
            child: Text(l10n.dismiss),
          ),
        ],
      ),
    );
  }
}

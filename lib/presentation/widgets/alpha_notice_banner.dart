import 'package:flutter/material.dart';

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

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: MaterialBanner(
        leading: Icon(Icons.info_outline, color: theme.colorScheme.tertiary),
        content: Text(
          'This app is in alpha. Features may change and bugs are expected.',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.colorScheme.tertiaryContainer,
        actions: [
          TextButton(
            onPressed: () => setState(() => _visible = false),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}

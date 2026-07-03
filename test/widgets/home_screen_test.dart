import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/presentation/providers/recent_subtitles_provider.dart';
import 'package:subvocal/presentation/screens/home_screen.dart';

final _mockRecentProvider = StateNotifierProvider<RecentSubtitlesNotifier, List<RecentSubtitleInfo>>((ref) {
  return RecentSubtitlesNotifier();
});

Widget _createTestApp() {
  return ProviderScope(
    overrides: [
      recentSubtitlesProvider.overrideWithProvider(_mockRecentProvider),
    ],
    child: const MaterialApp(
      home: HomeScreen(),
    ),
  );
}

void main() {
  testWidgets('shows app title and description', (tester) async {
    await tester.pumpWidget(_createTestApp());

    expect(find.text('subvocal'), findsOneWidget);
    expect(find.text('Pick subtitles and read them aloud'), findsOneWidget);
  });

  testWidgets('shows import and search buttons', (tester) async {
    await tester.pumpWidget(_createTestApp());

    expect(find.text('Import .SRT file'), findsOneWidget);
    expect(find.text('Search OpenSubtitles'), findsOneWidget);
  });
}

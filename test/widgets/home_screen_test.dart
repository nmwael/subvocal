import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/presentation/providers/recent_subtitles_provider.dart';
import 'package:subvocal/presentation/screens/home_screen.dart';

Widget _createTestApp() {
  return ProviderScope(
    overrides: [
      recentSubtitlesProvider.overrideWith((ref) => RecentSubtitlesNotifier()),
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

  testWidgets('shows search button', (tester) async {
    await tester.pumpWidget(_createTestApp());

    expect(find.text('Search subtitles'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:subvocal/app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Home to Player flow', () {
    testWidgets('shows import and search buttons on home screen', (tester) async {
      await tester.pumpWidget(const SubvocalApp());
      await tester.pumpAndSettle();

      expect(find.text('Import .SRT file'), findsOneWidget);
      expect(find.text('Search OpenSubtitles'), findsOneWidget);

      await binding.takeScreenshot('home_buttons');
    });

    testWidgets('search screen displays empty state', (tester) async {
      await tester.pumpWidget(const SubvocalApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search OpenSubtitles'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a movie or show name to search'), findsOneWidget);
      await binding.takeScreenshot('search_empty');
    });

    testWidgets('navigates back from search to home', (tester) async {
      await tester.pumpWidget(const SubvocalApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search OpenSubtitles'));
      await tester.pumpAndSettle();

      expect(find.text('Search Subtitles'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Import .SRT file'), findsOneWidget);
      await binding.takeScreenshot('home_after_search');
    });
  });
}

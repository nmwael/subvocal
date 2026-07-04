import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:subvocal/app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.convertFlutterSurfaceToImage();

  group('App E2E', () {
    testWidgets('renders home screen with correct elements', (tester) async {
      await tester.pumpWidget(const SubvocalApp());
      await tester.pumpAndSettle();

      expect(find.text('subvocal'), findsWidgets);
      expect(find.text('Pick subtitles and read them aloud'), findsOneWidget);
      expect(find.text('Import .SRT file'), findsOneWidget);
      expect(find.text('Search OpenSubtitles'), findsOneWidget);

      await binding.takeScreenshot('home_screen');
    });

    testWidgets('navigates to search screen', (tester) async {
      await tester.pumpWidget(const SubvocalApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search OpenSubtitles'));
      await tester.pumpAndSettle();

      expect(find.text('Search Subtitles'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await binding.takeScreenshot('search_screen');

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Import .SRT file'), findsOneWidget);
    });

    testWidgets('search field accepts input', (tester) async {
      await tester.pumpWidget(const SubvocalApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search OpenSubtitles'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Inception');
      await tester.pumpAndSettle();

      expect(find.text('Inception'), findsOneWidget);
      await binding.takeScreenshot('search_with_query');
    });

    testWidgets('displays empty state on search screen', (tester) async {
      await tester.pumpWidget(const SubvocalApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search OpenSubtitles'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a movie or show name to search'), findsOneWidget);
      await binding.takeScreenshot('search_empty_state');
    });

    testWidgets('stop button hidden when no player active', (tester) async {
      await tester.pumpWidget(const SubvocalApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.stop), findsNothing);
      await binding.takeScreenshot('home_no_player');
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:subvocal/app.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    binding.convertFlutterSurfaceToImage();
  });

  group('Search flow', () {
    testWidgets('search screen renders with all elements', (tester) async {
      await tester.pumpWidget(const SubvocalApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search OpenSubtitles'));
      await tester.pumpAndSettle();

      expect(find.text('Search Subtitles'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsWidgets);

      await binding.takeScreenshot('search_initial');
    });

    testWidgets('typing in search field shows clear button', (tester) async {
      await tester.pumpWidget(const SubvocalApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search OpenSubtitles'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.clear), findsOneWidget);
      await binding.takeScreenshot('search_with_text');
    });

    testWidgets('clearing search field removes results', (tester) async {
      await tester.pumpWidget(const SubvocalApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search OpenSubtitles'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text('Enter a movie or show name to search'), findsOneWidget);
      await binding.takeScreenshot('search_cleared');
    });
  });
}

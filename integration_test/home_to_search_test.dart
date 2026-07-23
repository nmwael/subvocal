import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'screenshot_helper.dart';
import 'package:subvocal/app.dart';

const _settleTimeout = Duration(seconds: 10);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    binding.convertFlutterSurfaceToImage();
  });

  group('Search flow', () {
    testWidgets('search screen renders with all elements', (tester) async {
      await tester.pumpWidget(const SubvocalApp());
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      await tester.ensureVisible(find.text('Search subtitles'));
      await tester.tap(find.text('Search subtitles'));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      // Wait for the search screen to fully load
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      expect(find.text('Search Subtitles'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsWidgets);

      await takeScreenshot(binding, 'search_initial');
    });

    testWidgets('typing in search field shows clear button', (tester) async {
      await tester.pumpWidget(const SubvocalApp());
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      await tester.ensureVisible(find.text('Search subtitles'));
      await tester.tap(find.text('Search subtitles'));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      // Wait for the search screen to fully load
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
      await takeScreenshot(binding, 'search_with_text');
    });

    testWidgets('clearing search field removes results', (tester) async {
      await tester.pumpWidget(const SubvocalApp());
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      await tester.ensureVisible(find.text('Search subtitles'));
      await tester.tap(find.text('Search subtitles'));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      // Wait for the search screen to fully load
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      expect(find.text('Enter a movie or show name to search'), findsOneWidget);
      await takeScreenshot(binding, 'search_cleared');
    });
  });
}

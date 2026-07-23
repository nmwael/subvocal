import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:subvocal/app.dart';
import 'screenshot_helper.dart';

const _settleTimeout = Duration(seconds: 10);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    binding.convertFlutterSurfaceToImage();
  });

  group('App E2E', () {
    testWidgets('renders home screen with correct elements', (tester) async {
      await tester.pumpWidget(const SubvocalApp());
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      expect(find.text('subvocal'), findsWidgets);
      expect(find.text('Pick subtitles and read them aloud'), findsOneWidget);
      expect(find.text('Search subtitles'), findsOneWidget);

      await takeScreenshot(binding, 'home_screen');
    });

    testWidgets('navigates to search screen', (tester) async {
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
      expect(find.byType(TextField), findsOneWidget);

      await takeScreenshot(binding, 'search_screen');

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      expect(find.text('Search subtitles'), findsOneWidget);
    });

    testWidgets('search field accepts input', (tester) async {
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

      await tester.enterText(find.byType(TextField), 'Inception');
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      expect(find.text('Inception'), findsWidgets);
      await takeScreenshot(binding, 'search_with_query');
    });

    testWidgets('displays empty state on search screen', (tester) async {
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

      expect(find.text('Enter a movie or show name to search'), findsOneWidget);
      await takeScreenshot(binding, 'search_empty_state');
    });

    testWidgets('stop button hidden when no player active', (tester) async {
      await tester.pumpWidget(const SubvocalApp());
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      expect(find.byIcon(Icons.stop), findsNothing);
      await takeScreenshot(binding, 'home_no_player');
    });
  });
}

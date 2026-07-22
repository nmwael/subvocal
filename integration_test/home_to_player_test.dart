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

  group('Home to Player flow', () {
    testWidgets('shows import and search buttons on home screen', (tester) async {
      await tester.pumpWidget(const SubvocalApp());
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      expect(find.text('Search subtitles'), findsOneWidget);

      await takeScreenshot(binding, 'home_buttons');
    });

    testWidgets('search screen displays empty state', (tester) async {
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

      expect(find.text('Enter a movie or show name to search'), findsOneWidget);
      await takeScreenshot(binding, 'search_empty');
    });

    testWidgets('navigates back from search to home', (tester) async {
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

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      expect(find.text('Search subtitles'), findsOneWidget);
      await takeScreenshot(binding, 'home_after_search');
    });
  });
}

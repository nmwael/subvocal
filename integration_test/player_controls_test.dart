import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'screenshot_helper.dart';
import 'package:subvocal/core/utils/srt_parser.dart';
import 'package:subvocal/domain/entities/subtitle.dart';
import 'package:subvocal/presentation/screens/player_screen.dart';
import 'package:subvocal/presentation/widgets/playback_controls.dart';
import 'package:subvocal/presentation/widgets/subtitle_display.dart';

const _settleTimeout = Duration(seconds: 10);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    binding.convertFlutterSurfaceToImage();
  });

  group('Player controls', () {
    late Subtitle testSubtitle;

    setUp(() {
      final parser = SrtParser();
      const srt = '1\n00:00:01,000 --> 00:00:04,000\nHello world\n\n'
          '2\n00:00:05,000 --> 00:00:08,000\nSecond subtitle';
      final entries = parser.parse(srt);
      testSubtitle = Subtitle(title: 'Test', entries: entries);
    });

    testWidgets('player screen renders with subtitle content', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: PlayerScreen(subtitle: testSubtitle),
          ),
        ),
      );
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(PlaybackControls), findsOneWidget);
      await takeScreenshot(binding, 'player_initial');
    });

    testWidgets('player screen shows play/pause controls', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: PlayerScreen(subtitle: testSubtitle),
          ),
        ),
      );
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
      await takeScreenshot(binding, 'player_controls');
    });

    testWidgets('player screen shows subtitle display area', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: PlayerScreen(subtitle: testSubtitle),
          ),
        ),
      );
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      expect(find.byType(SubtitleDisplay), findsOneWidget);
      await takeScreenshot(binding, 'player_progress');
    });

    testWidgets('player screen app bar has stop button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: PlayerScreen(subtitle: testSubtitle),
          ),
        ),
      );
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        _settleTimeout,
      );

      final stopButton = find.byTooltip('Stop');
      expect(stopButton, findsOneWidget);
      await takeScreenshot(binding, 'player_appbar');
    });
  });
}

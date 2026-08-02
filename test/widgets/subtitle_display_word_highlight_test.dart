import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/domain/entities/subtitle_entry.dart';
import 'package:subvocal/generated/app_localizations.dart';
import 'package:subvocal/presentation/widgets/subtitle_display.dart';

void main() {
  Widget createTestApp({
    required SubtitleEntry entry,
    int currentWordIndex = -1,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SubtitleDisplay(
          currentEntry: entry,
          currentWordIndex: currentWordIndex,
        ),
      ),
    );
  }

  group('SubtitleDisplay - Word Highlight', () {
    testWidgets('renders full text when no word index', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          entry: const SubtitleEntry(
            index: 1,
            start: Duration(seconds: 1),
            end: Duration(seconds: 4),
            text: 'Hello world',
          ),
          currentWordIndex: -1,
        ),
      );

      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('highlights word at currentWordIndex', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          entry: const SubtitleEntry(
            index: 1,
            start: Duration(seconds: 1),
            end: Duration(seconds: 4),
            text: 'Hello world',
          ),
          currentWordIndex: 0,
        ),
      );

      // Should find 'Hello' with highlight styling
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('world'), findsOneWidget);
    });

    testWidgets('highlights second word when index is 1', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          entry: const SubtitleEntry(
            index: 1,
            start: Duration(seconds: 1),
            end: Duration(seconds: 4),
            text: 'Hello world',
          ),
          currentWordIndex: 1,
        ),
      );

      expect(find.text('world'), findsOneWidget);
    });

    testWidgets('handles multi-word subtitle', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          entry: const SubtitleEntry(
            index: 1,
            start: Duration(seconds: 1),
            end: Duration(seconds: 6),
            text: 'The quick brown fox',
          ),
          currentWordIndex: 2,
        ),
      );

      expect(find.text('brown'), findsOneWidget);
    });

    testWidgets('shows timestamp when entry has start/end', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          entry: const SubtitleEntry(
            index: 1,
            start: Duration(seconds: 1),
            end: Duration(seconds: 4),
            text: 'Test entry',
          ),
          currentWordIndex: -1,
        ),
      );

      // Timestamp should be visible
      expect(find.textContaining('00:00:01'), findsOneWidget);
      expect(find.textContaining('00:00:04'), findsOneWidget);
    });
  });
}

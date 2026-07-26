import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/data/datasources/recent_subtitles_local_source.dart';
import 'package:subvocal/domain/entities/recent_subtitle_info.dart';
import 'package:subvocal/presentation/providers/recent_subtitles_provider.dart';
import 'package:subvocal/presentation/screens/home_screen.dart';

class _FakeRecentSubtitlesNotifier extends RecentSubtitlesNotifier {
  _FakeRecentSubtitlesNotifier() : super(_FakeLocalSource());
}

class _FakeLocalSource extends RecentSubtitlesLocalSource {
  @override
  Future<List<RecentSubtitleInfo>> load() async => [];
  @override
  Future<void> save(List<RecentSubtitleInfo> items) async {}
}

Widget _createTestApp() {
  return ProviderScope(
    overrides: [
      recentSubtitlesProvider.overrideWith(
        (ref) => _FakeRecentSubtitlesNotifier(),
      ),
    ],
    child: const MaterialApp(home: HomeScreen()),
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

  testWidgets('shows alpha chip in app bar', (tester) async {
    await tester.pumpWidget(_createTestApp());

    expect(find.text('ALPHA'), findsOneWidget);
  });

  testWidgets('shows alpha notice banner', (tester) async {
    await tester.pumpWidget(_createTestApp());

    expect(
      find.text(
        'This app is in alpha. Features may change and bugs are expected.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('dismisses alpha banner on tap', (tester) async {
    await tester.pumpWidget(_createTestApp());

    expect(find.text('Dismiss'), findsOneWidget);
    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This app is in alpha. Features may change and bugs are expected.',
      ),
      findsNothing,
    );
  });
}

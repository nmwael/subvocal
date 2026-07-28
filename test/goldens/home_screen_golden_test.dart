import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subvocal/data/datasources/recent_subtitles_local_source.dart';
import 'package:subvocal/domain/entities/recent_subtitle_info.dart';
import 'package:subvocal/presentation/providers/recent_subtitles_provider.dart';
import 'package:subvocal/presentation/screens/home_screen.dart';

import '../helpers/golden_test_helpers.dart';

class _FakeRecentSubtitlesNotifier extends RecentSubtitlesNotifier {
  _FakeRecentSubtitlesNotifier(super.source);
}

class _FakeLocalSource extends RecentSubtitlesLocalSource {
  final List<RecentSubtitleInfo> _items;
  _FakeLocalSource([this._items = const []]);
  @override
  Future<List<RecentSubtitleInfo>> load() async => _items;
  @override
  Future<void> save(List<RecentSubtitleInfo> items) async {}
}

void main() {
  group('HomeScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'welcome_dialog_seen': true,
      });
    });

    testWidgets('empty recent list', (tester) async {
      await screenMatchesGolden(
        tester,
        ProviderScope(
          overrides: [
            recentSubtitlesProvider.overrideWith(
              (ref) => _FakeRecentSubtitlesNotifier(_FakeLocalSource()),
            ),
          ],
          child: const HomeScreen(),
        ),
        'home_screen_empty_recent',
      );
    });

    testWidgets('with recent items', (tester) async {
      final items = [
        RecentSubtitleInfo(
          title: 'The Matrix',
          filePath: '/tmp/matrix.srt',
          language: 'en',
          addedAt: DateTime(2025, 1, 15),
        ),
        RecentSubtitleInfo(
          title: 'Inception',
          filePath: '/tmp/inception.srt',
          language: 'es',
          addedAt: DateTime(2025, 1, 10),
        ),
        RecentSubtitleInfo(
          title: 'Interstellar',
          filePath: '/tmp/interstellar.srt',
          language: 'da',
          addedAt: DateTime(2025, 1, 5),
        ),
      ];
      await screenMatchesGolden(
        tester,
        ProviderScope(
          overrides: [
            recentSubtitlesProvider.overrideWith(
              (ref) => _FakeRecentSubtitlesNotifier(_FakeLocalSource(items)),
            ),
          ],
          child: const HomeScreen(),
        ),
        'home_screen_with_recent',
      );
    });
  });
}

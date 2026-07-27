import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/domain/entities/saved_subtitle.dart';
import 'package:subvocal/presentation/providers/saved_subtitles_provider.dart';
import 'package:subvocal/presentation/screens/saved_translations_screen.dart';

import '../helpers/golden_test_helpers.dart';

void main() {
  group('SavedTranslationsScreen', () {
    testWidgets('empty state', (tester) async {
      await screenMatchesGolden(
        tester,
        ProviderScope(
          overrides: [
            savedSubtitlesProvider.overrideWith(
              (ref) => _FakeSavedNotifier([]),
            ),
          ],
          child: const SavedTranslationsScreen(),
        ),
        'saved_translations_empty',
      );
    });

    testWidgets('with items', (tester) async {
      final items = [
        SavedSubtitle(
          id: '1',
          title: 'The Matrix',
          language: 'es',
          entryCount: 120,
          savedAt: DateTime(2025, 1, 15),
          entries: const [],
          year: '1999',
        ),
        SavedSubtitle(
          id: '2',
          title: 'Inception',
          language: 'da',
          entryCount: 95,
          savedAt: DateTime(2025, 1, 10),
          entries: const [],
          year: '2010',
        ),
        SavedSubtitle(
          id: '3',
          title: 'The Office',
          language: 'en',
          entryCount: 150,
          savedAt: DateTime(2025, 1, 5),
          entries: const [],
          year: '2005',
          season: 2,
          episode: 5,
        ),
      ];
      await screenMatchesGolden(
        tester,
        ProviderScope(
          overrides: [
            savedSubtitlesProvider.overrideWith(
              (ref) => _FakeSavedNotifier(items),
            ),
          ],
          child: const SavedTranslationsScreen(),
        ),
        'saved_translations_with_items',
      );
    });
  });
}

class _FakeSavedNotifier extends StateNotifier<AsyncValue<List<SavedSubtitle>>>
    implements SavedSubtitlesNotifier {
  _FakeSavedNotifier(List<SavedSubtitle> items) : super(AsyncValue.data(items));

  @override
  Future<SavedSubtitle> save(
    subtitle,
    String language, {
    String? year,
    int? season,
    int? episode,
  }) async => throw UnimplementedError();

  @override
  Future<void> delete(String id) async {}
}

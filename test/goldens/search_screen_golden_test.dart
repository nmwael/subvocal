import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/presentation/providers/search_provider.dart';
import 'package:subvocal/presentation/screens/search_screen.dart';

import '../helpers/golden_test_helpers.dart';

void main() {
  group('SearchScreen', () {
    testWidgets('empty query', (tester) async {
      await screenMatchesGolden(
        tester,
        ProviderScope(
          overrides: [searchQueryProvider.overrideWith((ref) => '')],
          child: const SearchScreen(),
        ),
        'search_screen_empty',
      );
    });

    testWidgets('with results', (tester) async {
      await screenMatchesGolden(
        tester,
        ProviderScope(
          overrides: [searchQueryProvider.overrideWith((ref) => 'matrix')],
          child: const SearchScreen(),
        ),
        'search_screen_with_query',
      );
    });
  });
}

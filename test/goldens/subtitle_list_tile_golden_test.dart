import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/domain/entities/search_result.dart';
import 'package:subvocal/presentation/widgets/subtitle_list_tile.dart';

import '../helpers/golden_test_helpers.dart';

void main() {
  group('SubtitleListTile', () {
    testWidgets('with year and language', (tester) async {
      await screenMatchesGolden(
        tester,
        Scaffold(
          body: SubtitleListTile(
            result: const SearchResult(
              title: 'The Matrix',
              year: '1999',
              language: 'English',
              fileId: 123,
            ),
            onTap: () {},
          ),
        ),
        'subtitle_list_tile_full',
      );
    });

    testWidgets('minimal - title only', (tester) async {
      await screenMatchesGolden(
        tester,
        Scaffold(
          body: SubtitleListTile(
            result: const SearchResult(
              title: 'Some Movie With A Very Long Title',
              fileId: 456,
            ),
            onTap: () {},
          ),
        ),
        'subtitle_list_tile_minimal',
      );
    });
  });
}

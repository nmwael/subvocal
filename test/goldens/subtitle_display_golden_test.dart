import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/domain/entities/subtitle_entry.dart';
import 'package:subvocal/presentation/widgets/subtitle_display.dart';

import '../helpers/golden_test_helpers.dart';

void main() {
  group('SubtitleDisplay', () {
    testWidgets('empty state', (tester) async {
      await screenMatchesGolden(
        tester,
        const SubtitleDisplay(),
        'subtitle_display_empty',
      );
    });

    testWidgets('with active entry', (tester) async {
      await screenMatchesGolden(
        tester,
        const SubtitleDisplay(
          currentEntry: SubtitleEntry(
            index: 1,
            start: Duration(seconds: 10),
            end: Duration(seconds: 14),
            text: 'Hello, world!',
          ),
        ),
        'subtitle_display_with_entry',
      );
    });
  });
}

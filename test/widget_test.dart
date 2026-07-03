import 'package:flutter_test/flutter_test.dart';

import 'package:subvocal/app.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SubvocalApp());

    expect(find.text('subvocal'), findsWidgets);
    expect(find.text('Pick subtitles and read them aloud'), findsOneWidget);
  });
}

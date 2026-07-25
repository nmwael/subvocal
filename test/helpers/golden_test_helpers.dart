import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/core/theme/app_theme.dart';

Widget buildGoldenApp({
  required Widget child,
  List<Override> overrides = const [],
  Size? surfaceSize,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: child,
    ),
  );
}

Future<void> screenMatchesGolden(
  WidgetTester tester,
  Widget widget,
  String goldenName, {
  Size? surfaceSize,
}) async {
  if (surfaceSize != null) {
    await tester.binding.setSurfaceSize(surfaceSize);
  }
  await tester.pumpWidget(buildGoldenApp(child: widget));
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$goldenName.png'),
  );
  if (surfaceSize != null) {
    await tester.binding.setSurfaceSize(const Size(800, 600));
  }
}

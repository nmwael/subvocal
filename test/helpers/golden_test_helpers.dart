import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/core/theme/app_theme.dart';
import 'package:subvocal/generated/app_localizations.dart';

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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
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

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:subvocal/app.dart';
import 'package:subvocal/generated/app_localizations.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProviderScope(child: SubvocalApp()),
      ),
    );
    await tester.pump();

    expect(find.text('subvocal'), findsWidgets);
    expect(find.text('Pick subtitles and read them aloud'), findsOneWidget);
  });
}

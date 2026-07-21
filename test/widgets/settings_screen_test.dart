import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/presentation/screens/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen renders speech configuration and translation options', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    expect(find.text('Readout Settings'), findsOneWidget);
    expect(find.text('Speech Configuration'), findsOneWidget);
    expect(find.text('Speech Rate (Speed)'), findsOneWidget);
    expect(find.text('Voice Pitch'), findsOneWidget);
    expect(find.text('Translation & Language'), findsOneWidget);
    expect(find.text('Default Target Language'), findsOneWidget);
  });
}

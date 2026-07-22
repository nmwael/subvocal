import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/presentation/providers/auth_provider.dart';
import 'package:subvocal/presentation/providers/test_voice_provider.dart';
import 'package:subvocal/presentation/screens/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen renders top sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => _MockAuthNotifier()),
          testVoicePlayingProvider.overrideWith((ref) => false),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Readout Settings'), findsOneWidget);
    expect(find.text('OpenSubtitles Account'), findsOneWidget);
    expect(find.text('Speech Configuration'), findsOneWidget);
  });

  testWidgets('SettingsScreen renders bottom sections after scroll', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => _MockAuthNotifier()),
          testVoicePlayingProvider.overrideWith((ref) => false),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    // Scroll to bottom
    final listView = find.byType(ListView);
    await tester.drag(listView, const Offset(0, -800));
    await tester.pumpAndSettle();

    expect(find.text('Test Voice'), findsOneWidget);
    expect(find.text('Translation & Language'), findsOneWidget);
    expect(find.text('Default Target Language'), findsOneWidget);
  });
}

class _MockAuthNotifier extends AsyncNotifier<AuthState>
    implements AuthNotifier {
  @override
  Future<AuthState> build() async => const AuthState.unauthenticated();

  @override
  Future<bool> login(String username, String password) async => false;

  @override
  Future<void> logout() async {}
}

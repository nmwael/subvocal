import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/presentation/providers/auth_provider.dart';
import 'package:subvocal/presentation/providers/settings_provider.dart';
import 'package:subvocal/presentation/providers/test_voice_provider.dart';
import 'package:subvocal/presentation/screens/settings_screen.dart';

void main() {
  Widget buildTestWidget({
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        authProvider.overrideWith(() => _MockAuthNotifier()),
        testVoicePlayingProvider.overrideWith((ref) => false),
        translatedTestPlayingProvider.overrideWith((ref) => false),
        ...overrides,
      ],
      child: const MaterialApp(
        home: SettingsScreen(),
      ),
    );
  }

  testWidgets('SettingsScreen renders top sections', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump();

    expect(find.text('Readout Settings'), findsOneWidget);
    expect(find.text('OpenSubtitles Account'), findsOneWidget);
    expect(find.text('Speech Configuration'), findsOneWidget);
  });

  testWidgets('Voice selector renders with available voices', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      overrides: [
        availableVoicesProvider.overrideWith((ref) async => [
              {'name': 'Alice', 'language': 'en-US'},
              {'name': 'Bob', 'language': 'en-GB'},
            ]),
      ],
    ));
    await tester.pump();

    expect(find.text('Voice'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });

  testWidgets('Voice selector shows empty state when no voices', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      overrides: [
        availableVoicesProvider.overrideWith((ref) async => <Map<String, String>>[]),
      ],
    ));
    await tester.pump();

    expect(find.textContaining('No voices available'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
  });

  testWidgets('Translated preview shows text when available', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 3000));
    await tester.pumpWidget(buildTestWidget(
      overrides: [
        translatedTestPreviewProvider('en').overrideWith((ref) async => [
              'Hola, mundo!',
              'Segunda línea',
            ]),
      ],
    ));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Hola, mundo!'), findsOneWidget);

    await tester.binding.setSurfaceSize(const Size(800, 600));
  });

  testWidgets('Translated preview shows empty state when no translations', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 3000));
    await tester.pumpWidget(buildTestWidget(
      overrides: [
        translatedTestPreviewProvider('en').overrideWith((ref) async => <String>[]),
      ],
    ));
    await tester.pump();
    await tester.pump();

    expect(find.text('No translations available.'), findsOneWidget);

    await tester.binding.setSurfaceSize(const Size(800, 600));
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

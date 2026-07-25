import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/presentation/providers/auth_provider.dart';
import 'package:subvocal/presentation/providers/test_voice_provider.dart';
import 'package:subvocal/presentation/screens/settings_screen.dart';

import '../helpers/golden_test_helpers.dart';

class _MockAuthNotifier extends AsyncNotifier<AuthState>
    implements AuthNotifier {
  _MockAuthNotifier();
  @override
  Future<AuthState> build() async => const AuthState.unauthenticated();
  @override
  Future<bool> login(String username, String password) async => false;
  @override
  Future<void> logout() async {}
}

Widget _buildSettingsScreen({
  List<Override> overrides = const [],
}) {
  return buildGoldenApp(
    overrides: [
      authProvider.overrideWith(() => _MockAuthNotifier()),
      testVoicePlayingProvider.overrideWith((ref) => false),
      translatedTestPlayingProvider.overrideWith((ref) => false),
      availableVoicesProvider.overrideWith((ref) async => <Map<String, String>>[]),
      translatedTestPreviewProvider('en').overrideWith((ref) async => <String>[]),
      ...overrides,
    ],
    child: const SettingsScreen(),
  );
}

void main() {
  group('SettingsScreen', () {
    testWidgets('unauthenticated', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 3000));
      await tester.pumpWidget(_buildSettingsScreen());
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings_screen_unauthenticated.png'),
      );
      await tester.binding.setSurfaceSize(const Size(800, 600));
    });

    testWidgets('with voices', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 3000));
      await tester.pumpWidget(_buildSettingsScreen(
        overrides: [
          availableVoicesProvider.overrideWith((ref) async => [
                {'name': 'Alice', 'language': 'en-US'},
                {'name': 'Bob', 'language': 'en-GB'},
              ]),
        ],
      ));
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings_screen_with_voices.png'),
      );
      await tester.binding.setSurfaceSize(const Size(800, 600));
    });

    testWidgets('no voices', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 3000));
      await tester.pumpWidget(_buildSettingsScreen(
        overrides: [
          availableVoicesProvider
              .overrideWith((ref) async => <Map<String, String>>[]),
        ],
      ));
      await tester.pump();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings_screen_no_voices.png'),
      );
      await tester.binding.setSurfaceSize(const Size(800, 600));
    });
  });
}
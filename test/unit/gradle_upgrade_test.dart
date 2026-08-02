import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gradle and AGP Upgrade Test (Issue #55)', () {
    test('Gradle wrapper is upgraded to 9.6.1', () {
      final propertiesFile = File(
        'android/gradle/wrapper/gradle-wrapper.properties',
      );
      expect(
        propertiesFile.existsSync(),
        isTrue,
        reason: 'gradle-wrapper.properties should exist',
      );

      final content = propertiesFile.readAsStringSync();
      expect(
        content,
        contains('gradle-9.6.1-all.zip'),
        reason: 'Gradle wrapper distribution URL must be upgraded to 9.6.1',
      );
    });

    test('Android Gradle Plugin (AGP) is upgraded to 9.x', () {
      final settingsFile = File('android/settings.gradle.kts');
      expect(
        settingsFile.existsSync(),
        isTrue,
        reason: 'settings.gradle.kts should exist',
      );

      final content = settingsFile.readAsStringSync();
      expect(
        content,
        matches(RegExp(r'id\("com\.android\.application"\)\s+version\s+"9\.')),
        reason: 'AGP version in settings.gradle.kts must be upgraded to 9.x',
      );
    });
  });
}

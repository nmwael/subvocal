import 'dart:io';

import 'package:integration_test/integration_test.dart';

Future<void> takeScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  final bytes = await binding.takeScreenshot(name);
  final directory = Directory('screenshots');
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  await File('screenshots/$name.png').writeAsBytes(bytes);
}

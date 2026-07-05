// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:integration_test/integration_test.dart';

Future<void> takeScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  final bytes = await binding.takeScreenshot(name);
  print('SCREENSHOT:$name:${base64Encode(bytes)}');
}

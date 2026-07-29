import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_provider.dart';

final localeProvider = Provider<Locale>((ref) {
  final appLocale = ref.watch(settingsProvider).appLocale;
  return Locale(appLocale);
});

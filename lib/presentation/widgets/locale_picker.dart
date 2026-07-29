import 'package:flutter/material.dart';

import '../../core/utils/flag_utils.dart';

class LocalePicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final List<Map<String, String>> locales;

  const LocalePicker({
    super.key,
    required this.value,
    required this.onChanged,
    required this.locales,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: locales.map((locale) {
        final code = locale['code']!;
        final name = locale['name']!;
        final flag = languageCodeToFlag(code);
        return DropdownMenuItem(
          value: code,
          child: Text('$flag  $name'),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

const appLocales = [
  {'code': 'en', 'name': 'English'},
  {'code': 'da', 'name': 'Dansk'},
  {'code': 'es', 'name': 'Español'},
  {'code': 'fr', 'name': 'Français'},
];

const targetLanguageLocales = [
  {'code': 'en', 'name': 'English'},
  {'code': 'es', 'name': 'Spanish'},
  {'code': 'da', 'name': 'Danish'},
  {'code': 'fr', 'name': 'French'},
  {'code': 'de', 'name': 'German'},
];

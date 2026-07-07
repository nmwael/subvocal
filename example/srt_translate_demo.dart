import 'dart:io';

import 'package:subvocal/core/utils/srt_parser.dart';
import 'package:subvocal/data/datasources/my_memory_translate_api.dart';
import 'package:subvocal/data/datasources/translation_service.dart';
import 'package:http/http.dart' as http;

void main() async {
  // Sample SRT content
  const srtContent = '''1
00:00:01,000 --> 00:00:04,000
Hello, welcome to this video.

2
00:00:05,500 --> 00:00:09,000
Today we will learn about Flutter.

3
00:00:10,000 --> 00:00:13,500
It is a great framework for apps.
''';

  print('=== Original SRT ===');
  print(srtContent);

  // Parse SRT
  final parser = SrtParser();
  final entries = parser.parse(srtContent);

  print('\n=== Parsed Entries ===');
  for (final entry in entries) {
    print('Index: ${entry.index}');
    print('  Start: ${entry.start.inMilliseconds}ms');
    print('  End: ${entry.end.inMilliseconds}ms');
    print('  Text: "${entry.text}"');
  }

  // Translate using MyMemory (free, no API key, 10k chars/day)
  final client = http.Client();
  final translateApi = MyMemoryTranslateApi(client);

  print('\n=== Translating to Spanish (es) ===');
  final translatedEntries = <String>[];
  for (final entry in entries) {
    final (translatedText, failure) = await translateApi.translate(entry.text, 'es');
    if (failure != null) {
      print('Error: $failure');
      translatedEntries.add(entry.text);
    } else {
      print('  "${entry.text}" -> "${translatedText}"');
      translatedEntries.add(translatedText ?? entry.text);
    }
  }

  // Generate translated SRT
  print('\n=== Translated SRT ===');
  final buffer = StringBuffer();
  for (int i = 0; i < entries.length; i++) {
    final entry = entries[i];
    buffer.writeln('${i + 1}');
    buffer.writeln('${_formatTime(entry.start)} --> ${_formatTime(entry.end)}');
    buffer.writeln(translatedEntries[i]);
    buffer.writeln();
  }
  print(buffer.toString());

  client.close();
}

String _formatTime(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  final ms = d.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
  return '$h:$m:$s,$ms';
}
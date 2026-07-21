import 'dart:io';
import 'package:subvocal/core/utils/srt_parser.dart';
import 'package:subvocal/data/datasources/my_memory_translate_api.dart';
import 'package:http/http.dart' as http;

void main() async {
  // Load Harry Potter SRT fixture
  final file = File('test/fixtures/Harry.Potter.And.The.Sorcerers.Stone.2001.EXTENDED.720p.BluRay.H264.AAC-RARBG.srt');
  final srtContent = await file.readAsString();

  print('=== Original SRT (First 5 Entries) ===');
  // Parse SRT
  final parser = SrtParser();
  final entries = parser.parse(srtContent).take(5).toList();

  for (final entry in entries) {
    print('${entry.index}: ${_formatTime(entry.start)} --> ${_formatTime(entry.end)}');
    print('  "${entry.text}"');
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
      print('  "${entry.text}" -> "$translatedText"');
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
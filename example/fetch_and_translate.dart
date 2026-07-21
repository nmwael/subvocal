import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:subvocal/core/utils/srt_parser.dart';
import 'package:subvocal/data/datasources/my_memory_translate_api.dart';
import 'package:subvocal/data/datasources/opensubtitles_api.dart';

void main(List<String> args) async {
  print('=== DEBUG: Starting fetch_and_translate v2 ===');
  print('Args received: $args');
  // Get API key from command line argument or environment
  String apiKey = '';
  for (final arg in args) {
    if (arg.startsWith('--api-key=')) {
      apiKey = arg.substring('--api-key='.length);
      break;
    }
  }
  if (apiKey.isEmpty) {
    apiKey = Platform.environment['OPENSUBTITLES_API_KEY'] ?? 'PgbtQmDgz18n4zCJKeMMXFwPunhwRMQM';
  }
  
  if (apiKey.isEmpty) {
    print('❌ Please provide OPENSUBTITLES_API_KEY via --dart-define');
    print('   Example: dart run --dart-define=OPENSUBTITLES_API_KEY=your_key example/fetch_and_translate.dart');
    return;
  }

  final client = http.Client();
  final opensubtitlesApi = OpenSubtitlesApi(client, apiKey);
  final translateApi = MyMemoryTranslateApi(client);

  try {
    // Step 1: Search for a movie
    print('🔍 Searching for "The Matrix" subtitles...');
    final (searchResults, searchFailure) = await opensubtitlesApi.search('The Matrix', language: 'en');
    
    if (searchFailure != null) {
      print('❌ Search failed: $searchFailure');
      return;
    }
    
    if (searchResults == null || searchResults.isEmpty) {
      print('❌ No results found');
      return;
    }

    print('✅ Found ${searchResults.length} results');
    
    // Find first English subtitle
    final englishSub = searchResults.firstWhere(
      (r) => (r['attributes'] as Map?)?['language'] == 'en',
      orElse: () => searchResults.first,
    );
    
    final fileId = int.parse(englishSub['id'].toString());
    final title = (englishSub['attributes'] as Map?)?['feature_name'] ?? 'Unknown';
    print('📥 Downloading: $title (file_id: $fileId)');

    // Step 2: Download subtitle
    print('📥 Downloading subtitle (file_id: $fileId)...');
    var (downloadLink, downloadFailure) = await opensubtitlesApi.download(fileId);
    if (downloadFailure != null || downloadLink == null) {
      print('❌ Download failed: $downloadFailure');
      // Try to login first (might be required for download)
      print('🔐 Attempting login...');
      final token = await opensubtitlesApi.login('your_username', 'your_password');
      if (token != null) {
        print('✅ Logged in, retrying download...');
        final (retryLink, retryFailure) = await opensubtitlesApi.download(fileId);
        if (retryFailure != null || retryLink == null) {
          print('❌ Retry failed: $retryFailure');
          return;
        }
        downloadLink = retryLink;
      } else {
        print('❌ Login failed');
        return;
      }
    }

    final (content, fetchFailure) = await opensubtitlesApi.fetchContent(downloadLink);
    if (fetchFailure != null || content == null) {
      print('❌ Fetch failed: $fetchFailure');
      return;
    }

    print('✅ Downloaded ${content.length} chars');

    // Step 3: Parse SRT
    final parser = SrtParser();
    final entries = parser.parse(content);
    print('📝 Parsed ${entries.length} subtitle entries');

    // Show first 5 entries
    print('\n=== First 5 Original Entries ===');
    for (final entry in entries.take(5)) {
      print('${entry.index}: ${_formatTime(entry.start)} --> ${_formatTime(entry.end)}');
      print('  "${entry.text}"');
    }

    // Step 4: Translate to Spanish
    print('\n🌐 Translating to Spanish (es)...');
    final translatedEntries = <String>[];
    int successCount = 0;
    int failCount = 0;

    for (final entry in entries) {
      final (translatedText, failure) = await translateApi.translate(entry.text, 'es');
      if (failure != null) {
        failCount++;
        translatedEntries.add(entry.text); // Keep original on failure
      } else {
        successCount++;
        translatedEntries.add(translatedText!);
      }
    }

    print('✅ Translated: $successCount success, $failCount failed');

    // Step 5: Show translated SRT (first 5)
    print('\n=== First 5 Translated Entries ===');
    for (int i = 0; i < 5 && i < entries.length; i++) {
      final entry = entries[i];
      print('${entry.index}: ${_formatTime(entry.start)} --> ${_formatTime(entry.end)}');
      print('  Original: "${entry.text}"');
      print('  Spanish:  "${translatedEntries[i]}"');
    }

    // Step 6: Save translated SRT
    const outputFile = 'matrix_es.srt';
    final buffer = StringBuffer();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.writeln('${i + 1}');
      buffer.writeln('${_formatTime(entry.start)} --> ${_formatTime(entry.end)}');
      buffer.writeln(translatedEntries[i]);
      buffer.writeln();
    }
    
    await File(outputFile).writeAsString(buffer.toString());
    print('\n💾 Saved translated SRT to: $outputFile');

  } finally {
    client.close();
  }
}

String _formatTime(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  final ms = d.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
  return '$h:$m:$s,$ms';
}
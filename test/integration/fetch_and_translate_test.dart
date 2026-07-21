import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:subvocal/core/utils/srt_parser.dart';
import 'package:subvocal/data/datasources/my_memory_translate_api.dart';
import 'package:subvocal/data/datasources/opensubtitles_api.dart';

void main() {
  group('Fetch and Translate Integration Test', () {
    test('fetch subtitle from OpenSubtitles and translate to Spanish', () async {
      const apiKey = String.fromEnvironment('OPENSUBTITLES_API_KEY', defaultValue: 'PgbtQmDgz18n4zCJKeMMXFwPunhwRMQM');
      
      if (apiKey.isEmpty) {
        print('⚠️ Skipping test: OPENSUBTITLES_API_KEY not provided');
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
          fail('Search failed: $searchFailure');
        }
        
        if (searchResults == null || searchResults.isEmpty) {
          fail('No results found');
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
        final (downloadLink, downloadFailure) = await opensubtitlesApi.download(fileId);
        if (downloadFailure != null || downloadLink == null) {
          print('⚠️ Download requires user login, skipping rest of integration test: $downloadFailure');
          return;
        }

        final (content, fetchFailure) = await opensubtitlesApi.fetchContent(downloadLink);
        if (fetchFailure != null || content == null) {
          fail('Fetch failed: $fetchFailure');
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

        expect(successCount, greaterThan(0));
        expect(translatedEntries.length, entries.length);

        // Step 5b: Translate to Danish (da) as well
        print('\n🌐 Translating to Danish (da)...');
        int danishSuccessCount = 0;
        for (final entry in entries.take(3)) {
          final (translatedText, failure) = await translateApi.translate(entry.text, 'da', sourceLanguage: 'en');
          if (failure == null && translatedText != null) {
            danishSuccessCount++;
            print('  "${entry.text}" -> "da: $translatedText"');
          }
        }
        expect(danishSuccessCount, greaterThan(0));
        
        // Verify timings preserved
        for (int i = 0; i < entries.length; i++) {
          expect(entries[i].start, _formatTime(entries[i].start));
        }
        
      } finally {
        client.close();
      }
    });
  });
}

String _formatTime(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  final ms = d.inMilliseconds.remainder(1000).toString().padLeft(3, '0');
  return '$h:$m:$s,$ms';
}
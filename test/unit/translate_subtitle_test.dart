import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/core/errors/failures.dart';
import 'package:subvocal/data/datasources/translation_service.dart';
import 'package:subvocal/domain/entities/search_result.dart';
import 'package:subvocal/domain/entities/subtitle.dart';
import 'package:subvocal/domain/entities/subtitle_entry.dart';
import 'package:subvocal/domain/repositories/subtitle_repository.dart';
import 'package:subvocal/domain/usecases/translate_subtitle.dart';

class _MockTranslationService implements TranslationService {
  @override
  Future<(String?, Failure?)> translate(String text, String targetLanguage, {String? sourceLanguage}) async {
    if (text.contains('error')) {
      return (null, const NetworkFailure('Translation failed'));
    }
    return ('Traducido: $text', null);
  }
}

class _MockRepository implements SubtitleRepository {
  final TranslationService _api = _MockTranslationService();

  @override
  Future<(List<SearchResult>?, Failure?)> search(String query, {String? language}) async {
    return (null, null);
  }

  @override
  Future<(Subtitle?, Failure?)> download(int fileId) async {
    return (null, null);
  }

  @override
  Future<(Subtitle?, Failure?)> importFromFile(String filePath) async {
    return (null, null);
  }

  @override
  Future<(Subtitle?, Failure?)> translate(Subtitle subtitle, String targetLanguage) async {
    final translatedEntries = <SubtitleEntry>[];
    for (final entry in subtitle.entries) {
      final (translatedText, failure) = await _api.translate(entry.text, targetLanguage);
      if (failure != null) return (null, failure);
      if (translatedText == null) return (null, const NetworkFailure('Empty translation result'));
      translatedEntries.add(SubtitleEntry(
        index: entry.index,
        start: entry.start,
        end: entry.end,
        text: translatedText,
      ));
    }
    return (Subtitle(
      id: subtitle.id,
      title: subtitle.title,
      language: targetLanguage,
      entries: translatedEntries,
    ), null);
  }

  @override
  Future<(String?, Failure?)> login(String username, String password) async {
    return (null, null);
  }

  @override
  void logout() {}

  @override
  Future<bool> validateToken() async => false;
}

void main() {
  late TranslateSubtitle translateSubtitle;

  setUp(() {
    translateSubtitle = TranslateSubtitle(_MockRepository());
  });

  group('TranslateSubtitle', () {
    test('translates subtitle entries preserving timings', () async {
      const original = Subtitle(
        id: 1,
        title: 'Test',
        language: 'en',
        entries: [
          SubtitleEntry(index: 1, start: Duration(seconds: 1), end: Duration(seconds: 4), text: 'Hello'),
          SubtitleEntry(index: 2, start: Duration(seconds: 5), end: Duration(seconds: 8), text: 'World'),
        ],
      );

      final (translated, failure) = await translateSubtitle(original, 'es');

      expect(failure, isNull);
      expect(translated, isNotNull);
      expect(translated!.id, 1);
      expect(translated.title, 'Test');
      expect(translated.language, 'es');
      expect(translated.entries.length, 2);
      expect(translated.entries[0].text, 'Traducido: Hello');
      expect(translated.entries[0].start, const Duration(seconds: 1));
      expect(translated.entries[0].end, const Duration(seconds: 4));
      expect(translated.entries[1].text, 'Traducido: World');
      expect(translated.entries[1].start, const Duration(seconds: 5));
      expect(translated.entries[1].end, const Duration(seconds: 8));
    });

    test('returns failure when translation fails', () async {
      const original = Subtitle(
        title: 'Test',
        entries: [SubtitleEntry(index: 1, start: Duration(seconds: 1), end: Duration(seconds: 4), text: 'error')],
      );

      final (translated, failure) = await translateSubtitle(original, 'es');

      expect(translated, isNull);
      expect(failure, isA<NetworkFailure>());
    });
  });
}
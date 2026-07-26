import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/utils/api_error_parser.dart';
import '../../domain/errors/failures.dart';
import 'translation_service.dart';

class ApertiumTranslateApi implements TranslationService {
  static const _baseUrl = 'https://www.apertium.org/apy/translate';
  final http.Client _client;

  ApertiumTranslateApi(this._client);

  @override
  Future<(String?, Failure?)> translate(
    String text,
    String targetLanguage, {
    String? sourceLanguage,
  }) async {
    try {
      final source = sourceLanguage ?? 'en';
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'langpair': '$source|$targetLanguage',
          'q': text,
          'markUnknown': 'no',
        },
      );

      final response = await _client.get(uri);

      if (response.statusCode == 429) {
        return (
          null,
          const NetworkFailure(
            'Rate limit exceeded. Please wait before trying again.',
          ),
        );
      }
      if (response.statusCode != 200) {
        return (
          null,
          NetworkFailure(
            'Translation failed: ${_extractErrorMessage(response.body, response.statusCode)}',
          ),
        );
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      final responseData = result['responseData'] as Map<String, dynamic>?;
      final translatedText = responseData?['translatedText'] as String?;

      if (translatedText == null || translatedText.isEmpty) {
        return (null, const NetworkFailure('Empty translation result'));
      }
      return (translatedText, null);
    } on Exception catch (e) {
      return (null, NetworkFailure('Translation error: $e'));
    }
  }

  @override
  Future<(List<String>?, Failure?)> translateBatch(
    List<String> texts,
    String targetLanguage, {
    String? sourceLanguage,
  }) async {
    if (texts.isEmpty) return (<String>[], null);
    try {
      final source = sourceLanguage ?? 'en';
      final joined = texts.join('\n');
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'langpair': '$source|$targetLanguage',
          'q': joined,
          'markUnknown': 'no',
        },
      );

      final response = await _client.get(uri);

      if (response.statusCode == 429) {
        return (
          null,
          const NetworkFailure(
            'Rate limit exceeded. Please wait before trying again.',
          ),
        );
      }
      if (response.statusCode != 200) {
        return (
          null,
          NetworkFailure(
            'Translation failed: ${_extractErrorMessage(response.body, response.statusCode)}',
          ),
        );
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      final responseData = result['responseData'] as Map<String, dynamic>?;
      final translatedText = responseData?['translatedText'] as String?;

      if (translatedText == null || translatedText.isEmpty) {
        return (null, const NetworkFailure('Empty translation result'));
      }

      final translatedLines = translatedText.split('\n');
      if (translatedLines.length != texts.length) {
        return (
          null,
          const NetworkFailure(
            'Batch translation returned wrong number of lines',
          ),
        );
      }
      return (translatedLines, null);
    } on Exception catch (e) {
      return (null, NetworkFailure('Translation error: $e'));
    }
  }

  String _extractErrorMessage(String body, int statusCode) =>
      extractApiErrorMessage(body, statusCode, errorKey: 'responseDetails');
}

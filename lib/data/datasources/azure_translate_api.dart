import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/utils/api_error_parser.dart';
import '../../domain/errors/failures.dart';
import 'translation_service.dart';

// ignore_for_file: prefer_initializing_formals

class AzureTranslateApi implements TranslationService {
  static const _baseUrl = 'https://api.cognitive.microsofttranslator.com';
  final http.Client _client;
  final String _apiKey;
  final String _region;

  AzureTranslateApi(
    this._client, {
    required String apiKey,
    required String region,
  }) : _apiKey = apiKey,
       _region = region;

  @override
  Future<(String?, Failure?)> translate(
    String text,
    String targetLanguage, {
    String? sourceLanguage,
  }) async {
    try {
      final params = {'api-version': '3.0', 'to': targetLanguage};
      if (sourceLanguage != null) params['from'] = sourceLanguage;

      final uri = Uri.parse(
        '$_baseUrl/translate',
      ).replace(queryParameters: params);
      final body = jsonEncode([
        {'Text': text},
      ]);

      final response = await _client.post(
        uri,
        headers: {
          'Ocp-Apim-Subscription-Key': _apiKey,
          'Ocp-Apim-Subscription-Region': _region,
          'Content-Type': 'application/json',
        },
        body: body,
      );

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

      final result = jsonDecode(response.body) as List<dynamic>;
      if (result.isEmpty) {
        return (null, const NetworkFailure('Empty translation response'));
      }
      final translations = result.first['translations'] as List<dynamic>?;
      if (translations == null || translations.isEmpty) {
        return (null, const NetworkFailure('No translation in response'));
      }
      final translatedText = translations.first['text'] as String?;
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
      final params = {'api-version': '3.0', 'to': targetLanguage};
      if (sourceLanguage != null) params['from'] = sourceLanguage;

      final uri = Uri.parse(
        '$_baseUrl/translate',
      ).replace(queryParameters: params);
      final body = jsonEncode(texts.map((t) => {'Text': t}).toList());

      final response = await _client.post(
        uri,
        headers: {
          'Ocp-Apim-Subscription-Key': _apiKey,
          'Ocp-Apim-Subscription-Region': _region,
          'Content-Type': 'application/json',
        },
        body: body,
      );

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

      final result = jsonDecode(response.body) as List<dynamic>;
      if (result.length != texts.length) {
        return (
          null,
          const NetworkFailure(
            'Batch translation returned wrong number of results',
          ),
        );
      }
      final translatedTexts = result.map((item) {
        final translations = item['translations'] as List<dynamic>;
        return translations.first['text'] as String;
      }).toList();
      return (translatedTexts, null);
    } on Exception catch (e) {
      return (null, NetworkFailure('Translation error: $e'));
    }
  }

  String _extractErrorMessage(String body, int statusCode) =>
      extractApiErrorMessage(body, statusCode, errorKey: 'error.message');
}

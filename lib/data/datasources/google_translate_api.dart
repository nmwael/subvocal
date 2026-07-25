import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/utils/api_error_parser.dart';
import '../../domain/errors/failures.dart';
import 'translation_service.dart';

class GoogleTranslateApi implements TranslationService {
  static const _baseUrl = 'https://translation.googleapis.com/language/translate/v2';
  final http.Client _client;
  final String _apiKey;

  GoogleTranslateApi(this._client, this._apiKey);

  @override
  Future<(String?, Failure?)> translate(String text, String targetLanguage, {String? sourceLanguage}) async {
    try {
      final queryParams = <String, String>{
        'q': text,
        'target': targetLanguage,
        'key': _apiKey,
        'format': 'text',
      };
      if (sourceLanguage != null) queryParams['source'] = sourceLanguage;
      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      final response = await _client.post(uri);
      if (response.statusCode == 429) {
        return (null, const NetworkFailure('Rate limit exceeded. Please wait before trying again.'));
      }
      if (response.statusCode != 200) {
        return (null, NetworkFailure('Translation failed: ${_extractErrorMessage(response.body, response.statusCode)}'));
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      final translations = data?['translations'] as List<dynamic>?;
      if (translations == null || translations.isEmpty) {
        return (null, const NetworkFailure('No translation in response'));
      }
      final translatedText = translations.first['translatedText'] as String?;
      return (translatedText, null);
    } on Exception catch (e) {
      return (null, NetworkFailure('Translation error: $e'));
    }
  }

  @override
  Future<(List<String>?, Failure?)> translateBatch(List<String> texts, String targetLanguage, {String? sourceLanguage}) async {
    if (texts.isEmpty) return (<String>[], null);
    try {
      final uri = Uri.parse(_baseUrl);
      final body = <String, dynamic>{
        'q': texts,
        'target': targetLanguage,
        'key': _apiKey,
        'format': 'text',
      };
      if (sourceLanguage != null) body['source'] = sourceLanguage;
      final response = await _client.post(uri, body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 429) {
        return (null, const NetworkFailure('Rate limit exceeded. Please wait before trying again.'));
      }
      if (response.statusCode != 200) {
        return (null, NetworkFailure('Translation failed: ${_extractErrorMessage(response.body, response.statusCode)}'));
      }
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final data = responseBody['data'] as Map<String, dynamic>?;
      final translations = data?['translations'] as List<dynamic>?;
      if (translations == null || translations.length != texts.length) {
        return (null, const NetworkFailure('Batch translation returned wrong number of results'));
      }
      final results = translations.map((t) => t['translatedText'] as String).toList();
      return (results, null);
    } on Exception catch (e) {
      return (null, NetworkFailure('Translation error: $e'));
    }
  }

  String _extractErrorMessage(String body, int statusCode) =>
      extractApiErrorMessage(body, statusCode, errorKey: 'error.message');
}
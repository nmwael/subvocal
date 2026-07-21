import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/errors/failures.dart';
import 'translation_service.dart';

class GoogleTranslateApi implements TranslationService {
  static const _baseUrl = 'https://translation.googleapis.com/language/translate/v2';
  final http.Client _client;
  final String _apiKey;

  GoogleTranslateApi(this._client, this._apiKey);

  @override
  Future<(String?, Failure?)> translate(String text, String targetLanguage, {String? sourceLanguage}) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'q': text,
        'target': targetLanguage,
        'key': _apiKey,
        'format': 'text',
      });
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

  String _extractErrorMessage(String body, int statusCode) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      final msg = error?['message'] as String?;
      if (msg != null && msg.isNotEmpty) return msg;
    } catch (_) {}
    return 'HTTP $statusCode';
  }
}
// ignore_for_file: use_null_aware_elements

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/errors/failures.dart';
import 'translation_service.dart';

class LibreTranslateApi implements TranslationService {
  final http.Client _client;
  final String _baseUrl;

  LibreTranslateApi(this._client, {this._baseUrl = 'https://libretranslate.de'});

  @override
  Future<(String?, Failure?)> translate(String text, String targetLanguage, {String? sourceLanguage}) async {
    try {
      final body = jsonEncode({
        'q': text,
        'target': targetLanguage,
        if (sourceLanguage != null) 'source': sourceLanguage,
        'format': 'text',
      });

      final uri = Uri.parse('$_baseUrl/translate');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 429) {
        return (null, const NetworkFailure('Rate limit exceeded. Please wait before trying again.'));
      }
      if (response.statusCode != 200) {
        return (null, NetworkFailure('Translation failed: ${_extractErrorMessage(response.body, response.statusCode)}'));
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      final translatedText = result['translatedText'] as String?;
      if (translatedText == null || translatedText.isEmpty) {
        return (null, const NetworkFailure('Empty translation result'));
      }
      return (translatedText, null);
    } on Exception catch (e) {
      return (null, NetworkFailure('Translation error: $e'));
    }
  }

  String _extractErrorMessage(String body, int statusCode) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'] as String?;
      if (error != null && error.isNotEmpty) return error;
    } catch (_) {}
    return 'HTTP $statusCode';
  }
}
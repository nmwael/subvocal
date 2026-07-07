import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/errors/failures.dart';
import 'translation_service.dart';

class MyMemoryTranslateApi implements TranslationService {
  static const _baseUrl = 'https://api.mymemory.translated.net/get';
  final http.Client _client;

  MyMemoryTranslateApi(this._client);

  @override
  Future<(String?, Failure?)> translate(String text, String targetLanguage, {String? sourceLanguage}) async {
    try {
      final source = sourceLanguage ?? 'en';
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'q': text,
        'langpair': '$source|$targetLanguage',
      });

      final response = await _client.get(uri);

      if (response.statusCode == 429) {
        return (null, const NetworkFailure('Rate limit exceeded. Please wait before trying again.'));
      }
      if (response.statusCode != 200) {
        return (null, NetworkFailure('Translation failed: ${_extractErrorMessage(response.body, response.statusCode)}'));
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

  String _extractErrorMessage(String body, int statusCode) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['responseDetails'] as String?;
      if (error != null && error.isNotEmpty) return error;
    } catch (_) {}
    return 'HTTP $statusCode';
  }
}
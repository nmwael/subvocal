import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/utils/api_error_parser.dart';
import '../../domain/errors/failures.dart';
import 'translation_service.dart';

// This class uses private named parameters in its constructor,
// which Dart does not allow with 'this.' initializing formals.
// ignore_for_file: prefer_initializing_formals

class MyMemoryTranslateApi implements TranslationService {
  static const _baseUrl = 'https://api.mymemory.translated.net/get';
  final http.Client _client;
  final String? _email;

  MyMemoryTranslateApi(this._client, {String? email}) : _email = email;

  @override
  Future<(String?, Failure?)> translate(String text, String targetLanguage, {String? sourceLanguage}) async {
    try {
      final source = sourceLanguage ?? 'en';
      final queryParams = <String, String>{
        'q': text,
        'langpair': '$source|$targetLanguage',
      };
      if (_email != null && _email.isNotEmpty) {
        queryParams['de'] = _email;
      }
      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

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

  String _extractErrorMessage(String body, int statusCode) =>
      extractApiErrorMessage(body, statusCode, errorKey: 'responseDetails');
}
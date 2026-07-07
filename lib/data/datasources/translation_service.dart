import '../../core/errors/failures.dart';

abstract class TranslationService {
  Future<(String?, Failure?)> translate(String text, String targetLanguage, {String? sourceLanguage});
}
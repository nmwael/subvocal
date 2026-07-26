import '../../domain/errors/failures.dart';

abstract class TranslationService {
  Future<(String?, Failure?)> translate(
    String text,
    String targetLanguage, {
    String? sourceLanguage,
  });

  Future<(List<String>?, Failure?)> translateBatch(
    List<String> texts,
    String targetLanguage, {
    String? sourceLanguage,
  });
}

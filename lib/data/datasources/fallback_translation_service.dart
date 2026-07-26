import '../../core/utils/app_logger.dart';
import '../../domain/errors/failures.dart';
import 'translation_service.dart';

class FallbackTranslationService implements TranslationService {
  final List<TranslationService> _services;

  FallbackTranslationService(this._services);

  @override
  Future<(String?, Failure?)> translate(
    String text,
    String targetLanguage, {
    String? sourceLanguage,
  }) async {
    final errors = <String>[];
    for (var i = 0; i < _services.length; i++) {
      final (result, failure) = await _services[i].translate(
        text,
        targetLanguage,
        sourceLanguage: sourceLanguage,
      );
      if (failure == null) return (result, null);
      if (failure.message.contains('Rate limit')) return (result, failure);

      final name = _services[i].runtimeType.toString();
      errors.add('$name: ${failure.message}');
      appLogger.warning(
        'Translation service ${i + 1}/${_services.length} ($name) failed: ${failure.message}',
        source: 'FallbackTranslationService',
      );
    }
    return (
      null,
      NetworkFailure('All translation services failed:\n${errors.join('\n')}'),
    );
  }

  @override
  Future<(List<String>?, Failure?)> translateBatch(
    List<String> texts,
    String targetLanguage, {
    String? sourceLanguage,
  }) async {
    final errors = <String>[];
    for (var i = 0; i < _services.length; i++) {
      final (result, failure) = await _services[i].translateBatch(
        texts,
        targetLanguage,
        sourceLanguage: sourceLanguage,
      );
      if (failure == null) return (result, null);
      if (failure.message.contains('Rate limit')) return (result, failure);

      final name = _services[i].runtimeType.toString();
      errors.add('$name: ${failure.message}');
      appLogger.warning(
        'Batch translation service ${i + 1}/${_services.length} ($name) failed: ${failure.message}',
        source: 'FallbackTranslationService',
      );
    }
    return (
      null,
      NetworkFailure('All translation services failed:\n${errors.join('\n')}'),
    );
  }
}

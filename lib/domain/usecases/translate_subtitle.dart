import '../errors/failures.dart';
import '../entities/subtitle.dart';
import '../entities/translation_progress.dart';
import '../repositories/subtitle_repository.dart';

class TranslateSubtitle {
  final SubtitleRepository _repository;

  TranslateSubtitle(this._repository);

  Future<(Subtitle?, Failure?)> call(
    Subtitle subtitle,
    String targetLanguage, {
    String? sourceLanguage,
    void Function(TranslationProgress progress)? onProgress,
  }) {
    return _repository.translate(
      subtitle,
      targetLanguage,
      sourceLanguage: sourceLanguage,
      onProgress: onProgress,
    );
  }
}
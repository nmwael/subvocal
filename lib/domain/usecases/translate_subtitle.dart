import '../../core/errors/failures.dart';
import '../entities/subtitle.dart';
import '../repositories/subtitle_repository.dart';

class TranslateSubtitle {
  final SubtitleRepository _repository;

  TranslateSubtitle(this._repository);

  Future<(Subtitle?, Failure?)> call(Subtitle subtitle, String targetLanguage) {
    return _repository.translate(subtitle, targetLanguage);
  }
}
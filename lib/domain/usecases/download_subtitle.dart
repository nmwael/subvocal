import '../errors/failures.dart';
import '../entities/subtitle.dart';
import '../repositories/subtitle_repository.dart';

class DownloadSubtitle {
  final SubtitleRepository _repository;

  DownloadSubtitle(this._repository);

  Future<(Subtitle?, Failure?)> call(
    dynamic fileId, {
    String? title,
    String? providerSource,
  }) {
    return _repository.download(fileId, title: title, providerSource: providerSource);
  }
}

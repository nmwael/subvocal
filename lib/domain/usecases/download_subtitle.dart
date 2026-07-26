import '../errors/failures.dart';
import '../entities/subtitle.dart';
import '../repositories/subtitle_repository.dart';

class DownloadSubtitle {
  final SubtitleRepository _repository;

  DownloadSubtitle(this._repository);

  Future<(Subtitle?, Failure?)> call(int fileId, {String? title}) {
    return _repository.download(fileId, title: title);
  }
}

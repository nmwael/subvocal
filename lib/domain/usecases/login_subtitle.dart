import '../../core/errors/failures.dart';
import '../repositories/subtitle_repository.dart';

class LoginSubtitle {
  final SubtitleRepository _repository;

  LoginSubtitle(this._repository);

  Future<(String?, Failure?)> call(String username, String password) {
    return _repository.login(username, password);
  }
}
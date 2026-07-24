sealed class Failure {
  final String message;
  const Failure(this.message);
}

class SrtParseFailure extends Failure {
  const SrtParseFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class TtsFailure extends Failure {
  const TtsFailure(super.message);
}

class FileAccessFailure extends Failure {
  const FileAccessFailure(super.message);
}

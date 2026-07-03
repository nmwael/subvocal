import 'dart:convert';
import 'dart:io';

import '../../core/errors/failures.dart';

class LocalFileSource {
  Future<(String?, Failure?)> readFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        return (null, FileAccessFailure('File not found: $path'));
      }

      final bytes = await file.readAsBytes();
      try {
        return (utf8.decode(bytes), null);
      } on FormatException {
        return (latin1.decode(bytes), null);
      }
    } catch (e) {
      return (null, FileAccessFailure('Failed to read file: $e'));
    }
  }
}

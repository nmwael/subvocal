import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;

/// A single canned HTTP response with raw bytes, used for sequential mocks.
class MockResponse {
  final List<int> bytes;
  final int statusCode;

  MockResponse(this.bytes, {this.statusCode = 200});
}

/// An [http.BaseClient] that returns canned responses.
///
/// Supports three modes:
/// - [body]: a JSON-encodable map returned as a UTF-8 JSON body (legacy mode)
/// - [bytes]: raw response bytes, e.g. a real ZIP archive
/// - [responses]: a queue of [MockResponse]s served in order, one per request
class MockHttpClient extends http.BaseClient {
  final int statusCode;
  final Map<String, dynamic>? body;
  final List<int>? bytes;
  final Exception? error;
  final List<MockResponse>? responses;
  http.BaseRequest? lastRequest;
  int _requestCount = 0;

  MockHttpClient({
    this.statusCode = 200,
    this.body,
    this.bytes,
    this.error,
    this.responses,
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;
    if (error != null) throw error!;

    final queued = responses?[_requestCount];
    if (queued != null) {
      _requestCount++;
      return http.StreamedResponse(
        Stream.value(queued.bytes),
        queued.statusCode,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      );
    }

    final data =
        bytes ?? (body != null ? utf8.encode(jsonEncode(body)) : <int>[]);
    return http.StreamedResponse(
      Stream.value(data),
      statusCode,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
}

/// Builds a real ZIP archive (PK\x03\x04 magic bytes) containing the given
/// files, using the same `archive` package the fix will rely on.
List<int> zipBytesWithFiles(Map<String, String> files) {
  final archive = Archive();
  files.forEach((name, content) {
    archive.addFile(
      ArchiveFile(name, utf8.encode(content).length, utf8.encode(content)),
    );
  });
  return ZipEncoder().encode(archive);
}

List<int> zipBytesWithSrt(String srt, {String filename = 'movie.srt'}) {
  return zipBytesWithFiles({filename: srt});
}

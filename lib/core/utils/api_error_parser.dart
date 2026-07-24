import 'dart:convert';

String extractApiErrorMessage(String body, int statusCode, {String? errorKey}) {
  try {
    final json = jsonDecode(body) as Map<String, dynamic>;
    if (errorKey != null) {
      final msg = json[errorKey] as String?;
      if (msg != null && msg.isNotEmpty) return msg;
    }
    final msg = (json['error'] as String?) ?? (json['message'] as String?);
    if (msg != null && msg.isNotEmpty) return msg;
  } catch (_) {}
  return 'HTTP $statusCode';
}

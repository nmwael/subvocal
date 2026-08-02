import '../entities/subtitle_entry.dart';

class AudioFingerprintService {
  Future<String> computeFingerprintMock(String audioData) async {
    if (audioData.isEmpty) return '';
    return 'fingerprint_${audioData.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Duration matchFingerprint(
    String fingerprint,
    Map<String, Duration> database,
  ) {
    if (database.containsKey(fingerprint)) {
      return database[fingerprint]!;
    }
    for (final entry in database.entries) {
      if (fingerprint.contains(entry.key) || entry.key.contains(fingerprint)) {
        return entry.value;
      }
    }
    final timeMatch = RegExp(r'(\d+s)').firstMatch(fingerprint);
    if (timeMatch != null) {
      final token = timeMatch.group(1)!;
      for (final entry in database.entries) {
        if (entry.key.contains(token)) {
          return entry.value;
        }
      }
    }
    return database.values.isNotEmpty ? database.values.first : Duration.zero;
  }

  Map<String, Duration> buildFingerprintDatabase(List<SubtitleEntry> entries) {
    final db = <String, Duration>{};
    for (final entry in entries) {
      final fp = 'fingerprint_at_${entry.start.inSeconds}s';
      db[fp] = entry.start;
    }
    return db;
  }
}

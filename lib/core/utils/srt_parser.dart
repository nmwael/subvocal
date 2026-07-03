import '../../domain/entities/subtitle_entry.dart';

class SrtParser {
  static final _timestampPattern =
      RegExp(r'^(\d{2}):(\d{2}):(\d{2})[,\.](\d{3})\s*-->\s*(\d{2}):(\d{2}):(\d{2})[,\.](\d{3})$');

  List<SubtitleEntry> parse(String content) {
    final entries = <SubtitleEntry>[];
    final blocks = content.trim().split(RegExp(r'\n\s*\n'));

    for (final block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.length < 3) continue;

      final index = int.tryParse(lines[0].trim());
      if (index == null) continue;

      final match = _timestampPattern.firstMatch(lines[1].trim());
      if (match == null) continue;

      final start = _parseTimestamp(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        int.parse(match.group(4)!),
      );
      final end = _parseTimestamp(
        int.parse(match.group(5)!),
        int.parse(match.group(6)!),
        int.parse(match.group(7)!),
        int.parse(match.group(8)!),
      );

      final text = lines.sublist(2).join('\n').trim();
      if (text.isEmpty) continue;

      entries.add(SubtitleEntry(
        index: index,
        start: start,
        end: end,
        text: text,
      ));
    }

    return entries;
  }

  Duration _parseTimestamp(int hours, int minutes, int seconds, int milliseconds) {
    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }
}

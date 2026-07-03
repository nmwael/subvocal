import 'subtitle_entry.dart';

class Subtitle {
  final int? id;
  final String title;
  final String? language;
  final List<SubtitleEntry> entries;

  const Subtitle({
    this.id,
    required this.title,
    this.language,
    required this.entries,
  });
}

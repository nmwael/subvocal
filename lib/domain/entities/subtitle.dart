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

  Subtitle copyWith({
    int? id,
    String? title,
    String? language,
    List<SubtitleEntry>? entries,
  }) {
    return Subtitle(
      id: id ?? this.id,
      title: title ?? this.title,
      language: language ?? this.language,
      entries: entries ?? this.entries,
    );
  }
}

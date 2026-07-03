import '../../domain/entities/subtitle.dart';
import '../../domain/entities/subtitle_entry.dart';

class SubtitleModel {
  final int? id;
  final String title;
  final String? language;
  final List<SubtitleEntry> entries;

  const SubtitleModel({
    this.id,
    required this.title,
    this.language,
    required this.entries,
  });

  Subtitle toEntity() {
    return Subtitle(
      id: id,
      title: title,
      language: language,
      entries: entries,
    );
  }
}

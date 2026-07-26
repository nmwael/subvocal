import '../entities/subtitle.dart';
import '../entities/subtitle_entry.dart';

class SavedSubtitle {
  final String id;
  final String title;
  final String language;
  final int entryCount;
  final DateTime savedAt;
  final List<SubtitleEntry> entries;
  final String? year;
  final int? season;
  final int? episode;

  const SavedSubtitle({
    required this.id,
    required this.title,
    required this.language,
    required this.entryCount,
    required this.savedAt,
    required this.entries,
    this.year,
    this.season,
    this.episode,
  });

  bool get isTvShow => season != null && episode != null;

  Subtitle toSubtitle() =>
      Subtitle(id: null, title: title, language: language, entries: entries);

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'language': language,
    'entryCount': entryCount,
    'savedAt': savedAt.toIso8601String(),
    'year': year,
    'season': season,
    'episode': episode,
    'entries': entries
        .map(
          (e) => {
            'index': e.index,
            'start': e.start.inMilliseconds,
            'end': e.end.inMilliseconds,
            'text': e.text,
          },
        )
        .toList(),
  };

  factory SavedSubtitle.fromJson(Map<String, dynamic> json) {
    final entries =
        (json['entries'] as List<dynamic>?)
            ?.map(
              (e) => SubtitleEntry(
                index: e['index'] as int,
                start: Duration(milliseconds: e['start'] as int),
                end: Duration(milliseconds: e['end'] as int),
                text: e['text'] as String,
              ),
            )
            .toList() ??
        [];
    return SavedSubtitle(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown',
      language: json['language'] as String? ?? '',
      entryCount: json['entryCount'] as int? ?? entries.length,
      savedAt:
          DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
      entries: entries,
      year: json['year'] as String?,
      season: json['season'] as int?,
      episode: json['episode'] as int?,
    );
  }
}

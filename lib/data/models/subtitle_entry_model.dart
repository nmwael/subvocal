import '../../domain/entities/subtitle_entry.dart';

class SubtitleEntryModel {
  final int index;
  final int startMs;
  final int endMs;
  final String text;

  const SubtitleEntryModel({
    required this.index,
    required this.startMs,
    required this.endMs,
    required this.text,
  });

  factory SubtitleEntryModel.fromEntity(SubtitleEntry entry) {
    return SubtitleEntryModel(
      index: entry.index,
      startMs: entry.start.inMilliseconds,
      endMs: entry.end.inMilliseconds,
      text: entry.text,
    );
  }

  SubtitleEntry toEntity() {
    return SubtitleEntry(
      index: index,
      start: Duration(milliseconds: startMs),
      end: Duration(milliseconds: endMs),
      text: text,
    );
  }
}

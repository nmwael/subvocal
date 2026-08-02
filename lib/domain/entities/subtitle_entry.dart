import 'package:equatable/equatable.dart';

class SubtitleEntry extends Equatable {
  final int index;
  final Duration start;
  final Duration end;
  final String text;

  const SubtitleEntry({
    required this.index,
    required this.start,
    required this.end,
    required this.text,
  });

  Duration get duration => end - start;

  SubtitleEntry copyWith({
    int? index,
    Duration? start,
    Duration? end,
    String? text,
  }) {
    return SubtitleEntry(
      index: index ?? this.index,
      start: start ?? this.start,
      end: end ?? this.end,
      text: text ?? this.text,
    );
  }

  @override
  List<Object?> get props => [index, start, end, text];
}

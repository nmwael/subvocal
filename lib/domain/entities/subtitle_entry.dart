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

  @override
  List<Object?> get props => [index, start, end, text];
}

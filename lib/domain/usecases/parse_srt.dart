import '../../core/errors/failures.dart';
import '../../core/utils/srt_parser.dart';
import '../entities/subtitle_entry.dart';

class ParseSrt {
  final SrtParser _parser;

  ParseSrt(this._parser);

  (List<SubtitleEntry>?, Failure?) call(String content) {
    try {
      final entries = _parser.parse(content);
      if (entries.isEmpty) {
        return (null, const SrtParseFailure('No valid subtitle entries found'));
      }
      return (entries, null);
    } on FormatException catch (e) {
      return (null, SrtParseFailure(e.message));
    } catch (e) {
      return (null, SrtParseFailure('Failed to parse SRT: $e'));
    }
  }
}

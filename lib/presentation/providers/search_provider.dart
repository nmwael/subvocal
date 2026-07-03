import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/utils/srt_parser.dart';
import '../../data/datasources/local_file_source.dart';
import '../../data/datasources/opensubtitles_api.dart';
import '../../data/repositories/subtitle_repository_impl.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/entities/subtitle.dart';
import '../../domain/usecases/download_subtitle.dart';
import '../../domain/usecases/search_subtitles.dart';

final _httpClientProvider = Provider<http.Client>((ref) => http.Client());

final _srtParserProvider = Provider<SrtParser>((ref) => SrtParser());

final _localFileSourceProvider = Provider<LocalFileSource>((ref) => LocalFileSource());

final _openSubtitlesApiProvider = Provider<OpenSubtitlesApi>((ref) {
  const apiKey = String.fromEnvironment('OPENSUBTITLES_API_KEY', defaultValue: '');
  return OpenSubtitlesApi(ref.watch(_httpClientProvider), apiKey);
});

final subtitleRepositoryProvider = Provider<SubtitleRepositoryImpl>((ref) {
  return SubtitleRepositoryImpl(
    api: ref.watch(_openSubtitlesApiProvider),
    localFileSource: ref.watch(_localFileSourceProvider),
    srtParser: ref.watch(_srtParserProvider),
  );
});

final searchSubtitlesProvider = Provider<SearchSubtitles>((ref) {
  return SearchSubtitles(ref.watch(subtitleRepositoryProvider));
});

final downloadSubtitleProvider = Provider<DownloadSubtitle>((ref) {
  return DownloadSubtitle(ref.watch(subtitleRepositoryProvider));
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.autoDispose.family<List<SearchResult>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final searchSubtitles = ref.watch(searchSubtitlesProvider);
  final (results, failure) = await searchSubtitles.call(query);
  if (failure != null) throw failure;
  return results ?? [];
});

final importedSubtitleProvider = StateProvider<Subtitle?>((ref) => null);

final downloadedSubtitleProvider = StateProvider<Subtitle?>((ref) => null);

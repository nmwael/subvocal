import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/recent_subtitles_local_source.dart';
import '../../domain/entities/recent_subtitle_info.dart';
import '../../domain/entities/subtitle.dart';

final _recentSubtitlesLocalSourceProvider = Provider<RecentSubtitlesLocalSource>((ref) {
  return RecentSubtitlesLocalSource();
});

class RecentSubtitlesNotifier extends StateNotifier<List<RecentSubtitleInfo>> {
  final RecentSubtitlesLocalSource _localSource;

  RecentSubtitlesNotifier(this._localSource) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _localSource.load();
  }

  Future<void> add(Subtitle subtitle, {String? path}) async {
    final info = RecentSubtitleInfo(
      title: subtitle.title,
      filePath: path ?? '',
      language: subtitle.language,
      addedAt: DateTime.now(),
    );
    state = [info, ...state.take(19)];
    await _localSource.save(state);
  }

  Future<void> remove(int index) async {
    if (index >= 0 && index < state.length) {
      state = [...state.take(index), ...state.skip(index + 1)];
      await _localSource.save(state);
    }
  }

  Future<void> clear() async {
    state = [];
    await _localSource.save(state);
  }
}

final recentSubtitlesProvider = StateNotifierProvider<RecentSubtitlesNotifier, List<RecentSubtitleInfo>>((ref) {
  return RecentSubtitlesNotifier(ref.watch(_recentSubtitlesLocalSourceProvider));
});

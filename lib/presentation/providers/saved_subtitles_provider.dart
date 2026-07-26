import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/saved_subtitles_local_source.dart';
import '../../domain/entities/saved_subtitle.dart';
import '../../domain/entities/subtitle.dart';

final savedSubtitlesLocalSourceProvider = Provider<SavedSubtitlesLocalSource>((
  ref,
) {
  return SavedSubtitlesLocalSource();
});

final savedSubtitlesProvider =
    StateNotifierProvider<
      SavedSubtitlesNotifier,
      AsyncValue<List<SavedSubtitle>>
    >((ref) {
      return SavedSubtitlesNotifier(
        ref.watch(savedSubtitlesLocalSourceProvider),
      );
    });

class SavedSubtitlesNotifier
    extends StateNotifier<AsyncValue<List<SavedSubtitle>>> {
  final SavedSubtitlesLocalSource _localSource;

  SavedSubtitlesNotifier(this._localSource)
    : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    final items = await _localSource.load();
    state = AsyncValue.data(items);
  }

  Future<SavedSubtitle> save(Subtitle subtitle, String language) async {
    final saved = await _localSource.save(subtitle, language);
    await _load();
    return saved;
  }

  Future<void> delete(String id) async {
    await _localSource.delete(id);
    await _load();
  }
}

class SearchResult {
  final dynamic fileId;
  final String title;
  final String? year;
  final String? language;
  final int? subtitleCount;
  final String? releaseName;
  final String? providerSource;
  final int? season;
  final int? episode;
  final String? episodeName;

  const SearchResult({
    required this.fileId,
    required this.title,
    this.year,
    this.language,
    this.subtitleCount,
    this.releaseName,
    this.providerSource,
    this.season,
    this.episode,
    this.episodeName,
  });

  String get formattedTitle {
    final buffer = StringBuffer(title);
    if (season != null && episode != null) {
      buffer.write(
        ' S${season.toString().padLeft(2, '0')}E${episode.toString().padLeft(2, '0')}',
      );
    }
    if (episodeName != null && episodeName!.isNotEmpty) {
      buffer.write(' $episodeName');
    }
    return buffer.toString();
  }
}

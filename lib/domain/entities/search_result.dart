class SearchResult {
  final int fileId;
  final String title;
  final String? year;
  final String? language;
  final int? subtitleCount;
  final String? releaseName;

  const SearchResult({
    required this.fileId,
    required this.title,
    this.year,
    this.language,
    this.subtitleCount,
    this.releaseName,
  });
}

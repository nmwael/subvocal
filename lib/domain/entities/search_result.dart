class SearchResult {
  final dynamic fileId;
  final String title;
  final String? year;
  final String? language;
  final int? subtitleCount;
  final String? releaseName;
  final String? providerSource;

  const SearchResult({
    required this.fileId,
    required this.title,
    this.year,
    this.language,
    this.subtitleCount,
    this.releaseName,
    this.providerSource,
  });
}

class RecentSubtitleInfo {
  final String title;
  final String filePath;
  final String? language;
  final DateTime addedAt;

  const RecentSubtitleInfo({
    required this.title,
    required this.filePath,
    this.language,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'filePath': filePath,
    'language': language,
    'addedAt': addedAt.toIso8601String(),
  };

  factory RecentSubtitleInfo.fromJson(Map<String, dynamic> json) => RecentSubtitleInfo(
    title: json['title'] as String? ?? 'Unknown',
    filePath: json['filePath'] as String? ?? '',
    language: json['language'] as String?,
    addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

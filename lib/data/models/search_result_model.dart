import '../../domain/entities/search_result.dart';

class SearchResultModel {
  final int fileId;
  final String title;
  final String? year;
  final String? language;
  final int? subtitleCount;
  final String? releaseName;

  const SearchResultModel({
    required this.fileId,
    required this.title,
    this.year,
    this.language,
    this.subtitleCount,
    this.releaseName,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>?;
    final features = attributes?['features'] as List<dynamic>?;

    int _parseFileId() {
      final id = json['id'];
      if (id is int) return id;
      if (id is String) {
        final parsed = int.tryParse(id);
        if (parsed != null) return parsed;
      }
      if (id is num) return id.toInt();
      return 0;
    }

    String? _extractYear() {
      final feature = features?.isNotEmpty == true
          ? features!.first
          : null;
      if (feature is! Map<String, dynamic>) return null;
      final raw = feature['year'];
      return raw?.toString();
    }

    String _extractTitle() {
      if (attributes?.containsKey('title') == true) {
        final title = attributes!['title'];
        if (title is String && title.isNotEmpty) return title;
      }
      final feature = attributes?['feature'];
      if (feature is Map<String, dynamic>) {
        final featureTitle = feature['title'];
        if (featureTitle is String && featureTitle.isNotEmpty) return featureTitle;
      }
      final rawTitle = json['title'];
      if (rawTitle is String && rawTitle.isNotEmpty) return rawTitle;
      return 'Unknown';
    }

    return SearchResultModel(
      fileId: _parseFileId(),
      title: _extractTitle(),
      year: _extractYear(),
      language: attributes?['language'] as String?,
      subtitleCount: attributes?['subtitle_count'] as int?,
      releaseName: attributes?['release'] as String?,
    );
  }

  SearchResult toEntity() {
    return SearchResult(
      fileId: fileId,
      title: title,
      year: year,
      language: language,
      subtitleCount: subtitleCount,
      releaseName: releaseName,
    );
  }
}

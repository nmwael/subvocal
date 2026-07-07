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

    int parseFileId() {
      final files = attributes?['files'] as List<dynamic>?;
      final firstFile = files?.isNotEmpty == true ? files!.first : null;
      if (firstFile is Map<String, dynamic>) {
        final fileId = firstFile['file_id'];
        if (fileId is int) return fileId;
        if (fileId is String) {
          final parsed = int.tryParse(fileId);
          if (parsed != null) return parsed;
        }
        if (fileId is num) return fileId.toInt();
      }
      return 0;
    }

    String? extractYear() {
      final featureDetails = attributes?['feature_details'];
      if (featureDetails is Map<String, dynamic>) {
        final raw = featureDetails['year'];
        return raw?.toString();
      }
      return null;
    }

    String extractTitle() {
      final featureDetails = attributes?['feature_details'];
      if (featureDetails is Map<String, dynamic>) {
        final title = featureDetails['title'];
        if (title is String && title.isNotEmpty) return title;
      }
      final release = attributes?['release'];
      if (release is String && release.isNotEmpty) return release;
      return 'Unknown';
    }

    return SearchResultModel(
      fileId: parseFileId(),
      title: extractTitle(),
      year: extractYear(),
      language: attributes?['language'] as String?,
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

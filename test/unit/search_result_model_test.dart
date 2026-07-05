import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/data/models/search_result_model.dart';

import '../fixtures/search_result_fixtures.dart';

void main() {
  group('SearchResultModel.fromJson', () {
    test('parses full result with all fields', () {
      final model = SearchResultModel.fromJson(fullResult);

      expect(model.fileId, 12345);
      expect(model.title, 'Inception');
      expect(model.year, '2010');
      expect(model.language, 'en');
      expect(model.subtitleCount, 42);
      expect(model.releaseName, 'Inception.2010.1080p.BluRay');
    });

    test('parses minimal result with only required fields', () {
      final model = SearchResultModel.fromJson(minimalResult);

      expect(model.fileId, 0);
      expect(model.title, 'Unknown');
      expect(model.year, isNull);
      expect(model.language, isNull);
      expect(model.subtitleCount, isNull);
      expect(model.releaseName, isNull);
    });

    test('handles string fileId', () {
      final model = SearchResultModel.fromJson(stringIdResult);

      expect(model.fileId, 54321);
    });

    test('handles null attributes', () {
      final model = SearchResultModel.fromJson(nullAttributesResult);

      expect(model.fileId, 0);
      expect(model.title, 'Unknown');
      expect(model.year, isNull);
      expect(model.language, isNull);
    });

    test('handles missing features list', () {
      final model = SearchResultModel.fromJson(noFeaturesResult);

      expect(model.fileId, 22222);
      expect(model.title, 'Test Movie');
      expect(model.year, isNull);
    });

    test('handles null feature entries', () {
      final model = SearchResultModel.fromJson(nullFeatureResult);

      expect(model.fileId, 33333);
      expect(model.year, isNull);
    });

    test('handles non-Map feature entry', () {
      final model = SearchResultModel.fromJson(nonMapFeatureResult);

      expect(model.fileId, 44444);
      expect(model.year, isNull);
    });

    test('handles non-integer non-string fileId', () {
      final model = SearchResultModel.fromJson(doubleIdResult);

      expect(model.fileId, 99999);
    });

    test('converts to entity correctly', () {
      final model = SearchResultModel.fromJson(fullResult);
      final entity = model.toEntity();

      expect(entity.fileId, model.fileId);
      expect(entity.title, model.title);
      expect(entity.year, model.year);
      expect(entity.language, model.language);
      expect(entity.subtitleCount, model.subtitleCount);
      expect(entity.releaseName, model.releaseName);
    });
  });
}

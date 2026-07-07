final Map<String, dynamic> fullResult = {
  'attributes': {
    'language': 'en',
    'release': 'Inception.2010.1080p.BluRay',
    'files': [
      {'file_id': 12345},
    ],
    'feature_details': {
      'title': 'Inception',
      'year': 2010,
    },
  },
};

final Map<String, dynamic> minimalResult = {};

final Map<String, dynamic> stringIdResult = {
  'attributes': {
    'files': [
      {'file_id': '54321'},
    ],
    'feature_details': {'title': 'Test'},
  },
};

final Map<String, dynamic> nullAttributesResult = {
  'attributes': null,
};

final Map<String, dynamic> noFeatureDetailsResult = {
  'attributes': {
    'files': [
      {'file_id': 22222},
    ],
    'release': 'Test Movie',
  },
};

final Map<String, dynamic> nullFeatureDetailsResult = {
  'attributes': {
    'files': [
      {'file_id': 33333},
    ],
    'feature_details': null,
  },
};

final Map<String, dynamic> nonMapFeatureDetailsResult = {
  'attributes': {
    'files': [
      {'file_id': 44444},
    ],
    'feature_details': 'not a map',
  },
};

final Map<String, dynamic> doubleIdResult = {
  'attributes': {
    'files': [
      {'file_id': 99999.0},
    ],
  },
};

final Map<String, dynamic> fullResult = {
  'attributes': {
    'title': 'Inception',
    'language': 'en',
    'subtitle_count': 42,
    'release': 'Inception.2010.1080p.BluRay',
    'files': [
      {'file_id': 12345},
    ],
    'feature': {
      'title': 'Inception',
      'year': 2010,
    },
    'features': [
      {'year': 2010},
    ],
  },
};

final Map<String, dynamic> minimalResult = {};

final Map<String, dynamic> stringIdResult = {
  'attributes': {
    'title': 'Test',
    'files': [
      {'file_id': '54321'},
    ],
    'feature': {'title': 'Test'},
    'features': [],
  },
};

final Map<String, dynamic> nullAttributesResult = {
  'attributes': null,
};

final Map<String, dynamic> noFeaturesResult = {
  'attributes': {
    'title': 'Test Movie',
    'files': [
      {'file_id': 22222},
    ],
    'feature': {'title': 'Test Movie'},
  },
};

final Map<String, dynamic> nullFeatureResult = {
  'attributes': {
    'title': 'Test',
    'files': [
      {'file_id': 33333},
    ],
    'feature': {'title': 'Test'},
    'features': null,
  },
};

final Map<String, dynamic> nonMapFeatureResult = {
  'attributes': {
    'title': 'Test',
    'files': [
      {'file_id': 44444},
    ],
    'feature': {'title': 'Test'},
    'features': ['not a map'],
  },
};

final Map<String, dynamic> doubleIdResult = {
  'attributes': {
    'title': 'Test',
    'files': [
      {'file_id': 99999.0},
    ],
  },
};

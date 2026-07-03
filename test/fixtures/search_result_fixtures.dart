final Map<String, dynamic> fullResult = {
  'id': 12345,
  'attributes': {
    'title': 'Inception',
    'language': 'en',
    'subtitle_count': 42,
    'release': 'Inception.2010.1080p.BluRay',
    'feature': {
      'title': 'Inception',
      'year': 2010,
    },
    'features': [
      {'year': 2010},
    ],
  },
};

final Map<String, dynamic> minimalResult = {
  'id': 67890,
};

final Map<String, dynamic> stringIdResult = {
  'id': '54321',
  'attributes': {
    'title': 'Test',
    'feature': {'title': 'Test'},
    'features': [],
  },
};

final Map<String, dynamic> nullAttributesResult = {
  'id': 11111,
  'attributes': null,
};

final Map<String, dynamic> noFeaturesResult = {
  'id': 22222,
  'attributes': {
    'title': 'Test Movie',
    'feature': {'title': 'Test Movie'},
  },
};

final Map<String, dynamic> nullFeatureResult = {
  'id': 33333,
  'attributes': {
    'title': 'Test',
    'feature': {'title': 'Test'},
    'features': null,
  },
};

final Map<String, dynamic> nonMapFeatureResult = {
  'id': 44444,
  'attributes': {
    'title': 'Test',
    'feature': {'title': 'Test'},
    'features': ['not a map'],
  },
};

final Map<String, dynamic> doubleIdResult = {
  'id': 99999.0,
  'attributes': {
    'title': 'Test',
  },
};

String countryCodeToEmoji(String countryCode) {
  final code = countryCode.toUpperCase();
  if (code.length != 2) return '🏳️';
  final int first = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
  final int second = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
  return String.fromCharCodes([first, second]);
}

String languageCodeToCountryCode(String languageCode) {
  const mapping = {
    'en': 'US',
    'da': 'DK',
    'de': 'DE',
    'es': 'ES',
    'fr': 'FR',
    'it': 'IT',
    'pt': 'PT',
    'nl': 'NL',
    'sv': 'SE',
    'nb': 'NO',
    'nn': 'NO',
    'fi': 'FI',
    'pl': 'PL',
    'cs': 'CZ',
    'sk': 'SK',
    'hu': 'HU',
    'ro': 'RO',
    'bg': 'BG',
    'el': 'GR',
    'ru': 'RU',
    'uk': 'UA',
    'tr': 'TR',
    'ar': 'SA',
    'he': 'IL',
    'hi': 'IN',
    'zh': 'CN',
    'ja': 'JP',
    'ko': 'KR',
    'th': 'TH',
    'vi': 'VN',
    'id': 'ID',
    'ms': 'MY',
    'tl': 'PH',
  };
  return mapping[languageCode] ?? languageCode.toUpperCase();
}

String languageCodeToFlag(String languageCode) {
  return countryCodeToEmoji(languageCodeToCountryCode(languageCode));
}

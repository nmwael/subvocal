class AppConstants {
  AppConstants._();

  static const String appName = 'subvocal';
  static const Duration ttsPauseThreshold = Duration(milliseconds: 500);
  static const double defaultTtsRate = 0.5;
  static const double defaultTtsPitch = 1.0;
  static const double maxSyncOffset = 5.0;
  static const int maxRecentSubtitles = 20;
}

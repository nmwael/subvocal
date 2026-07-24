import 'dart:collection';

enum LogLevel { debug, info, warning, error }

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? source;
  final Object? error;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.source,
    this.error,
  });

  @override
  String toString() {
    final ts = timestamp.toIso8601String().substring(11, 19);
    final src = source != null ? '[$source]' : '';
    final err = error != null ? ' | $error' : '';
    return '$ts ${level.name.toUpperCase()} $src $message$err';
  }
}

class AppLogger {
  static const _maxEntries = 200;

  final Queue<LogEntry> _entries = Queue<LogEntry>();

  UnmodifiableListView<LogEntry> get entries =>
      UnmodifiableListView(_entries);

  void debug(String message, {String? source, Object? error}) =>
      _log(LogLevel.debug, message, source: source, error: error);

  void info(String message, {String? source, Object? error}) =>
      _log(LogLevel.info, message, source: source, error: error);

  void warning(String message, {String? source, Object? error}) =>
      _log(LogLevel.warning, message, source: source, error: error);

  void error(String message, {String? source, Object? error}) =>
      _log(LogLevel.error, message, source: source, error: error);

  void _log(LogLevel level, String message, {String? source, Object? error}) {
    _entries.addLast(LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      source: source,
      error: error,
    ));
    while (_entries.length > _maxEntries) {
      _entries.removeFirst();
    }
  }

  String exportLogs() => _entries.map((e) => e.toString()).join('\n');

  void clear() => _entries.clear();
}

final appLogger = AppLogger();

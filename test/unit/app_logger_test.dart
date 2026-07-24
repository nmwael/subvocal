import 'package:flutter_test/flutter_test.dart';
import 'package:subvocal/core/utils/app_logger.dart';

void main() {
  group('AppLogger', () {
    late AppLogger logger;

    setUp(() {
      logger = AppLogger();
    });

    test('logs entries at different levels', () {
      logger.debug('debug msg', source: 'Test');
      logger.info('info msg', source: 'Test');
      logger.warning('warn msg', source: 'Test');
      logger.error('error msg', source: 'Test');

      expect(logger.entries.length, 4);
      expect(logger.entries[0].level, LogLevel.debug);
      expect(logger.entries[1].level, LogLevel.info);
      expect(logger.entries[2].level, LogLevel.warning);
      expect(logger.entries[3].level, LogLevel.error);
    });

    test('stores source and error', () {
      logger.error('msg', source: 'MySource', error: Exception('boom'));

      final entry = logger.entries.first;
      expect(entry.source, 'MySource');
      expect(entry.error.toString(), contains('boom'));
    });

    test('caps entries at 200', () {
      for (var i = 0; i < 250; i++) {
        logger.info('entry $i');
      }
      expect(logger.entries.length, 200);
      expect(logger.entries.first.message, 'entry 50');
    });

    test('clear empties the log', () {
      logger.info('test');
      logger.clear();
      expect(logger.entries, isEmpty);
    });

    test('exportLogs returns formatted string', () {
      logger.info('hello', source: 'Src');
      final output = logger.exportLogs();
      expect(output, contains('INFO'));
      expect(output, contains('[Src]'));
      expect(output, contains('hello'));
    });

    test('toString includes timestamp and level', () {
      final entry = LogEntry(
        timestamp: DateTime(2025, 1, 15, 10, 30, 45),
        level: LogLevel.error,
        message: 'test',
      );
      final str = entry.toString();
      expect(str, contains('10:30:45'));
      expect(str, contains('ERROR'));
      expect(str, contains('test'));
    });
  });
}

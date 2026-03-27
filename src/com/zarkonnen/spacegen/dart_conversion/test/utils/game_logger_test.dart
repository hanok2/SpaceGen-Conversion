import 'package:test/test.dart';
import 'package:spacegen/core/game_logger.dart';

void main() {
  group('GameLogger', () {
    test('logs messages', () {
      final logger = GameLogger();
      logger.setYear(100);
      logger.log('Test message');

      expect(logger.fullLog.length, equals(2));
      expect(logger.fullLog[0], equals('100:'));
      expect(logger.fullLog[1], equals('Test message'));
    });

    test('logs to turn log', () {
      final logger = GameLogger();
      logger.setYear(100);
      logger.log('Turn event');

      expect(logger.turnLog.length, equals(2));
      expect(logger.turnLog[1], equals('Turn event'));
    });

    test('clears turn log when marked', () {
      final logger = GameLogger();
      logger.setYear(100);
      logger.log('First message');
      logger.markClearTurnLogOnNextEntry();
      logger.log('Second message');

      expect(logger.turnLog.length, equals(1));
      expect(logger.turnLog[0], equals('Second message'));
    });

    test('replaces placeholders in messages', () {
      final logger = GameLogger();
      logger.setYear(100);
      logger.log('Planet \$name discovered', replacements: {'\$name': 'Earth'});

      expect(logger.fullLog[1], equals('Planet Earth discovered'));
    });

    test('announces year only once per year', () {
      final logger = GameLogger();
      logger.setYear(100);
      logger.log('Event 1');
      logger.log('Event 2');

      expect(logger.fullLog.where((msg) => msg == '100:').length, equals(1));
    });

    test('clears all logs', () {
      final logger = GameLogger();
      logger.setYear(100);
      logger.log('Test');
      logger.clear();

      expect(logger.fullLog.isEmpty, isTrue);
      expect(logger.turnLog.isEmpty, isTrue);
    });

    test('toString returns formatted log', () {
      final logger = GameLogger();
      logger.setYear(100);
      logger.log('Event 1');
      logger.log('Event 2');

      final output = logger.toString();
      expect(output, contains('100:'));
      expect(output, contains('Event 1'));
      expect(output, contains('Event 2'));
    });
  });
}

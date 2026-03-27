import 'package:test/test.dart';
import 'package:spacegen/utils/random_utils.dart';

void main() {
  group('RandomUtils', () {
    test('deterministic random generation with seed', () {
      final random1 = RandomUtils(42);
      final random2 = RandomUtils(42);
      
      expect(random1.nextInt(100), equals(random2.nextInt(100)));
      expect(random1.nextInt(100), equals(random2.nextInt(100)));
      expect(random1.nextInt(100), equals(random2.nextInt(100)));
    });
    
    test('coin flip returns boolean', () {
      final random = RandomUtils(42);
      final result = random.coin();
      expect(result, isA<bool>());
    });
    
    test('d returns value in range', () {
      final random = RandomUtils(42);
      for (int i = 0; i < 100; i++) {
        final result = random.d(10);
        expect(result, greaterThanOrEqualTo(0));
        expect(result, lessThan(10));
      }
    });
    
    test('dRolls sums multiple dice rolls', () {
      final random = RandomUtils(42);
      final result = random.dRolls(3, 6);
      expect(result, greaterThanOrEqualTo(0));
      expect(result, lessThan(18));
    });
    
    test('pick selects from list', () {
      final random = RandomUtils(42);
      final items = ['a', 'b', 'c', 'd', 'e'];
      final picked = random.pick(items);
      expect(items.contains(picked), isTrue);
    });
    
    test('pick throws on empty list', () {
      final random = RandomUtils(42);
      expect(() => random.pick([]), throwsArgumentError);
    });
    
    test('p returns true when d(n) == 0', () {
      final random = RandomUtils(42);
      bool foundTrue = false;
      bool foundFalse = false;
      
      for (int i = 0; i < 100; i++) {
        if (random.p(2)) {
          foundTrue = true;
        } else {
          foundFalse = true;
        }
      }
      
      expect(foundTrue, isTrue);
      expect(foundFalse, isTrue);
    });
    
    test('atLeast works correctly', () {
      final random = RandomUtils(42);
      for (int i = 0; i < 50; i++) {
        random.atLeast(5, 10);
      }
    });
    
    test('lessThan works correctly', () {
      final random = RandomUtils(42);
      for (int i = 0; i < 50; i++) {
        random.lessThan(5, 10);
      }
    });
  });
}

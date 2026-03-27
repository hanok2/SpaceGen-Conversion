import 'package:test/test.dart';
import 'package:spacegen/utils/name_generator.dart';

void main() {
  group('NameGenerator', () {
    test('generates consistent planet names from seed', () {
      final name1 = NameGenerator.generatePlanetName(12345);
      final name2 = NameGenerator.generatePlanetName(12345);
      expect(name1, equals(name2));
    });
    
    test('generates different names for different seeds', () {
      final name1 = NameGenerator.generatePlanetName(12345);
      final name2 = NameGenerator.generatePlanetName(54321);
      expect(name1, isNot(equals(name2)));
    });
    
    test('generates planet name with roman numeral for even seeds', () {
      final name = NameGenerator.generatePlanetName(100);
      expect(name, contains(RegExp(r' [IVX]+')));
    });
    
    test('generates procedural name for odd seeds', () {
      final name = NameGenerator.generatePlanetName(101);
      expect(name.length, greaterThan(0));
    });
    
    test('generates civilization name with single member', () {
      final name = NameGenerator.generateCivName(
        governmentTitle: 'Republic',
        memberNames: ['Humans'],
      );
      expect(name, equals('Republic of Humans'));
    });
    
    test('generates civilization name with multiple members', () {
      final name = NameGenerator.generateCivName(
        governmentTitle: 'Empire',
        memberNames: ['Humans', 'Elves', 'Dwarves'],
      );
      expect(name, equals('Empire of Humans, Elves and Dwarves'));
    });
    
    test('generates civilization name with nth prefix', () {
      final name = NameGenerator.generateCivName(
        governmentTitle: 'Kingdom',
        memberNames: ['Dragons'],
        nth: 2,
      );
      expect(name, equals('Second Kingdom of Dragons'));
    });
    
    test('generates civilization name without nth prefix for first', () {
      final name = NameGenerator.generateCivName(
        governmentTitle: 'Theocracy',
        memberNames: ['Zealots'],
        nth: 1,
      );
      expect(name, equals('Theocracy of Zealots'));
    });
  });
}

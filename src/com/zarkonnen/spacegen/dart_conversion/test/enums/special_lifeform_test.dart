import 'package:test/test.dart';
import 'package:spacegen/enums/special_lifeform.dart';

void main() {
  group('SpecialLifeform', () {
    test('has correct names and descriptions', () {
      expect(SpecialLifeform.ultravores.name, equals('Ultravores'));
      expect(
        SpecialLifeform.ultravores.desc,
        contains('ultimate apex predator'),
      );
      
      expect(SpecialLifeform.pharmaceuticals.name, equals('Pharmaceuticals'));
      expect(SpecialLifeform.shapeShifter.name, equals('Shape-shifters'));
      expect(SpecialLifeform.brainParasite.name, equals('Brain parasites'));
      expect(SpecialLifeform.vastHerds.name, equals('Vast grazing herds'));
      expect(SpecialLifeform.flyingCreatures.name, equals('Beautiful flying creatures'));
      expect(SpecialLifeform.oceanGiants.name, equals('Ocean giants'));
      expect(SpecialLifeform.livingIslands.name, equals('Living islands'));
      expect(SpecialLifeform.gasBags.name, equals('Gas bags'));
      expect(SpecialLifeform.radiovores.name, equals('Radiovores'));
    });

    test('has all expected values', () {
      expect(SpecialLifeform.values.length, equals(10));
    });
  });
}

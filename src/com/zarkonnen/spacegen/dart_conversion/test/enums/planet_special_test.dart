import 'package:test/test.dart';
import 'package:spacegen/enums/planet_special.dart';

void main() {
  group('PlanetSpecial', () {
    test('has correct announcements and explanations', () {
      expect(
        PlanetSpecial.poisonWorld.announcement,
        equals('\$name has become a poison world.'),
      );
      expect(
        PlanetSpecial.poisonWorld.explanation,
        contains('Poison World'),
      );
      
      expect(PlanetSpecial.gemWorld.announcement, contains('gems'));
      expect(PlanetSpecial.titanicMountains.announcement, contains('mountains'));
      expect(PlanetSpecial.vastCanyons.announcement, contains('canyons'));
      expect(PlanetSpecial.deepImpenetrableSeas.announcement, contains('seas'));
      expect(PlanetSpecial.beautifulAurorae.announcement, contains('aurorae'));
      expect(PlanetSpecial.giganticCaveNetwork.announcement, contains('caves'));
      expect(PlanetSpecial.tidallyLockedToStar.announcement, contains('tidally locked'));
      expect(PlanetSpecial.musicalCaves.announcement, contains('music'));
      expect(PlanetSpecial.icePlanet.announcement, contains('ice'));
      expect(PlanetSpecial.periodicalDarkness.announcement, contains('darkness'));
      expect(PlanetSpecial.hugePlains.announcement, contains('plains'));
    });

    test('has all expected values', () {
      expect(PlanetSpecial.values.length, equals(12));
    });

    test('apply method exists', () {
      expect(() => PlanetSpecial.poisonWorld.apply(null), returnsNormally);
    });
  });
}

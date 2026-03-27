import 'package:test/test.dart';
import 'package:spacegen/models/civilization.dart';
import 'package:spacegen/models/planet.dart';
import 'package:spacegen/models/population.dart';
import 'package:spacegen/models/sentient_type.dart';
import 'package:spacegen/models/artefact.dart';
import 'package:spacegen/enums/government.dart';
import 'package:spacegen/systems/science_system.dart';
import 'package:spacegen/utils/random_utils.dart';

Civilization _makeCiv(String name, {Government gov = Government.republic}) =>
    Civilization(government: gov, name: name, birthYear: 0);

Planet _makePlanet(String name, {int x = 0, int y = 0, bool habitable = true}) =>
    Planet(name: name, habitable: habitable, x: x, y: y);

SentientType _makeType(String name) => SentientType(
      birth: 0,
      base: SentientBase.humanoids,
      personality: 'peaceful',
      goal: 'exploration',
      name: name,
    );

void main() {
  group('ScienceSystem', () {
    test('advance returns false when no colonies', () {
      final random = RandomUtils(42);
      final sci = ScienceSystem(random);
      final civ = _makeCiv('Empty');
      final result = sci.advance(civ, [civ], [], 100, (_) {});
      expect(result, isFalse);
    });

    test('advance tech level increases techLevel', () {
      bool foundTechAdvance = false;
      for (int seed = 0; seed < 1000 && !foundTechAdvance; seed++) {
        final random = RandomUtils(seed);
        if (random.d(9) == 0) {
          final sci = ScienceSystem(RandomUtils(seed));
          final civ = _makeCiv('Scientists');
          civ.techLevel = 1;
          final home = _makePlanet('Home');
          home.owner = civ;
          home.inhabitants.add(Population(type: _makeType('Humans'), size: 5, planet: home));
          final log = <String>[];
          sci.advance(civ, [civ], [home], 100, log.add);
          expect(civ.techLevel, equals(2));
          foundTechAdvance = true;
        }
      }
    });

    test('advance weapons increases weaponLevel', () {
      bool foundWeapon = false;
      for (int seed = 0; seed < 10000 && !foundWeapon; seed++) {
        final r = RandomUtils(seed);
        if (r.d(9) == 1) {
          final sci = ScienceSystem(RandomUtils(seed));
          final civ = _makeCiv('Militarists');
          civ.weaponLevel = 0;
          final home = _makePlanet('Home');
          home.owner = civ;
          home.inhabitants.add(Population(type: _makeType('Humans'), size: 5, planet: home));
          final log = <String>[];
          sci.advance(civ, [civ], [home], 100, log.add);
          expect(civ.weaponLevel, equals(1));
          foundWeapon = true;
        }
      }
    });

    test('advance transcendence removes civ at techLevel 10', () {
      bool foundTranscend = false;
      for (int seed = 0; seed < 10000 && !foundTranscend; seed++) {
        final r = RandomUtils(seed);
        if (r.d(9) == 0) {
          final sci = ScienceSystem(RandomUtils(seed));
          final civ = _makeCiv('Transcendent');
          civ.techLevel = 9;
          final home = _makePlanet('Home');
          home.owner = civ;
          home.inhabitants.add(Population(type: _makeType('Humans'), size: 3, planet: home));
          final civs = [civ];
          final planets = [home];
          final log = <String>[];
          final result = sci.advance(civ, civs, planets, 100, log.add);
          expect(result, isTrue);
          expect(civs, isNot(contains(civ)));
          foundTranscend = true;
        }
      }
    });

    test('advance creates robots on colony without robots', () {
      bool foundRobots = false;
      for (int seed = 0; seed < 10000 && !foundRobots; seed++) {
        final r = RandomUtils(seed);
        if (r.d(9) == 4) {
          final sci = ScienceSystem(RandomUtils(seed));
          final civ = _makeCiv('Roboticists');
          final home = _makePlanet('Home');
          home.owner = civ;
          home.inhabitants.add(Population(type: _makeType('Humans'), size: 5, planet: home));
          final log = <String>[];
          sci.advance(civ, [civ], [home], 100, log.add);
          final hasRobots = home.inhabitants.any((p) => p.type.base == SentientBase.robots);
          expect(hasRobots, isTrue);
          foundRobots = true;
        }
      }
    });

    test('advance creates artefact on technology breakthrough', () {
      bool foundArtefact = false;
      for (int seed = 0; seed < 10000 && !foundArtefact; seed++) {
        final r = RandomUtils(seed);
        final roll = r.d(9);
        if (roll == 6 || roll == 7 || roll == 8) {
          final sci = ScienceSystem(RandomUtils(seed));
          final civ = _makeCiv('Scientists');
          final home = _makePlanet('Home');
          home.owner = civ;
          home.inhabitants.add(Population(type: _makeType('Humans'), size: 5, planet: home));
          final log = <String>[];
          sci.advance(civ, [civ], [home], 100, log.add);
          expect(home.artefacts, isNotEmpty);
          expect(home.artefacts.first.type, equals(ArtefactType.technology));
          foundArtefact = true;
        }
      }
    });

    test('advance logs a message', () {
      final sci = ScienceSystem(RandomUtils(42));
      final civ = _makeCiv('Scientists');
      final home = _makePlanet('Home');
      home.owner = civ;
      home.inhabitants.add(Population(type: _makeType('Humans'), size: 5, planet: home));
      final log = <String>[];
      sci.advance(civ, [civ], [home], 100, log.add);
      expect(log, isNotEmpty);
    });
  });
}

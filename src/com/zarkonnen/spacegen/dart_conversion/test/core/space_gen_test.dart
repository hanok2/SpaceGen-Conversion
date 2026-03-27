import 'package:test/test.dart';
import '../../lib/core/space_gen.dart';
import '../../lib/models/planet.dart';
import '../../lib/models/civilization.dart';
import '../../lib/models/population.dart';
import '../../lib/models/sentient_type.dart';
import '../../lib/enums/government.dart';

void main() {
  group('SpaceGen initialization', () {
    test('creates with seed', () {
      final sg = SpaceGen(42);
      expect(sg.year, equals(0));
      expect(sg.age, equals(1));
      expect(sg.civs, isEmpty);
      expect(sg.planets, isEmpty);
    });

    test('init creates planets', () {
      final sg = SpaceGen(42);
      sg.init();
      expect(sg.planets.length, greaterThanOrEqualTo(6));
      expect(sg.planets.length, lessThanOrEqualTo(30));
    });

    test('init gives planets unique names and positions', () {
      final sg = SpaceGen(99);
      sg.init();
      final names = sg.planets.map((p) => p.name).toSet();
      expect(names.length, equals(sg.planets.length));
    });
  });

  group('SpaceGen tick', () {
    test('tick increments year', () {
      final sg = SpaceGen(42);
      sg.init();
      sg.tick();
      expect(sg.year, equals(1));
      sg.tick();
      expect(sg.year, equals(2));
    });

    test('multiple ticks work without crash', () {
      final sg = SpaceGen(12345);
      sg.init();
      for (int i = 0; i < 100; i++) {
        sg.tick();
      }
      expect(sg.year, equals(100));
    });

    test('age transition when civs appear then disappear', () {
      final sg = SpaceGen(42);
      sg.init();

      final st = SentientType(
        birth: 0,
        base: SentientBase.humanoids,
        personality: 'bold',
        goal: 'conquer',
        name: 'Testoids',
      );
      final planet = sg.planets.first;
      planet.habitable = true;
      planet.inhabitants.add(Population(type: st, size: 3, planet: planet));

      final civ = Civilization(
        government: Government.republic,
        name: 'Test Republic',
        birthYear: 0,
        fullMembers: [st],
      );
      planet.owner = civ;
      sg.civs.add(civ);
      sg.historicalCivNames.add(civ.name);

      sg.tick();
      expect(sg.hadCivs, isTrue);
    });
  });

  group('SpaceGen interesting', () {
    test('not interesting at year 0', () {
      final sg = SpaceGen(42);
      sg.init();
      expect(sg.interesting(650), isFalse);
    });

    test('civs increase interest score', () {
      final sg = SpaceGen(42);
      sg.init();

      final st = SentientType(
        birth: 0,
        base: SentientBase.humanoids,
        personality: 'bold',
        goal: 'explore',
        name: 'Humanoids',
      );
      final p = sg.planets.first;
      p.habitable = true;
      p.inhabitants.add(Population(type: st, size: 3, planet: p));
      final civ = Civilization(
        government: Government.republic,
        name: 'Republic',
        birthYear: 0,
        fullMembers: [st],
      );
      p.owner = civ;
      sg.civs.add(civ);

      for (int i = 0; i < 200; i++) sg.tick();

      expect(sg.interesting(100), isTrue);
    });
  });

  group('SpaceGen checkCivDoom', () {
    test('civ with no full colonies is removed', () {
      final sg = SpaceGen(42);
      sg.init();

      final st = SentientType(
        birth: 0,
        base: SentientBase.humanoids,
        personality: 'bold',
        goal: 'survive',
        name: 'Doomed',
      );
      final p = sg.planets.first;
      p.habitable = true;
      final civ = Civilization(
        government: Government.republic,
        name: 'Doomed Republic',
        birthYear: 0,
        fullMembers: [st],
      );
      p.owner = civ;
      sg.civs.add(civ);
      sg.historicalCivNames.add(civ.name);

      sg.tick();

      expect(sg.civs, isEmpty);
    });

    test('civ with single planet and 1 pop collapses', () {
      final sg = SpaceGen(42);
      sg.init();

      final st = SentientType(
        birth: 0,
        base: SentientBase.humanoids,
        personality: 'bold',
        goal: 'survive',
        name: 'LastOnes',
      );
      final p = sg.planets.first;
      p.habitable = true;
      p.inhabitants.add(Population(type: st, size: 1, planet: p));

      final civ = Civilization(
        government: Government.republic,
        name: 'Last Republic',
        birthYear: 0,
        fullMembers: [st],
      );
      p.owner = civ;
      sg.civs.add(civ);
      sg.historicalCivNames.add(civ.name);

      sg.tick();

      expect(sg.civs, isEmpty);
      expect(p.owner, isNull);
    });
  });

  group('SpaceGen describe', () {
    test('describe returns non-empty string', () {
      final sg = SpaceGen(42);
      sg.init();
      final desc = sg.describe();
      expect(desc, contains('PLANETS:'));
    });

    test('describe includes civ when present', () {
      final sg = SpaceGen(42);
      sg.init();

      final st = SentientType(
        birth: 0,
        base: SentientBase.humanoids,
        personality: 'bold',
        goal: 'explore',
        name: 'TestHumans',
      );
      final p = sg.planets.first;
      p.habitable = true;
      p.inhabitants.add(Population(type: st, size: 3, planet: p));
      final civ = Civilization(
        government: Government.republic,
        name: 'Test Republic',
        birthYear: 0,
        fullMembers: [st],
      );
      p.owner = civ;
      sg.civs.add(civ);

      final desc = sg.describe();
      expect(desc, contains('CIVILISATIONS:'));
      expect(desc, contains('Test Republic'));
      expect(desc, contains('SENTIENT SPECIES:'));
      expect(desc, contains('TestHumans'));
    });
  });

  group('SpaceGen science system integration', () {
    test('science breakthroughs accumulate', () {
      final sg = SpaceGen(1000);
      sg.init();

      final st = SentientType(
        birth: 0,
        base: SentientBase.humanoids,
        personality: 'bold',
        goal: 'research',
        name: 'Scientists',
      );
      final p = sg.planets.first;
      p.habitable = true;
      p.inhabitants.add(Population(type: st, size: 5, planet: p));
      final civ = Civilization(
        government: Government.republic,
        name: 'Science Republic',
        birthYear: 0,
        fullMembers: [st],
        resources: 100,
      );
      p.owner = civ;
      sg.civs.add(civ);
      sg.historicalCivNames.add(civ.name);

      for (int i = 0; i < 30; i++) sg.tick();

      expect(sg.fullLog.isNotEmpty, isTrue);
    });
  });

  group('SpaceGen log', () {
    test('log is populated during ticks', () {
      final sg = SpaceGen(777);
      sg.init();

      final st = SentientType(
        birth: 0,
        base: SentientBase.humanoids,
        personality: 'bold',
        goal: 'explore',
        name: 'Loggers',
      );
      final p = sg.planets[1];
      p.habitable = true;
      p.inhabitants.add(Population(type: st, size: 4, planet: p));
      final civ = Civilization(
        government: Government.republic,
        name: 'Log Republic',
        birthYear: 0,
        fullMembers: [st],
        resources: 50,
      );
      p.owner = civ;
      sg.civs.add(civ);
      sg.historicalCivNames.add(civ.name);

      for (int i = 0; i < 20; i++) sg.tick();

      expect(sg.fullLog, isNotEmpty);
    });

    test('turnLog is cleared each tick', () {
      final sg = SpaceGen(42);
      sg.init();
      sg.tick();
      final prevTurnLog = List<String>.from(sg.turnLog);
      sg.tick();
      expect(sg.turnLog, isNot(equals(prevTurnLog)));
    });
  });
}

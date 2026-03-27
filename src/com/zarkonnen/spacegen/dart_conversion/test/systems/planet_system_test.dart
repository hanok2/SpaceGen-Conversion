import 'package:test/test.dart';
import 'package:spacegen/systems/planet_evolution.dart';
import 'package:spacegen/systems/planet_events.dart';
import 'package:spacegen/systems/planet_system.dart';
import 'package:spacegen/models/planet.dart';
import 'package:spacegen/models/population.dart';
import 'package:spacegen/models/sentient_type.dart';
import 'package:spacegen/models/plague.dart';
import 'package:spacegen/models/civilization.dart';
import 'package:spacegen/models/structure.dart';
import 'package:spacegen/models/strata/fossil.dart';
import 'package:spacegen/models/strata/remnant.dart';
import 'package:spacegen/models/strata/ruin.dart';
import 'package:spacegen/enums/special_lifeform.dart';
import 'package:spacegen/enums/planet_special.dart';
import 'package:spacegen/enums/government.dart';
import 'package:spacegen/utils/random_utils.dart';

SentientType _makeType(String name) => SentientType(
      birth: 0,
      base: SentientBase.humanoids,
      personality: 'cautious',
      goal: 'deeply religious',
      name: name,
    );

Civilization _makeCiv(String name) => Civilization(
      government: Government.republic,
      name: name,
      birthYear: 0,
    );

void main() {
  group('PlanetEvolution', () {
    late RandomUtils random;
    late PlanetEvolution evo;

    setUp(() {
      random = RandomUtils(42);
      evo = PlanetEvolution(random);
    });

    test('accumulateEvolutionPoints increases points when pollution < 6', () {
      final planet = Planet(name: 'A', pollution: 0);
      evo.accumulateEvolutionPoints(planet);
      expect(planet.evolutionPoints, greaterThan(0));
    });

    test('accumulateEvolutionPoints adds zero when pollution == 6', () {
      final planet = Planet(name: 'A', pollution: 6);
      evo.accumulateEvolutionPoints(planet);
      expect(planet.evolutionPoints, equals(0));
    });

    test('checkEvolution returns false when points below threshold', () {
      final planet = Planet(name: 'A', evolutionPoints: 0, evolutionNeeded: 15000);
      final logs = <String>[];
      expect(evo.checkEvolution(planet, 0, logs.add), isFalse);
    });

    test('life arises on barren planet via evolution', () {
      final r = RandomUtils(0);
      final e = PlanetEvolution(r);
      final planet = Planet(name: 'Barren', habitable: false, pollution: 0,
          evolutionPoints: 999999, evolutionNeeded: 0);
      final logs = <String>[];
      bool lifeArose = false;
      for (int i = 0; i < 200; i++) {
        planet.evolutionPoints = 999999;
        if (e.checkEvolution(planet, i, logs.add)) {
          lifeArose = true;
          break;
        }
      }
      expect(lifeArose, isTrue);
      expect(planet.habitable, isTrue);
      expect(logs.any((l) => l.contains('Life arises')), isTrue);
    });

    test('evolution resets evoPoints to 0 on trigger', () {
      final r = RandomUtils(1);
      final e = PlanetEvolution(r);
      final planet = Planet(name: 'B', habitable: false, pollution: 0,
          evolutionPoints: 999999, evolutionNeeded: 0);
      final logs = <String>[];
      for (int i = 0; i < 200; i++) {
        planet.evolutionPoints = 999999;
        if (e.checkEvolution(planet, i, logs.add)) break;
      }
      expect(planet.evolutionPoints, equals(0));
    });

    test('high pollution prevents evolution', () {
      final planet = Planet(name: 'A', pollution: 2,
          evolutionPoints: 999999, evolutionNeeded: 0);
      final logs = <String>[];
      bool evolved = false;
      for (int i = 0; i < 500; i++) {
        planet.evolutionPoints = 999999;
        if (evo.checkEvolution(planet, i, logs.add)) {
          evolved = true;
          break;
        }
      }
      expect(evolved, isFalse);
    });

    test('processPopulationAndPollution changes population size over time', () {
      final r = RandomUtils(999);
      final e = PlanetEvolution(r);
      final planet = Planet(name: 'C', pollution: 0);
      final type = _makeType('Human');
      final pop = Population(type: type, size: 3, planet: planet);
      planet.inhabitants.add(pop);
      final initial = pop.size;
      final logs = <String>[];
      for (int i = 0; i < 100; i++) {
        e.processPopulationAndPollution(planet, i, logs.add);
      }
      expect(pop.size, isNot(equals(initial)));
    });

    test('processPopulationAndPollution removes population killed by pollution', () {
      final r = RandomUtils(0);
      final e = PlanetEvolution(r);
      final planet = Planet(name: 'D', pollution: 5);
      final type = _makeType('Alien');
      final pop = Population(type: type, size: 1, planet: planet);
      planet.inhabitants.add(pop);
      final logs = <String>[];
      for (int i = 0; i < 200; i++) {
        e.processPopulationAndPollution(planet, i, logs.add);
        if (planet.inhabitants.isEmpty) break;
        if (planet.inhabitants.isNotEmpty) {
          planet.inhabitants.first.size = 1;
          planet.pollution = 5;
        }
      }
      expect(logs.any((l) => l.contains('died out')), isTrue);
    });

    test('depopulation from pollution creates remnant stratum', () {
      final r = RandomUtils(0);
      final e = PlanetEvolution(r);
      final planet = Planet(name: 'E', pollution: 5);
      final type = _makeType('Bot');
      final pop = Population(type: type, size: 1, planet: planet);
      planet.inhabitants.add(pop);
      final logs = <String>[];
      for (int i = 0; i < 200; i++) {
        e.processPopulationAndPollution(planet, i, logs.add);
        if (planet.inhabitants.isEmpty) break;
        if (planet.inhabitants.isNotEmpty) {
          planet.inhabitants.first.size = 1;
          planet.pollution = 5;
        }
      }
      expect(planet.strata.whereType<Remnant>().isNotEmpty, isTrue);
    });

    test('plague lethality kills population', () {
      final r = RandomUtils(0);
      final e = PlanetEvolution(r);
      final planet = Planet(name: 'F');
      final type = _makeType('Vic');
      final pop = Population(type: type, size: 1, planet: planet);
      planet.inhabitants.add(pop);
      final plague = Plague(
        name: 'Deathpox',
        lethality: 12,
        mutationRate: 0,
        transmissivity: 0,
        curability: 0,
        color: '#FF0000',
        affects: [type],
      );
      planet.addPlague(plague);
      final logs = <String>[];
      for (int i = 0; i < 200; i++) {
        e.processPopulationAndPollution(planet, i, logs.add);
        if (planet.inhabitants.isEmpty) break;
        if (planet.inhabitants.isNotEmpty) {
          planet.inhabitants.first.size = 1;
        }
      }
      expect(logs.any((l) => l.contains('wiped out')), isTrue);
    });

    test('plague mutation adds new type to affects', () {
      final r = RandomUtils(0);
      final e = PlanetEvolution(r);
      final planet = Planet(name: 'G');
      final t1 = _makeType('Alpha');
      final t2 = _makeType('Beta');
      planet.inhabitants.add(Population(type: t1, size: 5, planet: planet));
      planet.inhabitants.add(Population(type: t2, size: 5, planet: planet));
      final plague = Plague(
        name: 'Mutox',
        lethality: 0,
        mutationRate: 12,
        transmissivity: 0,
        curability: 0,
        color: '#FF0000',
        affects: [t1],
      );
      planet.addPlague(plague);
      final logs = <String>[];
      bool mutated = false;
      for (int i = 0; i < 500; i++) {
        e.processPopulationAndPollution(planet, i, logs.add);
        if (plague.affects.contains(t2)) { mutated = true; break; }
      }
      expect(mutated, isTrue);
      expect(logs.any((l) => l.contains('mutates')), isTrue);
    });

    test('plague is cured via processPlagueCureAndSpread', () {
      final r = RandomUtils(0);
      final e = PlanetEvolution(r);
      final planet = Planet(name: 'H');
      final type = _makeType('Sick');
      final plague = Plague(
        name: 'Easypox',
        lethality: 0,
        mutationRate: 0,
        transmissivity: 0,
        curability: 12,
        color: '#FF0000',
        affects: [type],
      );
      planet.addPlague(plague);
      final logs = <String>[];
      bool cured = false;
      for (int i = 0; i < 200; i++) {
        e.processPlagueCureAndSpread(planet, [planet], logs.add);
        if (planet.plagues.isEmpty) { cured = true; break; }
        planet.addPlague(Plague(name: 'Easypox', lethality: 0, mutationRate: 0,
            transmissivity: 0, curability: 12, color: '#FF0000', affects: [type]));
      }
      expect(cured, isTrue);
      expect(logs.any((l) => l.contains('eradicated')), isTrue);
    });

    test('plague spreads to another planet', () {
      final r = RandomUtils(0);
      final e = PlanetEvolution(r);
      final type = _makeType('Spread');
      final p1 = Planet(name: 'P1');
      final p2 = Planet(name: 'P2');
      p1.inhabitants.add(Population(type: type, size: 3, planet: p1));
      p2.inhabitants.add(Population(type: type, size: 3, planet: p2));
      final plague = Plague(
        name: 'Traveler',
        lethality: 0,
        mutationRate: 0,
        transmissivity: 12,
        curability: 0,
        color: '#FF0000',
        affects: [type],
      );
      p1.addPlague(plague);
      final logs = <String>[];
      bool spread = false;
      for (int i = 0; i < 500; i++) {
        e.processPlagueCureAndSpread(p1, [p1, p2], logs.add);
        if (p2.plagues.isNotEmpty) { spread = true; break; }
      }
      expect(spread, isTrue);
    });

    test('special lifeform evolves on habitable planet', () {
      final r = RandomUtils(0);
      final e = PlanetEvolution(r);
      final planet = Planet(name: 'I', habitable: true, pollution: 0,
          evolutionPoints: 999999, evolutionNeeded: 0);
      final logs = <String>[];
      bool gotLifeform = false;
      for (int i = 0; i < 500; i++) {
        planet.evolutionPoints = 999999;
        e.checkEvolution(planet, i, logs.add);
        if (planet.lifeforms.isNotEmpty) { gotLifeform = true; break; }
      }
      expect(gotLifeform, isTrue);
    });
  });

  group('PlanetEvents', () {
    late RandomUtils random;
    late PlanetEvents events;

    setUp(() {
      random = RandomUtils(42);
      events = PlanetEvents(random);
    });

    test('checkCataclysm returns false for barren planet', () {
      final planet = Planet(name: 'Barren', habitable: false);
      final logs = <String>[];
      for (int i = 0; i < 1000; i++) {
        expect(events.checkCataclysm(planet, i, logs.add), isFalse);
      }
      expect(logs, isEmpty);
    });

    test('cataclysm eventually occurs on habitable planet', () {
      final r = RandomUtils(0);
      final ev = PlanetEvents(r);
      bool occurred = false;
      final logs = <String>[];
      for (int i = 0; i < 5000; i++) {
        final planet = Planet(name: 'Doomed', habitable: true);
        planet.addLifeform(SpecialLifeform.ultravores);
        if (ev.checkCataclysm(planet, i, logs.add)) {
          occurred = true;
          expect(planet.habitable, isFalse);
          expect(planet.strata.whereType<Fossil>().isNotEmpty, isTrue);
          break;
        }
      }
      expect(occurred, isTrue);
      expect(logs.isNotEmpty, isTrue);
    });

    test('pollution abatement requires pollution > 1', () {
      final planet = Planet(name: 'Clean', pollution: 1);
      final logs = <String>[];
      for (int i = 0; i < 1000; i++) {
        events.checkPollutionAbatement(planet, logs.add);
      }
      expect(logs, isEmpty);
      expect(planet.pollution, equals(1));
    });

    test('pollution abatement eventually triggers for pollution > 1', () {
      final r = RandomUtils(0);
      final ev = PlanetEvents(r);
      bool abated = false;
      final logs = <String>[];
      for (int i = 0; i < 2000; i++) {
        final planet = Planet(name: 'Pol', pollution: 3);
        if (ev.checkPollutionAbatement(planet, logs.add)) {
          abated = true;
          expect(planet.pollution, equals(2));
          break;
        }
      }
      expect(abated, isTrue);
    });

    test('poison world does not get pollution abatement', () {
      final planet = Planet(name: 'Toxic', pollution: 3);
      planet.specials.add(PlanetSpecial.poisonWorld);
      final logs = <String>[];
      for (int i = 0; i < 2000; i++) {
        events.checkPollutionAbatement(planet, logs.add);
      }
      expect(logs, isEmpty);
    });

    test('planet special eventually added', () {
      final r = RandomUtils(0);
      final ev = PlanetEvents(r);
      final planet = Planet(name: 'Sp');
      final logs = <String>[];
      bool added = false;
      for (int i = 0; i < 3000; i++) {
        if (ev.checkPlanetSpecial(planet, logs.add)) {
          added = true;
          break;
        }
      }
      expect(added, isTrue);
      expect(planet.specials.isNotEmpty, isTrue);
      expect(logs.isNotEmpty, isTrue);
    });

    test('duplicate planet special is not added', () {
      final r = RandomUtils(0);
      final ev = PlanetEvents(r);
      final planet = Planet(name: 'Sp2');
      final logs = <String>[];
      for (int i = 0; i < 5000; i++) {
        ev.checkPlanetSpecial(planet, logs.add);
      }
      final uniqueSpecials = planet.specials.toSet();
      expect(planet.specials.length, equals(uniqueSpecials.length));
    });

    test('processErosion removes old fossils', () {
      final r = RandomUtils(0);
      final ev = PlanetEvents(r);
      final planet = Planet(name: 'Ancient');
      planet.strata.add(Fossil(
        fossil: SpecialLifeform.ultravores,
        fossilisationTime: 1,
      ));
      bool eroded = false;
      for (int year = 1000; year < 15000; year++) {
        ev.processErosion(planet, year);
        if (planet.strata.isEmpty) { eroded = true; break; }
      }
      expect(eroded, isTrue);
    });

    test('processErosion removes old remnants', () {
      final r = RandomUtils(0);
      final ev = PlanetEvents(r);
      final planet = Planet(name: 'Rem');
      final type = _makeType('Ghost');
      final pop = Population(type: type, size: 1, planet: planet);
      planet.strata.add(Remnant(remnant: pop, collapseTime: 1));
      bool eroded = false;
      for (int year = 100; year < 5000; year++) {
        ev.processErosion(planet, year);
        if (planet.strata.isEmpty) { eroded = true; break; }
      }
      expect(eroded, isTrue);
    });

    test('processErosion removes old ruins', () {
      final r = RandomUtils(0);
      final ev = PlanetEvents(r);
      final planet = Planet(name: 'Ruin');
      final civ = _makeCiv('Ancients');
      final struct = Structure(type: StructureType.temple, builders: civ, buildTime: 1);
      planet.strata.add(Ruin(structure: struct, ruinTime: 1));
      bool eroded = false;
      for (int year = 100; year < 10000; year++) {
        ev.processErosion(planet, year);
        if (planet.strata.isEmpty) { eroded = true; break; }
      }
      expect(eroded, isTrue);
    });
  });

  group('PlanetSystem', () {
    test('tick returns list for a planet', () {
      final system = PlanetSystem(RandomUtils(42));
      final planet = Planet(name: 'Quiet', habitable: false, evolutionPoints: 0);
      final logs = system.tick(planet, 0, [planet]);
      expect(logs, isA<List<String>>());
    });

    test('tickAll returns map', () {
      final system = PlanetSystem(RandomUtils(42));
      final planets = [
        Planet(name: 'A', habitable: false),
        Planet(name: 'B', habitable: false),
      ];
      final result = system.tickAll(planets, 0);
      expect(result, isA<Map<String, List<String>>>());
    });

    test('tickAll handles empty list', () {
      final system = PlanetSystem(RandomUtils(0));
      expect(system.tickAll([], 0), isEmpty);
    });

    test('planet can evolve from barren to habitable over many ticks', () {
      final system = PlanetSystem(RandomUtils(7));
      final planet = Planet(name: 'Young', habitable: false, pollution: 0,
          evolutionPoints: 0, evolutionNeeded: 15000);
      bool lifeArose = false;
      for (int y = 0; y < 2000; y++) {
        system.tick(planet, y, [planet]);
        if (planet.habitable) { lifeArose = true; break; }
      }
      expect(lifeArose, isTrue);
    });

    test('cataclysm stops processing and returns logs', () {
      final r = RandomUtils(0);
      final system = PlanetSystem(r);
      bool cataclysm = false;
      for (int i = 0; i < 5000; i++) {
        final planet = Planet(name: 'X', habitable: true);
        planet.addLifeform(SpecialLifeform.gasBags);
        final logs = system.tick(planet, i, [planet]);
        if (logs.isNotEmpty && !planet.habitable) {
          cataclysm = true;
          break;
        }
      }
      expect(cataclysm, isTrue);
    });
  });
}

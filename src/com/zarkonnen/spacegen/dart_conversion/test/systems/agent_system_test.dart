import 'package:test/test.dart';
import 'package:spacegen/models/agent.dart';
import 'package:spacegen/models/planet.dart';
import 'package:spacegen/models/civilization.dart';
import 'package:spacegen/models/population.dart';
import 'package:spacegen/models/sentient_type.dart';
import 'package:spacegen/enums/government.dart';
import 'package:spacegen/systems/agent_system.dart';
import 'package:spacegen/utils/random_utils.dart';

SentientType _makeType(String name) => SentientType(
      birth: 0,
      base: SentientBase.humanoids,
      personality: 'peaceful',
      goal: 'exploration',
      name: name,
    );

Civilization _makeCiv(String name) =>
    Civilization(government: Government.republic, name: name, birthYear: 0);

Planet _makePlanet(String name, {int x = 0, int y = 0}) =>
    Planet(name: name, habitable: true, x: x, y: y);

void main() {
  late RandomUtils random;
  late AgentSystem system;

  setUp(() {
    random = RandomUtils(42);
    system = AgentSystem(random);
  });

  group('AgentSystem - spawnPirate', () {
    test('spawns pirate with correct type', () {
      final p = _makePlanet('Home');
      final st = _makeType('Humans');
      final agent = system.spawnPirate(location: p, sentientType: st, year: 100);
      expect(agent.type, equals(AgentType.pirate));
    });

    test('spawns pirate with location set', () {
      final p = _makePlanet('Home');
      final st = _makeType('Humans');
      final agent = system.spawnPirate(location: p, sentientType: st, year: 100);
      expect(agent.location, equals(p));
    });

    test('spawns pirate with birth year set', () {
      final p = _makePlanet('Home');
      final st = _makeType('Humans');
      final agent = system.spawnPirate(location: p, sentientType: st, year: 100);
      expect(agent.birth, equals(100));
    });

    test('spawns pirate with non-empty name', () {
      final p = _makePlanet('Home');
      final st = _makeType('Humans');
      final agent = system.spawnPirate(location: p, sentientType: st, year: 100);
      expect(agent.name, isNotEmpty);
    });

    test('spawns pirate with fleet and resources', () {
      final p = _makePlanet('Home');
      final st = _makeType('Humans');
      final agent = system.spawnPirate(location: p, sentientType: st, year: 100);
      expect(agent.fleet, greaterThan(0));
      expect(agent.resources, greaterThanOrEqualTo(0));
    });
  });

  group('AgentSystem - spawnAdventurer', () {
    test('spawns adventurer with correct type', () {
      final p = _makePlanet('Home');
      final st = _makeType('Humans');
      final civ = _makeCiv('Empire');
      final agent = system.spawnAdventurer(location: p, sentientType: st, originator: civ, year: 100);
      expect(agent.type, equals(AgentType.adventurer));
    });

    test('spawns adventurer with originator set', () {
      final p = _makePlanet('Home');
      final st = _makeType('Humans');
      final civ = _makeCiv('Empire');
      final agent = system.spawnAdventurer(location: p, sentientType: st, originator: civ, year: 100);
      expect(agent.originator, equals(civ));
    });

    test('spawns adventurer with sentient type set', () {
      final p = _makePlanet('Home');
      final st = _makeType('Humans');
      final civ = _makeCiv('Empire');
      final agent = system.spawnAdventurer(location: p, sentientType: st, originator: civ, year: 100);
      expect(agent.sentientType, equals(st));
    });
  });

  group('AgentSystem - spawnSpaceMonster', () {
    test('spawns space monster with correct type', () {
      final p = _makePlanet('Wild');
      final agent = system.spawnSpaceMonster(location: p, year: 50);
      expect(agent.type, equals(AgentType.spaceMonster));
    });

    test('spawns space monster with non-empty name from known types', () {
      final p = _makePlanet('Wild');
      final agent = system.spawnSpaceMonster(location: p, year: 50);
      expect(agent.name, isNotEmpty);
    });

    test('spawns space monster with location set', () {
      final p = _makePlanet('Wild');
      final agent = system.spawnSpaceMonster(location: p, year: 50);
      expect(agent.location, equals(p));
    });
  });

  group('AgentSystem - spawnRogueAi', () {
    test('spawns rogue AI with correct type', () {
      final p = _makePlanet('Station');
      final agent = system.spawnRogueAi(location: p, year: 200);
      expect(agent.type, equals(AgentType.rogueAi));
    });

    test('spawns rogue AI with location set', () {
      final p = _makePlanet('Station');
      final agent = system.spawnRogueAi(location: p, year: 200);
      expect(agent.location, equals(p));
    });

    test('spawns rogue AI with non-empty name', () {
      final p = _makePlanet('Station');
      final agent = system.spawnRogueAi(location: p, year: 200);
      expect(agent.name, isNotEmpty);
    });
  });

  group('AgentSystem - spawnSpaceProbe', () {
    test('spawns space probe with correct type', () {
      final target = _makePlanet('Target', x: 5, y: 5);
      final civ = _makeCiv('Explorers');
      final agent = system.spawnSpaceProbe(target: target, originator: civ, year: 300, travelTime: 10);
      expect(agent.type, equals(AgentType.spaceProbe));
    });

    test('spawns space probe with target set', () {
      final target = _makePlanet('Target', x: 5, y: 5);
      final civ = _makeCiv('Explorers');
      final agent = system.spawnSpaceProbe(target: target, originator: civ, year: 300, travelTime: 10);
      expect(agent.target, equals(target));
    });
  });

  group('AgentSystem - processAgents pirate aging', () {
    test('old pirate is removed from agents list after dying', () {
      final p = _makePlanet('Wild');
      final st = _makeType('Humans');
      final pirate = system.spawnPirate(location: p, sentientType: st, year: 0);
      final agents = [pirate];
      final logs = <String>[];
      system.processAgents(agents, [p], [], 100, logs.add);
      expect(agents, isEmpty);
    });

    test('old pirate leaves tomb on planet strata', () {
      final p = _makePlanet('Wild');
      final st = _makeType('Humans');
      final pirate = system.spawnPirate(location: p, sentientType: st, year: 0);
      final agents = [pirate];
      system.processAgents(agents, [p], [], 100, (_) {});
      expect(p.strata, isNotEmpty);
    });
  });

  group('AgentSystem - pirate tribute', () {
    test('pirate collects tribute from owned planet', () {
      final random2 = RandomUtils(7);
      final sys2 = AgentSystem(random2);
      final civ = _makeCiv('Rich Empire');
      civ.resources = 100;
      final p = _makePlanet('Colony');
      p.owner = civ;
      final st = _makeType('Humans');
      final pirate = sys2.spawnPirate(location: p, sentientType: st, year: 50);
      bool tributePaid = false;
      for (int i = 0; i < 30; i++) {
        final r2 = RandomUtils(i * 13 + 1);
        final s2 = AgentSystem(r2);
        final p2 = _makePlanet('Colony$i');
        final civ2 = _makeCiv('Empire$i');
        civ2.resources = 200;
        p2.owner = civ2;
        final pirate2 = Agent(
          location: p2,
          type: AgentType.pirate,
          fleet: 1,
          resources: 5,
          birth: 50,
          name: 'Blackbeard',
          sentientType: st,
        );
        final agents2 = [pirate2];
        final preRes = civ2.resources;
        s2.processAgents(agents2, [p2], [civ2], 55, (_) {});
        if (civ2.resources < preRes) {
          tributePaid = true;
          break;
        }
      }
      expect(tributePaid, isTrue);
    });
  });

  group('AgentSystem - processAgents handles all agent types without throwing', () {
    test('processes empty agent list', () {
      expect(
        () => system.processAgents([], [_makePlanet('X')], [], 100, (_) {}),
        returnsNormally,
      );
    });

    test('processes space monster agent', () {
      final p = _makePlanet('Wild');
      final monster = system.spawnSpaceMonster(location: p, year: 100);
      expect(
        () => system.processAgents([monster], [p], [], 101, (_) {}),
        returnsNormally,
      );
    });

    test('processes rogue AI agent', () {
      final p = _makePlanet('Station');
      final ai = system.spawnRogueAi(location: p, year: 100);
      expect(
        () => system.processAgents([ai], [p], [], 101, (_) {}),
        returnsNormally,
      );
    });

    test('processes adventurer agent', () {
      final p = _makePlanet('Colony');
      final civ = _makeCiv('Empire');
      final st = _makeType('Humans');
      civ.fullMembers.add(st);
      p.owner = civ;
      p.inhabitants.add(Population(type: st, size: 3, planet: p));
      final adv = system.spawnAdventurer(location: p, sentientType: st, originator: civ, year: 100);
      expect(
        () => system.processAgents([adv], [p], [civ], 101, (_) {}),
        returnsNormally,
      );
    });
  });

  group('AgentSystem - space monster threatens planet', () {
    test('space monster on inhabited planet logs a threat', () {
      final p = _makePlanet('Colony');
      final civ = _makeCiv('Empire');
      final st = _makeType('Humans');
      p.owner = civ;
      p.inhabitants.add(Population(type: st, size: 5, planet: p));
      final monster = system.spawnSpaceMonster(location: p, year: 100);
      final logs = <String>[];
      system.processAgents([monster], [p], [civ], 101, logs.add);
      expect(logs, isNotEmpty);
    });
  });

  group('AgentSystem - agent describe()', () {
    test('pirate describe returns orbit string', () {
      final p = _makePlanet('X');
      final st = _makeType('Humans');
      final agent = system.spawnPirate(location: p, sentientType: st, year: 0);
      expect(agent.describe(), contains('pirate'));
    });

    test('space monster describe returns threatening string', () {
      final p = _makePlanet('X');
      final agent = system.spawnSpaceMonster(location: p, year: 0);
      expect(agent.describe(), contains('threatening'));
    });

    test('rogue AI describe returns rogue AI string', () {
      final p = _makePlanet('X');
      final agent = system.spawnRogueAi(location: p, year: 0);
      expect(agent.describe(), contains('rogue AI'));
    });

    test('adventurer describe returns serving string', () {
      final p = _makePlanet('X');
      final st = _makeType('Humans');
      final civ = _makeCiv('Empire');
      final agent = system.spawnAdventurer(location: p, sentientType: st, originator: civ, year: 0);
      expect(agent.describe(), contains('adventurer'));
    });
  });
}

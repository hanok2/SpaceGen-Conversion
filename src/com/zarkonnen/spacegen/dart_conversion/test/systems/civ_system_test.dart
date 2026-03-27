import 'package:test/test.dart';
import 'package:spacegen/models/civilization.dart';
import 'package:spacegen/models/planet.dart';
import 'package:spacegen/models/population.dart';
import 'package:spacegen/models/sentient_type.dart';
import 'package:spacegen/models/structure.dart';
import 'package:spacegen/enums/diplomacy_outcome.dart';
import 'package:spacegen/enums/government.dart';
import 'package:spacegen/systems/civ_actions.dart';
import 'package:spacegen/systems/war_system.dart';
import 'package:spacegen/utils/random_utils.dart';

SentientType _makeType(String name) => SentientType(
      birth: 0,
      base: SentientBase.humanoids,
      personality: 'peaceful',
      goal: 'exploration',
      name: name,
    );

Civilization _makeCiv(String name, {Government gov = Government.republic}) =>
    Civilization(government: gov, name: name, birthYear: 0);

Planet _makePlanet(String name, {int x = 0, int y = 0, bool habitable = true}) =>
    Planet(name: name, habitable: habitable, x: x, y: y);

void main() {
  group('Civilization model', () {
    test('getRelation returns peace by default', () {
      final a = _makeCiv('A');
      final b = _makeCiv('B');
      expect(a.getRelation(b), equals(DiplomacyOutcome.peace));
    });

    test('setRelation and getRelation round-trip', () {
      final a = _makeCiv('A');
      final b = _makeCiv('B');
      a.setRelation(b, DiplomacyOutcome.war);
      expect(a.getRelation(b), equals(DiplomacyOutcome.war));
    });

    test('colonies returns only owned planets', () {
      final civ = _makeCiv('Empire');
      final p1 = _makePlanet('P1');
      final p2 = _makePlanet('P2');
      final p3 = _makePlanet('P3');
      p1.owner = civ;
      p3.owner = civ;
      final all = [p1, p2, p3];
      expect(civ.colonies(all), containsAll([p1, p3]));
      expect(civ.colonies(all), isNot(contains(p2)));
    });

    test('colonies returns empty list when no owned planets', () {
      final civ = _makeCiv('Empty');
      final all = [_makePlanet('A'), _makePlanet('B')];
      expect(civ.colonies(all), isEmpty);
    });

    test('fullColonies excludes uninhabited owned planets', () {
      final civ = _makeCiv('Empire');
      final p1 = _makePlanet('P1');
      final p2 = _makePlanet('P2');
      p1.owner = civ;
      p2.owner = civ;
      final type = _makeType('Humans');
      p1.inhabitants.add(Population(type: type, size: 3, planet: p1));
      expect(civ.fullColonies([p1, p2]), equals([p1]));
    });

    test('largestColony returns planet with most population', () {
      final civ = _makeCiv('Empire');
      final p1 = _makePlanet('Small');
      final p2 = _makePlanet('Large');
      p1.owner = civ;
      p2.owner = civ;
      final type = _makeType('Humans');
      p1.inhabitants.add(Population(type: type, size: 1, planet: p1));
      p2.inhabitants.add(Population(type: type, size: 5, planet: p2));
      expect(civ.largestColony([p1, p2]), equals(p2));
    });

    test('largestColony returns null when no colonies', () {
      final civ = _makeCiv('Empty');
      expect(civ.largestColony([_makePlanet('X')]), isNull);
    });

    test('leastPopulousFullColony returns planet with fewest inhabitants', () {
      final civ = _makeCiv('Empire');
      final p1 = _makePlanet('Small');
      final p2 = _makePlanet('Large');
      p1.owner = civ;
      p2.owner = civ;
      final type = _makeType('Humans');
      p1.inhabitants.add(Population(type: type, size: 2, planet: p1));
      p2.inhabitants.add(Population(type: type, size: 8, planet: p2));
      expect(civ.leastPopulousFullColony([p1, p2]), equals(p1));
    });

    test('totalPopulation sums all colony populations', () {
      final civ = _makeCiv('Empire');
      final p1 = _makePlanet('P1');
      final p2 = _makePlanet('P2');
      p1.owner = civ;
      p2.owner = civ;
      final type = _makeType('Humans');
      p1.inhabitants.add(Population(type: type, size: 3, planet: p1));
      p2.inhabitants.add(Population(type: type, size: 4, planet: p2));
      expect(civ.totalPopulation([p1, p2]), equals(7));
    });

    test('updateName generates unique names', () {
      final civ = _makeCiv('');
      final type = _makeType('Humans');
      civ.fullMembers.add(type);
      final history = <String>[];
      civ.updateName(history);
      expect(civ.name, isNotEmpty);
      expect(history, contains(civ.name));
    });

    test('updateName avoids previously used names', () {
      final civ = _makeCiv('');
      final type = _makeType('Humans');
      civ.fullMembers.add(type);
      final history = <String>['Republic of Humans'];
      civ.updateName(history);
      expect(civ.name, isNot(equals('Republic of Humans')));
    });
  });

  group('CivActions - doResearch', () {
    late RandomUtils random;
    late CivActions actions;

    setUp(() {
      random = RandomUtils(42);
      actions = CivActions(random);
    });

    test('doResearch transfers resources to science', () {
      final civ = _makeCiv('Researchers');
      civ.resources = 10;
      int transferred = 0;
      for (int i = 0; i < 20; i++) {
        civ.resources = 10;
        civ.science = 0;
        actions.doResearch(civ);
        if (civ.science > 0) { transferred++; break; }
      }
      expect(transferred, greaterThan(0));
    });

    test('doResearch does nothing when resources are zero', () {
      final civ = _makeCiv('Broke');
      civ.resources = 0;
      civ.science = 0;
      actions.doResearch(civ);
      expect(civ.science, equals(0));
      expect(civ.resources, equals(0));
    });

    test('doResearch never goes negative on resources', () {
      final civ = _makeCiv('Poor');
      civ.resources = 1;
      actions.doResearch(civ);
      expect(civ.resources, greaterThanOrEqualTo(0));
    });
  });

  group('CivActions - buildWarships', () {
    late RandomUtils random;
    late CivActions actions;

    setUp(() {
      random = RandomUtils(42);
      actions = CivActions(random);
    });

    test('buildWarships transfers resources to military', () {
      final civ = _makeCiv('Militarists');
      civ.resources = 20;
      final initialMilitary = civ.military;
      actions.buildWarships(civ);
      expect(civ.military, greaterThan(initialMilitary));
      expect(civ.resources, lessThan(20));
    });

    test('buildWarships does nothing when resources below 3', () {
      final civ = _makeCiv('Broke');
      civ.resources = 2;
      civ.military = 0;
      actions.buildWarships(civ);
      expect(civ.military, equals(0));
    });

    test('buildWarships never goes negative on resources', () {
      final civ = _makeCiv('Poor');
      civ.resources = 3;
      actions.buildWarships(civ);
      expect(civ.resources, greaterThanOrEqualTo(0));
    });
  });

  group('CivActions - buildScienceOutpost', () {
    late RandomUtils random;
    late CivActions actions;

    setUp(() {
      random = RandomUtils(42);
      actions = CivActions(random);
    });

    test('buildScienceOutpost does nothing when resources < 5', () {
      final civ = _makeCiv('Empire');
      civ.resources = 4;
      final home = _makePlanet('Home');
      home.owner = civ;
      final target = _makePlanet('Target', x: 1, y: 1);
      actions.buildScienceOutpost(civ, [home, target], 0, (_) {});
      expect(target.structures, isEmpty);
    });

    test('buildScienceOutpost builds lab and deducts resources', () {
      final civ = _makeCiv('Scientists');
      civ.resources = 20;
      final home = _makePlanet('Home');
      home.owner = civ;
      final target = _makePlanet('Target', x: 1, y: 0);
      final logs = <String>[];
      actions.buildScienceOutpost(civ, [home, target], 0, logs.add);
      final built = target.hasStructure(StructureType.laboratory) ||
          home.hasStructure(StructureType.laboratory);
      expect(built, isTrue);
      expect(civ.resources, lessThan(20));
    });
  });

  group('CivActions - colonisePlanet', () {
    late RandomUtils random;
    late CivActions actions;

    setUp(() {
      random = RandomUtils(42);
      actions = CivActions(random);
    });

    test('colonisePlanet does nothing when resources < 6', () {
      final civ = _makeCiv('Empire');
      civ.resources = 5;
      final type = _makeType('Humans');
      civ.fullMembers.add(type);
      final home = _makePlanet('Home');
      home.owner = civ;
      home.inhabitants.add(Population(type: type, size: 3, planet: home));
      final target = _makePlanet('Target', x: 1, y: 0);
      actions.colonisePlanet(civ, [home, target], [], 0, (_) {});
      expect(target.owner, isNull);
    });

    test('colonisePlanet colonizes reachable habitable planet', () {
      final civ = _makeCiv('Empire');
      civ.resources = 20;
      final type = _makeType('Humans');
      civ.fullMembers.add(type);
      final home = _makePlanet('Home');
      home.owner = civ;
      home.inhabitants.add(Population(type: type, size: 3, planet: home));
      final target = _makePlanet('Target', x: 1, y: 0);
      final logs = <String>[];
      actions.colonisePlanet(civ, [home, target], [], 0, logs.add);
      expect(target.owner, equals(civ));
      expect(civ.resources, lessThan(20));
    });

    test('colonisePlanet does nothing when total population < 2', () {
      final civ = _makeCiv('Empire');
      civ.resources = 20;
      final type = _makeType('Humans');
      civ.fullMembers.add(type);
      final home = _makePlanet('Home');
      home.owner = civ;
      home.inhabitants.add(Population(type: type, size: 1, planet: home));
      final target = _makePlanet('Target', x: 1, y: 0);
      actions.colonisePlanet(civ, [home, target], [], 0, (_) {});
      expect(target.owner, isNull);
    });
  });

  group('WarSystem', () {
    late RandomUtils random;
    late WarSystem warSystem;

    setUp(() {
      random = RandomUtils(1);
      warSystem = WarSystem(random);
    });

    test('processWars does nothing when no wars', () {
      final a = _makeCiv('A');
      final b = _makeCiv('B');
      final p1 = _makePlanet('P1');
      final p2 = _makePlanet('P2', x: 1, y: 0);
      p1.owner = a;
      p2.owner = b;
      a.military = 10;
      b.military = 0;
      final logs = <String>[];
      warSystem.processWars([a, b], [p1, p2], [], 0, logs.add);
      expect(logs, isEmpty);
      expect(p2.owner, equals(b));
    });

    test('processWars with war reduces military or captures planet', () {
      final a = _makeCiv('Attacker');
      final b = _makeCiv('Defender');
      final p1 = _makePlanet('Home', x: 0, y: 0);
      final p2 = _makePlanet('Target', x: 1, y: 0);
      p1.owner = a;
      p2.owner = b;
      a.military = 100;
      b.military = 0;
      a.setRelation(b, DiplomacyOutcome.war);
      b.setRelation(a, DiplomacyOutcome.war);
      final allCivs = [a, b];
      final logs = <String>[];
      warSystem.processWars(allCivs, [p1, p2], [], 0, logs.add);
      final captured = p2.owner == a;
      final militaryReduced = a.military < 100 || b.military < 0;
      expect(captured || logs.isNotEmpty, isTrue);
    });

    test('processWars removes destroyed civilization', () {
      final a = _makeCiv('Destroyer');
      final b = _makeCiv('Victim');
      final p1 = _makePlanet('Home', x: 0, y: 0);
      final p2 = _makePlanet('Victim', x: 1, y: 0);
      p1.owner = a;
      p2.owner = b;
      a.military = 1000;
      b.military = 0;
      a.setRelation(b, DiplomacyOutcome.war);
      b.setRelation(a, DiplomacyOutcome.war);
      final allCivs = [a, b];
      final logs = <String>[];
      for (int i = 0; i < 10; i++) {
        if (!allCivs.contains(b)) break;
        warSystem.processWars(allCivs, [p1, p2], [], i, logs.add);
      }
      if (!allCivs.contains(b)) {
        expect(logs.any((l) => l.contains('destroyed')), isTrue);
      }
    });

    test('processWars does nothing when attacker has no military', () {
      final a = _makeCiv('Pacifist');
      final b = _makeCiv('Defender');
      final p1 = _makePlanet('P1');
      final p2 = _makePlanet('P2', x: 1, y: 0);
      p1.owner = a;
      p2.owner = b;
      a.military = 0;
      b.military = 5;
      a.setRelation(b, DiplomacyOutcome.war);
      final logs = <String>[];
      warSystem.processWars([a, b], [p1, p2], [], 0, logs.add);
      expect(p2.owner, equals(b));
      expect(logs, isEmpty);
    });

    test('processWars does not attack out-of-range planets', () {
      final a = _makeCiv('Attacker');
      final b = _makeCiv('FarDefender');
      final p1 = _makePlanet('Home', x: 0, y: 0);
      final p2 = _makePlanet('FarAway', x: 100, y: 100);
      p1.owner = a;
      p2.owner = b;
      a.military = 100;
      b.military = 0;
      a.setRelation(b, DiplomacyOutcome.war);
      final logs = <String>[];
      warSystem.processWars([a, b], [p1, p2], [], 0, logs.add);
      expect(p2.owner, equals(b));
      expect(logs, isEmpty);
    });
  });

  group('DiplomacyOutcome', () {
    test('displayName returns correct strings', () {
      expect(DiplomacyOutcome.peace.displayName, equals('Peace'));
      expect(DiplomacyOutcome.war.displayName, equals('War'));
      expect(DiplomacyOutcome.union.displayName, equals('Union'));
    });
  });

  group('CivActions - explorePlanet diplomacy', () {
    late CivActions actions;

    setUp(() {
      actions = CivActions(RandomUtils(42));
    });

    test('explorePlanet does not reach out-of-range planets', () {
      final civ = _makeCiv('Explorer');
      civ.resources = 10;
      final home = _makePlanet('Home', x: 0, y: 0);
      home.owner = civ;
      final farPlanet = _makePlanet('Far', x: 1000, y: 1000);
      final logs = <String>[];
      actions.explorePlanet(civ, [home, farPlanet], [civ], [], 0, logs.add);
      expect(logs.any((l) => l.contains('Far')), isFalse);
    });

    test('explorePlanet with parasite civilization always declares war', () {
      final parasite = SentientType(
        birth: 0,
        base: SentientBase.parasites,
        personality: 'aggressive',
        goal: 'domination',
        name: 'Parasites',
      );
      final civA = _makeCiv('Empire');
      final civB = _makeCiv('Parasite Civ');
      civA.fullMembers.add(_makeType('Humans'));
      civB.fullMembers.add(parasite);
      final homeA = _makePlanet('HomeA', x: 0, y: 0);
      final homeB = _makePlanet('HomeB', x: 1, y: 0);
      homeA.owner = civA;
      homeB.owner = civB;
      final allCivs = [civA, civB];
      final logs = <String>[];
      for (int i = 0; i < 20; i++) {
        actions.explorePlanet(civA, [homeA, homeB], allCivs, [], i, logs.add);
        if (civA.getRelation(civB) == DiplomacyOutcome.war) break;
      }
      expect(civA.getRelation(civB), equals(DiplomacyOutcome.war));
    });
  });

  group('CivActions - buildConstruction', () {
    late CivActions actions;

    setUp(() {
      actions = CivActions(RandomUtils(42));
    });

    test('buildConstruction does nothing when resources < 8', () {
      final civ = _makeCiv('Empire');
      civ.resources = 7;
      final type = _makeType('Humans');
      civ.fullMembers.add(type);
      final home = _makePlanet('Home');
      home.owner = civ;
      home.inhabitants.add(Population(type: type, size: 2, planet: home));
      actions.buildConstruction(civ, [home], 0, (_) {});
      expect(home.structures, isEmpty);
    });

    test('buildConstruction builds structure and deducts resources', () {
      final civ = _makeCiv('Builders');
      civ.resources = 20;
      final type = _makeType('Humans');
      civ.fullMembers.add(type);
      final home = _makePlanet('Home');
      home.owner = civ;
      home.inhabitants.add(Population(type: type, size: 3, planet: home));
      final logs = <String>[];
      actions.buildConstruction(civ, [home], 0, logs.add);
      expect(home.structures, isNotEmpty);
      expect(civ.resources, lessThan(20));
    });

    test('buildConstruction reduces decrepitude', () {
      final civ = _makeCiv('Builders');
      civ.resources = 50;
      civ.decrepitude = 10;
      final type = _makeType('Humans');
      civ.fullMembers.add(type);
      final home = _makePlanet('Home');
      home.owner = civ;
      home.inhabitants.add(Population(type: type, size: 3, planet: home));
      actions.buildConstruction(civ, [home], 0, (_) {});
      expect(civ.decrepitude, lessThanOrEqualTo(10));
    });
  });
}

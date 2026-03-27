import 'package:test/test.dart';
import 'package:spacegen/models/civilization.dart';
import 'package:spacegen/models/planet.dart';
import 'package:spacegen/models/population.dart';
import 'package:spacegen/models/sentient_type.dart';
import 'package:spacegen/enums/diplomacy_outcome.dart';
import 'package:spacegen/enums/government.dart';
import 'package:spacegen/systems/war_system.dart';
import 'package:spacegen/utils/random_utils.dart';

SentientType _makeType(String name) => SentientType(
      birth: 0,
      base: SentientBase.humanoids,
      personality: 'aggressive',
      goal: 'conquest',
      name: name,
    );

Civilization _makeCiv(String name, {Government gov = Government.republic}) =>
    Civilization(government: gov, name: name, birthYear: 0);

Planet _makePlanet(String name, {int x = 0, int y = 0, bool habitable = true}) =>
    Planet(name: name, habitable: habitable, x: x, y: y);

void main() {
  group('WarSystem', () {
    test('processWars does nothing when actor has no military', () {
      final random = RandomUtils(42);
      final war = WarSystem(random);
      final a = _makeCiv('Attacker');
      final b = _makeCiv('Defender');
      a.military = 0;
      b.military = 5;
      final p = _makePlanet('Target');
      p.owner = b;
      a.setRelation(b, DiplomacyOutcome.war);
      b.setRelation(a, DiplomacyOutcome.war);
      final planets = [p];
      final civs = [a, b];
      war.processWars(civs, planets, [], 100, (_) {});
      expect(p.owner, equals(b));
    });

    test('processWars does nothing when no war relation', () {
      final random = RandomUtils(42);
      final war = WarSystem(random);
      final a = _makeCiv('Attacker');
      final b = _makeCiv('Defender');
      a.military = 10;
      b.military = 1;
      final p = _makePlanet('Target');
      p.owner = b;
      final planets = [p];
      final civs = [a, b];
      war.processWars(civs, planets, [], 100, (_) {});
      expect(p.owner, equals(b));
    });

    test('processWars does nothing when target out of range', () {
      final random = RandomUtils(42);
      final war = WarSystem(random);
      final a = _makeCiv('Attacker');
      final b = _makeCiv('Defender');
      a.military = 10;
      b.military = 1;
      final attCol = _makePlanet('Home', x: 0, y: 0);
      final defCol = _makePlanet('Target', x: 1000, y: 1000);
      attCol.owner = a;
      defCol.owner = b;
      a.setRelation(b, DiplomacyOutcome.war);
      b.setRelation(a, DiplomacyOutcome.war);
      final planets = [attCol, defCol];
      final civs = [a, b];
      war.processWars(civs, planets, [], 100, (_) {});
      expect(defCol.owner, equals(b));
    });

    test('capturePlanet transfers ownership', () {
      final random = RandomUtils(1);
      final war = WarSystem(random);
      final a = _makeCiv('Attacker');
      final b = _makeCiv('Defender');
      a.military = 50;
      b.military = 1;
      final attCol = _makePlanet('Home', x: 0, y: 0);
      final defCol = _makePlanet('Target', x: 1, y: 0);
      attCol.owner = a;
      defCol.owner = b;
      final type = _makeType('Humans');
      defCol.inhabitants.add(Population(type: type, size: 2, planet: defCol));
      a.setRelation(b, DiplomacyOutcome.war);
      b.setRelation(a, DiplomacyOutcome.war);
      final planets = [attCol, defCol];
      final civs = [a, b];
      final log = <String>[];
      war.processWars(civs, planets, [], 100, log.add);
      expect(log, isNotEmpty);
    });

    test('defender destroyed when all colonies captured', () {
      final random = RandomUtils(1);
      final war = WarSystem(random);
      final a = _makeCiv('Attacker');
      final b = _makeCiv('Defender');
      a.military = 100;
      b.military = 0;
      b.resources = 10;
      final attCol = _makePlanet('Home', x: 0, y: 0);
      final defCol = _makePlanet('Target', x: 1, y: 0);
      attCol.owner = a;
      defCol.owner = b;
      a.setRelation(b, DiplomacyOutcome.war);
      b.setRelation(a, DiplomacyOutcome.war);
      final planets = [attCol, defCol];
      final civs = [a, b];
      final log = <String>[];
      war.processWars(civs, planets, [], 100, log.add);
      expect(defCol.owner, equals(a));
      expect(civs, isNot(contains(b)));
    });

    test('resources transferred on capture', () {
      final random = RandomUtils(1);
      final war = WarSystem(random);
      final a = _makeCiv('Attacker');
      final b = _makeCiv('Defender');
      a.military = 100;
      a.resources = 10;
      b.military = 0;
      b.resources = 20;
      final attCol = _makePlanet('Home', x: 0, y: 0);
      final defCol = _makePlanet('Target', x: 1, y: 0);
      attCol.owner = a;
      defCol.owner = b;
      a.setRelation(b, DiplomacyOutcome.war);
      b.setRelation(a, DiplomacyOutcome.war);
      final planets = [attCol, defCol];
      final civs = [a, b];
      war.processWars(civs, planets, [], 100, (_) {});
      expect(a.resources, greaterThan(10));
    });
  });
}

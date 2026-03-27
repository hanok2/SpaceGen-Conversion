import 'package:test/test.dart';
import 'package:spacegen/models/civilization.dart';
import 'package:spacegen/models/planet.dart';
import 'package:spacegen/models/sentient_type.dart';
import 'package:spacegen/enums/diplomacy_outcome.dart';
import 'package:spacegen/enums/government.dart';
import 'package:spacegen/systems/diplomacy_system.dart';
import 'package:spacegen/utils/random_utils.dart';

Civilization _makeCiv(String name, {Government gov = Government.republic, SentientBase? firstMemberBase}) {
  final civ = Civilization(government: gov, name: name, birthYear: 0);
  if (firstMemberBase != null) {
    civ.fullMembers.add(SentientType(
      birth: 0,
      base: firstMemberBase,
      personality: 'test',
      goal: 'test',
      name: 'Test',
    ));
  }
  return civ;
}

Planet _makePlanet(String name) => Planet(name: name, habitable: true);

void main() {
  group('DiplomacySystem', () {
    test('meet returns war when first civ is ursoids', () {
      final random = RandomUtils(42);
      final diplo = DiplomacySystem(random);
      final a = _makeCiv('Ursoids', firstMemberBase: SentientBase.ursoids);
      final b = _makeCiv('Humans');
      expect(diplo.meet(a, b), equals(DiplomacyOutcome.war));
    });

    test('meet returns war when second civ is ursoids', () {
      final random = RandomUtils(42);
      final diplo = DiplomacySystem(random);
      final a = _makeCiv('Humans');
      final b = _makeCiv('Ursoids', firstMemberBase: SentientBase.ursoids);
      expect(diplo.meet(a, b), equals(DiplomacyOutcome.war));
    });

    test('republic vs republic can reach union', () {
      bool foundUnion = false;
      for (int seed = 0; seed < 1000; seed++) {
        final random = RandomUtils(seed);
        final diplo = DiplomacySystem(random);
        final a = _makeCiv('A', gov: Government.republic);
        final b = _makeCiv('B', gov: Government.republic);
        final outcome = diplo.meet(a, b);
        if (outcome == DiplomacyOutcome.union) {
          foundUnion = true;
          break;
        }
      }
      expect(foundUnion, isTrue);
    });

    test('republic vs republic can reach war', () {
      bool foundWar = false;
      for (int seed = 0; seed < 1000; seed++) {
        final random = RandomUtils(seed);
        final diplo = DiplomacySystem(random);
        final a = _makeCiv('A', gov: Government.republic);
        final b = _makeCiv('B', gov: Government.republic);
        final outcome = diplo.meet(a, b);
        if (outcome == DiplomacyOutcome.war) {
          foundWar = true;
          break;
        }
      }
      expect(foundWar, isTrue);
    });

    test('theocracy vs theocracy mostly war', () {
      int warCount = 0;
      for (int seed = 0; seed < 100; seed++) {
        final random = RandomUtils(seed);
        final diplo = DiplomacySystem(random);
        final a = _makeCiv('A', gov: Government.theocracy);
        final b = _makeCiv('B', gov: Government.theocracy);
        if (diplo.meet(a, b) == DiplomacyOutcome.war) warCount++;
      }
      expect(warCount, greaterThan(50));
    });

    test('meetAndRecord sets relations on both civs', () {
      final random = RandomUtils(42);
      final diplo = DiplomacySystem(random);
      final a = _makeCiv('A', gov: Government.republic);
      final b = _makeCiv('B', gov: Government.republic);
      diplo.meetAndRecord(a, b);
      expect(a.getRelation(b), equals(b.getRelation(a)));
    });

    test('outcomeDescription war continuing', () {
      final random = RandomUtils(42);
      final diplo = DiplomacySystem(random);
      final desc = diplo.outcomeDescription(DiplomacyOutcome.war, DiplomacyOutcome.war, 'Enemies');
      expect(desc, contains('Enemies'));
      expect(desc, contains('continues'));
    });

    test('outcomeDescription war declaration', () {
      final random = RandomUtils(42);
      final diplo = DiplomacySystem(random);
      final desc = diplo.outcomeDescription(DiplomacyOutcome.war, DiplomacyOutcome.peace, 'Enemies');
      expect(desc, contains('war'));
    });

    test('outcomeDescription peace treaty', () {
      final random = RandomUtils(42);
      final diplo = DiplomacySystem(random);
      final desc = diplo.outcomeDescription(DiplomacyOutcome.peace, DiplomacyOutcome.war, 'Friends');
      expect(desc, contains('peace'));
    });

    test('mergeCivs transfers planets and resources', () {
      final random = RandomUtils(42);
      final diplo = DiplomacySystem(random);
      final absorber = _makeCiv('Absorber');
      final absorbed = _makeCiv('Absorbed');
      absorber.resources = 10;
      absorbed.resources = 20;
      final p = _makePlanet('Colony');
      p.owner = absorbed;
      final civs = [absorber, absorbed];
      final planets = [p];
      diplo.mergeCivs(absorber, absorbed, civs, planets);
      expect(p.owner, equals(absorber));
      expect(absorber.resources, equals(30));
      expect(civs, isNot(contains(absorbed)));
    });

    test('mergeCivs adds full members', () {
      final random = RandomUtils(42);
      final diplo = DiplomacySystem(random);
      final absorber = _makeCiv('Absorber');
      final absorbed = _makeCiv('Absorbed');
      final st = SentientType(birth: 0, base: SentientBase.insects, personality: 'x', goal: 'y', name: 'Bugs');
      absorbed.fullMembers.add(st);
      diplo.mergeCivs(absorber, absorbed, [absorber, absorbed], []);
      expect(absorber.fullMembers, contains(st));
    });
  });
}

import '../models/civilization.dart';
import '../models/planet.dart';
import '../models/population.dart';
import '../enums/diplomacy_outcome.dart';
import '../enums/government.dart';
import '../utils/random_utils.dart';

class WarSystem {
  final RandomUtils random;

  WarSystem(this.random);

  void processWars(
    List<Civilization> allCivs,
    List<Planet> allPlanets,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    for (final actor in List<Civilization>.from(allCivs)) {
      if (!allCivs.contains(actor)) continue;
      for (final other in List<Civilization>.from(allCivs)) {
        if (!allCivs.contains(other)) continue;
        if (actor == other) continue;
        if (actor.getRelation(other) != DiplomacyOutcome.war) continue;

        _conductWarTurn(actor, other, allCivs, allPlanets, historicalCivNames, year, log);
      }
    }
  }

  void _conductWarTurn(
    Civilization attacker,
    Civilization defender,
    List<Civilization> allCivs,
    List<Planet> allPlanets,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    if (attacker.military == 0) return;

    final defCols = defender.colonies(allPlanets);
    if (defCols.isEmpty) return;

    final attCols = attacker.colonies(allPlanets);
    if (attCols.isEmpty) return;

    Planet? target;
    int closestDist = 100000;
    final range = 3 + attacker.techLevel * attacker.techLevel;

    for (final defCol in defCols) {
      for (final attCol in attCols) {
        final dist = (defCol.x - attCol.x) * (defCol.x - attCol.x) +
                     (defCol.y - attCol.y) * (defCol.y - attCol.y);
        if (dist <= range && dist < closestDist) {
          closestDist = dist;
          target = defCol;
        }
      }
    }

    if (target == null) return;

    final attackStrength = attacker.military;
    final defendStrength = defender.military + target.totalPopulation;

    if (attackStrength > defendStrength || random.coin()) {
      _bombardPlanet(attacker, defender, target, allCivs, allPlanets, historicalCivNames, year, log);
    } else {
      final losses = random.d(attackStrength ~/ 2 + 1);
      attacker.military -= losses;
      if (attacker.military < 0) attacker.military = 0;
    }
  }

  void _bombardPlanet(
    Civilization attacker,
    Civilization defender,
    Planet target,
    List<Civilization> allCivs,
    List<Planet> allPlanets,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    final bombP = attacker.government.bombardP;

    if (random.p(bombP)) {
      _capturePlanet(attacker, defender, target, allCivs, allPlanets, historicalCivNames, year, log);
    } else {
      _bombardAndCapture(attacker, defender, target, allCivs, allPlanets, historicalCivNames, year, log);
    }
  }

  void _bombardAndCapture(
    Civilization attacker,
    Civilization defender,
    Planet target,
    List<Civilization> allCivs,
    List<Planet> allPlanets,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    final defMilLost = random.d(defender.military + 1);
    defender.military -= defMilLost;
    if (defender.military < 0) defender.military = 0;

    final attMilLost = random.d(attacker.military ~/ 2 + 1);
    attacker.military -= attMilLost;
    if (attacker.military < 0) attacker.military = 0;

    if (target.totalPopulation > 0) {
      final pop = random.pick(target.inhabitants);
      pop.size -= 1;
      if (pop.size <= 0) {
        target.depopulate(pop, year, null, 'killed during bombardment by ${attacker.name}', null);
        log('The ${attacker.name} bombard ${target.name}, killing billions of ${pop.type.name}. ');
      }
    }

    if (attacker.military > defender.military) {
      _capturePlanet(attacker, defender, target, allCivs, allPlanets, historicalCivNames, year, log);
    }
  }

  void _capturePlanet(
    Civilization attacker,
    Civilization defender,
    Planet target,
    List<Civilization> allCivs,
    List<Planet> allPlanets,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    final defMilLost = random.d(defender.military + 1);
    defender.military -= defMilLost;
    if (defender.military < 0) defender.military = 0;

    final resGained = defender.resources ~/ (defender.colonies(allPlanets).length + 1);
    attacker.resources += resGained;
    defender.resources -= resGained;
    if (defender.resources < 0) defender.resources = 0;

    target.owner = attacker;
    log('The ${attacker.name} capture ${target.name} from the ${defender.name}! ');

    if (defender.colonies(allPlanets).isEmpty) {
      log('The ${defender.name} have been destroyed! ');
      allCivs.remove(defender);

      for (final pop in List<Population>.from(target.inhabitants)) {
        if (!attacker.fullMembers.contains(pop.type)) {
          if (random.coin()) {
            attacker.fullMembers.add(pop.type);
          }
        }
      }
    }
  }
}

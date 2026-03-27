import '../models/plague.dart';
import '../models/planet.dart';
import '../models/population.dart';
import '../enums/special_lifeform.dart';
import '../utils/random_utils.dart';

class PlanetEvolution {
  final RandomUtils random;

  PlanetEvolution(this.random);

  void accumulateEvolutionPoints(Planet planet) {
    planet.evolutionPoints +=
        (random.d(6)+1) * (random.d(6)+1) * (random.d(6)+1) * (random.d(6)+1) * (random.d(6)+1) *
        3 *
        (6 - planet.pollution);
  }

  bool checkEvolution(Planet planet, int currentYear, void Function(String) log) {
    if (planet.evolutionPoints <= planet.evolutionNeeded) return false;
    if (!random.p(12)) return false;
    if (planet.pollution >= 2) return false;

    planet.evolutionPoints = 0;

    if (!planet.habitable) {
      planet.habitable = true;
      log('Life arises on ${planet.name}');
      return true;
    } else {
      if (planet.inhabitants.isNotEmpty && random.coin()) {
        if (planet.owner == null) {
          return _foundCivilization(planet, currentYear, log);
        }
      } else {
        return _evolveNewLife(planet, currentYear, log);
      }
    }
    return false;
  }

  bool _foundCivilization(Planet planet, int currentYear, void Function(String) log) {
    log('Sentient life on ${planet.name} achieves spaceflight.');
    return true;
  }

  bool _evolveNewLife(Planet planet, int currentYear, void Function(String) log) {
    if (random.p(3) || planet.lifeforms.length >= 3) {
      log('Sentient life arises on ${planet.name}.');
      return true;
    } else {
      final slf = random.pick(SpecialLifeform.values);
      if (!planet.lifeforms.contains(slf)) {
        planet.addLifeform(slf);
        log('${slf.name} evolve on ${planet.name}.');
        return true;
      }
    }
    return false;
  }

  void processPopulationAndPollution(Planet planet, int currentYear, void Function(String) log) {
    if ((planet.totalPopulation > 12 ||
            (planet.totalPopulation > 7 && random.p(10))) &&
        planet.pollution < 4) {
      planet.pollution++;
    }

    for (final pop in List<Population>.from(planet.inhabitants)) {
      final roll = random.d(6);
      if (roll < planet.pollution) {
        planet.pollution--;
        if (pop.size == 1) {
          planet.depopulate(pop, currentYear, null, 'from the effects of pollution', null);
          log('${pop.type.name} have died out on ${planet.name}!');
          return;
        } else {
          pop.decrease(1);
        }
      } else {
        if (roll == 5 || (planet.owner != null && roll == 4)) {
          pop.increase(1);
        }
      }

      for (final plague in List.from(planet.plagues)) {
        if (plague.affects.contains(pop.type)) {
          if (random.d(12) < plague.lethality) {
            if (pop.size <= 1) {
              planet.depopulate(pop, currentYear, null, 'from the ${plague.name}', plague);
              log('The ${pop.type.name} on ${planet.name} have been wiped out by the ${plague.name}!');
              return;
            } else {
              pop.decrease(1);
            }
          }
        } else {
          if (random.d(12) < plague.mutationRate) {
            plague.affects.add(pop.type);
            log('The ${plague.name} mutates to affect ${pop.type.name}');
          }
        }
      }
    }
  }

  void processPlagueCureAndSpread(Planet planet, List<Planet> allPlanets, void Function(String) log) {
    for (final plague in List.from(planet.plagues)) {
      if (random.d(12) < plague.curability) {
        planet.removePlague(plague);
        log('${plague.name} has been eradicated on ${planet.name}.');
      } else {
        if (random.d(12) < plague.transmissivity) {
          final target = random.pick(allPlanets);
          bool canJump = false;
          for (final pop in target.inhabitants) {
            if (plague.affects.contains(pop.type)) {
              canJump = true;
              break;
            }
          }
          if (canJump) {
            bool match = false;
            for (final p2 in target.plagues) {
              if (p2.name == plague.name) {
                for (final st in plague.affects) {
                  if (!p2.affects.contains(st)) p2.affects.add(st);
                }
                match = true;
              }
            }
            if (!match) {
              target.addPlague(Plague.copy(plague));
            }
          }
        }
      }
    }
  }
}

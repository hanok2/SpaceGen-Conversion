import '../models/planet.dart';
import '../utils/random_utils.dart';
import 'planet_evolution.dart';
import 'planet_events.dart';

class PlanetSystem {
  final PlanetEvolution evolution;
  final PlanetEvents events;

  PlanetSystem(RandomUtils random)
      : evolution = PlanetEvolution(random),
        events = PlanetEvents(random);

  List<String> tick(Planet planet, int currentYear, List<Planet> allPlanets) {
    final logs = <String>[];

    if (events.checkCataclysm(planet, currentYear, logs.add)) {
      return logs;
    }

    events.checkPollutionAbatement(planet, logs.add);
    events.checkPlanetSpecial(planet, logs.add);

    evolution.accumulateEvolutionPoints(planet);
    evolution.checkEvolution(planet, currentYear, logs.add);

    evolution.processPopulationAndPollution(planet, currentYear, logs.add);
    evolution.processPlagueCureAndSpread(planet, allPlanets, logs.add);

    events.processErosion(planet, currentYear);

    return logs;
  }

  Map<String, List<String>> tickAll(List<Planet> planets, int currentYear) {
    final allLogs = <String, List<String>>{};
    for (final planet in planets) {
      final logs = tick(planet, currentYear, planets);
      if (logs.isNotEmpty) {
        allLogs[planet.name] = logs;
      }
    }
    return allLogs;
  }
}

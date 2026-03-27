import '../models/planet.dart';
import '../models/strata/fossil.dart';
import '../models/strata/lost_artefact.dart';
import '../models/strata/remnant.dart';
import '../models/strata/ruin.dart';
import '../enums/cataclysm.dart';
import '../enums/planet_special.dart';
import '../models/structure.dart';
import '../utils/random_utils.dart';

class PlanetEvents {
  final RandomUtils random;

  PlanetEvents(this.random);

  bool checkCataclysm(Planet planet, int currentYear, void Function(String) log) {
    if (!planet.habitable) return false;
    if (!random.p(500)) return false;

    final c = random.pick(Cataclysm.values);
    log(c.desc.replaceAll('\$name', planet.name));
    planet.extinguishLife(currentYear, c, null);
    return true;
  }

  bool checkPollutionAbatement(Planet planet, void Function(String) log) {
    if (!random.p(200)) return false;
    if (planet.pollution <= 1) return false;
    if (planet.specials.contains(PlanetSpecial.poisonWorld)) return false;

    log('Pollution on ${planet.name} abates.');
    planet.pollution--;
    return true;
  }

  bool checkPlanetSpecial(Planet planet, void Function(String) log) {
    if (!random.p(300 + 5000 * planet.specials.length)) return false;

    final ps = random.pick(PlanetSpecial.values);
    if (planet.specials.contains(ps)) return false;

    planet.specials.add(ps);
    ps.apply(planet);
    log(ps.announcement.replaceAll('\$name', planet.name));
    return true;
  }

  void processErosion(Planet planet, int currentYear) {
    for (final s in List.from(planet.strata)) {
      final sAge = currentYear - s.time + 1;
      if (sAge <= 0) continue;

      if (s is Fossil) {
        if (random.p(12000 ~/ sAge + 800)) {
          planet.strata.remove(s);
        }
      } else if (s is LostArtefact) {
        if (random.p(10000 ~/ sAge + 500)) {
          planet.strata.remove(s);
        }
      } else if (s is Remnant) {
        if (random.p(4000 ~/ sAge + 400)) {
          planet.strata.remove(s);
        }
      } else if (s is Ruin) {
        final type = s.structure.type;
        if (type == StructureType.fortress ||
            type == StructureType.mine ||
            type == StructureType.laboratory) {
          if (random.p(1000 ~/ sAge + 150)) {
            planet.strata.remove(s);
          }
        } else {
          if (random.p(3000 ~/ sAge + 300)) {
            planet.strata.remove(s);
          }
        }
      }
    }
  }
}

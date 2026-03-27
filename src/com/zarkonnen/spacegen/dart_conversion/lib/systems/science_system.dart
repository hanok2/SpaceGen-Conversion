import '../models/civilization.dart';
import '../models/planet.dart';
import '../models/population.dart';
import '../models/sentient_type.dart';
import '../models/artefact.dart';
import '../utils/random_utils.dart';

class ScienceSystem {
  final RandomUtils random;

  ScienceSystem(this.random);

  bool advance(
    Civilization actor,
    List<Civilization> allCivs,
    List<Planet> allPlanets,
    int year,
    void Function(String) log,
  ) {
    switch (random.d(9)) {
      case 0:
        actor.techLevel += 1;
        if (actor.techLevel >= 10) {
          log('The highly advanced technology of the ${actor.name} allows them to transcend the bounds of this universe. They vanish instantly.');
          for (final col in List<Planet>.from(actor.colonies(allPlanets))) {
            col.transcend(year);
          }
          allCivs.remove(actor);
          return true;
        }
        log('The ${actor.name} advance their technology to level ${actor.techLevel}.');
        break;
      case 1:
        log('The ${actor.name} develop powerful new weapons.');
        actor.weaponLevel += 1;
        break;
      case 2:
        final srcP = actor.largestColony(allPlanets);
        if (srcP != null && srcP.totalPopulation > 1) {
          for (final p in _reachables(actor, allPlanets)) {
            if (!p.habitable && p.owner == null) {
              p.habitable = true;
              Population? srcPop;
              for (final pop in srcP.inhabitants) {
                if (actor.fullMembers.contains(pop.type) && pop.size > 1) {
                  srcPop = pop;
                }
              }
              srcPop ??= random.pick(srcP.inhabitants);
              final resolvedPop = srcPop!;
              resolvedPop.size -= 1;
              final newPop = Population(type: resolvedPop.type, size: 1, planet: p);
              p.inhabitants.add(newPop);
              p.owner = actor;
              log('The ${actor.name} terraform and colonise ${p.name}.');
              return false;
            }
          }
        }
        continue colonise;
      colonise:
      case 3:
        for (final p in _reachables(actor, allPlanets)) {
          if (p.habitable && p.owner == null && p.inhabitants.isEmpty) {
            final st = SentientType(
              birth: year,
              base: SentientBase.humanoids,
              personality: 'uplifted',
              goal: 'service',
              name: '${actor.name} Clients',
            );
            p.owner = actor;
            p.inhabitants.add(Population(type: st, size: 3, planet: p));
            log('The ${actor.name} uplift the local ${st.name} on ${p.name} and incorporate the planet into their civilisation.');
            return false;
          }
        }
        continue robots;
      robots:
      case 4:
        final robotCands = <Planet>[];
        outer:
        for (final p in actor.fullColonies(allPlanets)) {
          for (final pop in p.inhabitants) {
            if (pop.type.base == SentientBase.robots) continue outer;
          }
          robotCands.add(p);
        }
        if (robotCands.isEmpty) return false;
        final rp = random.pick(robotCands);
        final rob = SentientType(
          birth: year,
          base: SentientBase.robots,
          personality: 'obedient',
          goal: 'service',
          name: '${actor.name} Robots',
        );
        log('The ${actor.name} create ${rob.name} as servants on ${rp.name}.');
        rp.inhabitants.add(Population(type: rob, size: 4, planet: rp));
        break;
      case 5:
        final target = actor.largestColony(allPlanets);
        if (target == null) return false;
        log('The ${actor.name} launch a space probe to explore the galaxy.');
        break;
      case 6:
      case 7:
      case 8:
        final candPlanets = <Planet>[];
        for (final p in actor.colonies(allPlanets)) {
          if (p.structures.any((s) => s.type.name == 'Science Lab')) {
            candPlanets.add(p);
          }
        }
        final lc = actor.largestColony(allPlanets);
        if (lc != null) candPlanets.add(lc);
        if (candPlanets.isEmpty) return false;
        final p = random.pick(candPlanets);
        final artefact = Artefact(
          created: year,
          creator: actor,
          type: ArtefactType.technology,
          description: 'Scientific breakthrough by the ${actor.name}',
          creatorTechLevel: actor.techLevel,
        );
        p.artefacts.add(artefact);
        log('The ${actor.name} develop a new technology.');
        break;
    }
    return false;
  }

  List<Planet> _reachables(Civilization actor, List<Planet> allPlanets) {
    final range = 3 + actor.techLevel * actor.techLevel;
    final result = <Planet>[];
    for (final col in actor.colonies(allPlanets)) {
      for (final p in allPlanets) {
        final dx = p.x - col.x;
        final dy = p.y - col.y;
        if (dx * dx + dy * dy <= range && !result.contains(p)) {
          result.add(p);
        }
      }
    }
    return result;
  }
}

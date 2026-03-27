import '../models/civilization.dart';
import '../models/planet.dart';
import '../models/population.dart';
import '../models/structure.dart';
import '../models/sentient_type.dart';
import '../enums/government.dart';
import '../enums/diplomacy_outcome.dart';
import '../enums/sentient_encounter_outcome.dart';
import '../enums/special_lifeform.dart';
import '../utils/random_utils.dart';

class CivActions {
  final RandomUtils random;

  CivActions(this.random);

  void explorePlanet(
    Civilization actor,
    List<Planet> allPlanets,
    List<Civilization> allCivs,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    final reachables = _reachables(actor, allPlanets);
    if (reachables.isEmpty) return;
    final p = random.pick(reachables);

    if (p.owner != null && p.owner != actor) {
      final other = p.owner!;
      log('The ${actor.name} send a delegation to ${p.name}. ');
      final prevRelation = actor.getRelation(other);
      final outcome = _diplomacyMeet(actor, other);
      log(_diplomacyDesc(outcome, other, prevRelation));

      if (outcome == DiplomacyOutcome.union &&
          (actor.fullMembers.any((m) => m.base == SentientBase.parasites) ||
           other.fullMembers.any((m) => m.base == SentientBase.parasites))) {
        actor.setRelation(other, DiplomacyOutcome.peace);
        other.setRelation(actor, DiplomacyOutcome.peace);
        return;
      }

      if (outcome == DiplomacyOutcome.union) {
        allCivs.remove(other);
        final newGovt = random.pick([actor.government, other.government]);
        for (final col in List<Planet>.from(other.colonies(allPlanets))) {
          col.owner = actor;
        }
        actor.resources += other.resources;
        actor.science += other.science;
        for (final st in other.fullMembers) {
          if (!actor.fullMembers.contains(st)) actor.fullMembers.add(st);
        }
        final newRels = <Civilization, DiplomacyOutcome>{};
        for (final c in allCivs) {
          if (c == actor || c == other) continue;
          if (actor.getRelation(c) == DiplomacyOutcome.war ||
              other.getRelation(c) == DiplomacyOutcome.war) {
            newRels[c] = DiplomacyOutcome.war;
            c.setRelation(actor, DiplomacyOutcome.war);
          } else {
            newRels[c] = DiplomacyOutcome.peace;
            c.setRelation(actor, DiplomacyOutcome.peace);
          }
        }
        actor.relations.clear();
        actor.relations.addAll(newRels);
        actor.government = newGovt;
        actor.updateName(historicalCivNames);
        log('The two civilizations combine into the ${actor.name}. ');
      } else {
        if (actor.getRelation(other) != outcome) {
          actor.setRelation(other, outcome);
          other.setRelation(actor, outcome);
        }
      }
      return;
    }

    log('The ${actor.name} explore ${p.name}. ');

    for (final slf in p.lifeforms) {
      switch (slf) {
        case SpecialLifeform.brainParasite:
          if (!random.p(3)) break;
          final victimP = random.pick(actor.colonies(allPlanets));
          final stolenRes = actor.resources ~/ actor.colonies(allPlanets).length;
          final newCiv = Civilization(
            government: random.pick(Government.values),
            name: '',
            birthYear: year,
          );
          newCiv.fullMembers.add(_makeParsiteType(year, victimP));
          newCiv.resources = stolenRes;
          newCiv.techLevel = 1;
          newCiv.updateName(historicalCivNames);
          victimP.owner = newCiv;
          allCivs.add(newCiv);
          newCiv.setRelation(actor, DiplomacyOutcome.war);
          actor.setRelation(newCiv, DiplomacyOutcome.war);
          log('The expedition encounters brain parasites. Upon their return to ${victimP.name}, the parasites take over the brains of the planet\'s inhabitants, creating the ${newCiv.name}.');
          return;

        case SpecialLifeform.pharmaceuticals:
          log('The expedition encounters plants with useful pharmaceutical properties. ');
          actor.science += 4;
          break;

        case SpecialLifeform.shapeShifter:
          if (random.p(3)) {
            final victimP = random.pick(actor.colonies(allPlanets));
            log('Shape-shifters impersonate the crew of the expedition. Upon their return to ${victimP.name} they merge into the population.');
            return;
          }
          break;

        case SpecialLifeform.ultravores:
          final victimP = random.pick(actor.colonies(allPlanets));
          if (victimP.totalPopulation < 2 || random.coin()) {
            if (random.p(10)) {
              log('The expedition captures an ultravore. The science of the ${actor.name} fashions it into a living weapon of war. ');
            }
          } else {
            log('An ultravore stows away on the expedition\'s ship. Upon their return to ${victimP.name} it escapes and multiplies.');
            return;
          }
          break;

        default:
          break;
      }
    }

    if (p.owner == null) {
      for (final pop in List<Population>.from(p.inhabitants)) {
        if (pop.type.base == SentientBase.parasites) {
          log('They remain unaware of the Deep Dweller culture far beneath. ');
          continue;
        }
        final seo = random.pick(actor.government.encounterOutcomes);
        log(_encounterDesc(seo, pop.type.name));
        switch (seo) {
          case SentientEncounterOutcome.exterminate:
            final kills = random.d(3) + 1;
            if (kills >= pop.size) {
              p.depopulate(pop, year, null, 'a campaign of extermination by ${actor.name}', null);
              log(' and wipe them out. ');
            } else {
              pop.size -= kills;
              log(', killing $kills billion.');
            }
            break;
          case SentientEncounterOutcome.exterminateFail:
            final newCiv = Civilization(
              government: Government.republic,
              name: '',
              birthYear: year,
            );
            newCiv.fullMembers.add(pop.type);
            newCiv.resources = 1;
            newCiv.techLevel = 1;
            newCiv.updateName(historicalCivNames);
            pop.size += 1;
            actor.setRelation(newCiv, DiplomacyOutcome.war);
            newCiv.setRelation(actor, DiplomacyOutcome.war);
            allCivs.add(newCiv);
            log(', but their campaign fails disastrously. The local ${pop.type.name} steal their technology and establish themselves as the ${newCiv.name}.');
            return;
          case SentientEncounterOutcome.giveFullMembership:
            if (!actor.fullMembers.contains(pop.type)) {
              actor.fullMembers.add(pop.type);
              actor.updateName(historicalCivNames);
              log(' They now call themselves the ${actor.name}.');
            }
            p.owner = actor;
            break;
          case SentientEncounterOutcome.subjugate:
            p.owner = actor;
            break;
          case SentientEncounterOutcome.ignore:
            break;
        }
        log(' ');
      }
    }

    for (int stratNum = 0; stratNum < p.strata.length; stratNum++) {
      final stratum = p.strata[p.strata.length - stratNum - 1];
      if (random.p(4 + stratNum * 2)) {
        _processStratum(stratum, p, actor, allCivs, year, log, stratNum);
      }
    }
  }

  void colonisePlanet(
    Civilization actor,
    List<Planet> allPlanets,
    List<String> historicalCivNames,
    int year,
    void Function(String) log,
  ) {
    if (actor.resources < 6) return;
    if (actor.totalPopulation(allPlanets) < 2) return;
    final srcP = actor.largestColony(allPlanets);
    if (srcP == null || srcP.totalPopulation <= 1) return;

    final reachables = _reachables(actor, allPlanets);
    for (int tries = 0; tries < 20; tries++) {
      if (reachables.isEmpty) return;
      final p = random.pick(reachables);
      if (!p.habitable) continue;
      if (p.owner != null && p.owner != actor) continue;
      if (p.owner == actor && p.totalPopulation > 0) continue;

      actor.resources -= 6;
      p.owner = actor;
      log('The ${actor.name} colonise ${p.name}. ');

      bool updNeeded = false;
      if (p.inhabitants.isNotEmpty) log('Of the natives of that planet, ');
      bool first = true;
      for (final nativeP in List<Population>.from(p.inhabitants)) {
        if (!first) log(', ');
        log('the ${nativeP.toUnenslavedString()}');
        final seo = random.pick(actor.government.encounterOutcomes);
        switch (seo) {
          case SentientEncounterOutcome.exterminate:
          case SentientEncounterOutcome.exterminateFail:
            p.depopulate(nativeP, year, null, 'through the actions of the ${actor.name}', null);
            log(' are exterminated');
            break;
          case SentientEncounterOutcome.ignore:
          case SentientEncounterOutcome.subjugate:
            log(' are enslaved');
            break;
          case SentientEncounterOutcome.giveFullMembership:
            log(' are given full membership in the ${actor.name}');
            if (!actor.fullMembers.contains(nativeP.type)) {
              actor.fullMembers.add(nativeP.type);
              updNeeded = true;
            }
            break;
        }
        first = false;
      }
      if (p.inhabitants.isNotEmpty) log('. ');
      if (updNeeded) {
        actor.updateName(historicalCivNames);
        log(' They now call themselves the ${actor.name}.');
      }

      Population? srcPop;
      for (final pop in srcP.inhabitants) {
        if (actor.fullMembers.contains(pop.type) && pop.size > 1) {
          srcPop = pop;
        }
      }
      srcPop ??= srcP.inhabitants.isNotEmpty ? random.pick(srcP.inhabitants) : null;
      if (srcPop != null) {
        srcPop.size--;
        final existing = p.inhabitants.where((pop) => pop.type == srcPop!.type);
        if (existing.isNotEmpty) {
          existing.first.size++;
        } else {
          p.inhabitants.add(Population(type: srcPop.type, size: 1, planet: p));
        }
      }
      return;
    }
  }

  void buildScienceOutpost(
    Civilization actor,
    List<Planet> allPlanets,
    int year,
    void Function(String) log,
  ) => _buildOutpost(StructureType.laboratory, actor, allPlanets, year, log);

  void buildMilitaryBase(
    Civilization actor,
    List<Planet> allPlanets,
    int year,
    void Function(String) log,
  ) => _buildOutpost(StructureType.fortress, actor, allPlanets, year, log);

  void buildMiningBase(
    Civilization actor,
    List<Planet> allPlanets,
    int year,
    void Function(String) log,
  ) => _buildOutpost(StructureType.mine, actor, allPlanets, year, log);

  void _buildOutpost(
    StructureType st,
    Civilization actor,
    List<Planet> allPlanets,
    int year,
    void Function(String) log,
  ) {
    if (actor.resources < 5) return;
    final reachables = _reachables(actor, allPlanets);
    for (int tries = 0; tries < 20; tries++) {
      if (reachables.isEmpty) return;
      final p = random.pick(reachables);
      if (p.owner != null && p.owner != actor && p.inhabitants.isNotEmpty) continue;
      if (p.hasStructure(st)) continue;
      if (p.structures.length >= 5) continue;

      if (p.owner != actor) p.owner = actor;
      actor.resources -= 5;
      p.addStructure(Structure(type: st, builders: actor, buildTime: year));
      log('The ${actor.name} build a ${st.displayName} on ${p.name}.');
      return;
    }
  }

  void buildConstruction(
    Civilization actor,
    List<Planet> allPlanets,
    int year,
    void Function(String) log,
  ) {
    if (actor.resources < 8) return;
    final colonyStructures = [
      StructureType.farm,
      StructureType.factory,
      StructureType.spaceport,
      StructureType.temple,
      StructureType.library,
      StructureType.hospital,
      StructureType.university,
    ];

    StructureType st = random.pick(colonyStructures);
    if (random.p(3) && actor.fullMembers.isNotEmpty) {
      final member = random.pick(actor.fullMembers);
      if (member.specialStructures.isNotEmpty) {
        st = random.pick(member.specialStructures);
      }
    }

    final colonies = actor.colonies(allPlanets);
    for (int tries = 0; tries < 20; tries++) {
      if (colonies.isEmpty) return;
      final p = random.pick(colonies);
      if (p.isOutpost) continue;
      if (p.hasStructure(st)) continue;
      if (p.structures.length >= 5) continue;

      if (p.owner != actor) p.owner = actor;
      actor.resources -= 8;
      p.addStructure(Structure(type: st, builders: actor, buildTime: year));
      log('The ${actor.name} build a ${st.displayName} on ${p.name}.');
      actor.decrepitude -= 3;
      if (actor.decrepitude < 0) actor.decrepitude = 0;
      return;
    }
  }

  void doResearch(Civilization actor) {
    if (actor.resources == 0) return;
    final res = actor.resources < random.d(6) ? actor.resources : random.d(6);
    actor.resources -= res;
    actor.science += res;
  }

  void buildWarships(Civilization actor) {
    if (actor.resources < 3) return;
    final res = actor.resources < random.d(6) + 2 ? actor.resources : random.d(6) + 2;
    actor.resources -= res;
    actor.military += res;
  }

  List<Planet> _reachables(Civilization actor, List<Planet> allPlanets) {
    final colonies = actor.colonies(allPlanets);
    if (colonies.isEmpty) return [];
    final range = 3 + actor.techLevel * actor.techLevel;
    return allPlanets.where((p) {
      int closestR = 100000;
      for (final c in colonies) {
        final dist = (p.x - c.x) * (p.x - c.x) + (p.y - c.y) * (p.y - c.y);
        if (dist < closestR) closestR = dist;
      }
      return closestR <= range;
    }).toList();
  }

  DiplomacyOutcome _diplomacyMeet(Civilization a, Civilization b) {
    if (a.fullMembers.any((m) => m.base == SentientBase.parasites) ||
        b.fullMembers.any((m) => m.base == SentientBase.parasites)) {
      return DiplomacyOutcome.war;
    }

    Civilization aa = a, bb = b;
    if (aa.government.index > bb.government.index) {
      final tmp = aa; aa = bb; bb = tmp;
    }

    const table = <List<List<DiplomacyOutcome>>>[
      [
        [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
        [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
        [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
        [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
      ],
      [
        [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
        [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace],
        [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
        [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
      ],
      [
        [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
        [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
        [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.union],
        [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
      ],
      [
        [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
        [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
        [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
        [DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.union],
      ],
    ];

    return random.pick(table[aa.government.index][bb.government.index]);
  }

  String _diplomacyDesc(DiplomacyOutcome outcome, Civilization encountered, DiplomacyOutcome prev) {
    switch (outcome) {
      case DiplomacyOutcome.war:
        if (prev == DiplomacyOutcome.war) return 'Peace negotiations with the ${encountered.name} are unsuccessful and their war continues.';
        return 'They declare war on the ${encountered.name}!';
      case DiplomacyOutcome.peace:
        if (prev == DiplomacyOutcome.war) return 'They sign a peace accord with the ${encountered.name}, ending their war.';
        return 'They reaffirm their peaceful relations with the ${encountered.name}.';
      case DiplomacyOutcome.union:
        if (prev == DiplomacyOutcome.war) return 'In a historical moment, they put aside their differences with the ${encountered.name}, uniting the two empires.';
        return 'In a historical moment, they agree to combine their civilization with the ${encountered.name}.';
    }
  }

  String _encounterDesc(SentientEncounterOutcome seo, String speciesName) {
    switch (seo) {
      case SentientEncounterOutcome.exterminate:
        return 'They attempt to exterminate the $speciesName';
      case SentientEncounterOutcome.exterminateFail:
        return 'They attempt to exterminate the $speciesName';
      case SentientEncounterOutcome.giveFullMembership:
        return 'They welcome the $speciesName as full members of their civilization.';
      case SentientEncounterOutcome.subjugate:
        return 'They subjugate the $speciesName.';
      case SentientEncounterOutcome.ignore:
        return 'They ignore the $speciesName.';
    }
  }

  void _processStratum(
    dynamic stratum,
    Planet p,
    Civilization actor,
    List<Civilization> allCivs,
    int year,
    void Function(String) log,
    int stratNum,
  ) {
    final type = stratum.runtimeType.toString();
    if (type == 'Fossil') {
      log('They discover: $stratum ');
      actor.science += 1;
    } else if (type == 'Remnant') {
      log('They discover: $stratum ');
      actor.resources += 1;
      actor.science += 1;
    } else if (type == 'Ruin') {
      log('They discover: $stratum ');
      actor.resources += 2;
    } else if (type == 'LostArtefact') {
      log('They recover: $stratum ');
      actor.resources += 3;
      p.strata.remove(stratum);
    }
  }

  SentientType _makeParsiteType(int year, Planet planet) {
    return SentientType(
      birth: year,
      evolvedLocation: planet,
      base: SentientBase.parasites,
      personality: 'aggressive',
      goal: 'total domination',
      name: 'Parasites',
    );
  }
}

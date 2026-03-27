import '../models/planet.dart';
import '../models/civilization.dart';
import '../models/agent.dart';
import '../models/population.dart';
import '../models/sentient_type.dart';
import '../models/strata/lost_artefact.dart';
import '../models/artefact.dart';
import '../models/structure.dart';
import '../enums/government.dart';
import '../enums/civ_action_type.dart';
import '../enums/special_lifeform.dart';
import '../enums/planet_special.dart';
import '../systems/planet_system.dart';
import '../systems/civ_actions.dart';
import '../systems/civ_events.dart';
import '../systems/war_system.dart';
import '../systems/science_system.dart';
import '../systems/agent_system.dart';
import '../utils/random_utils.dart';
import 'game_logger.dart';

class SpaceGen {
  final RandomUtils random;
  final GameLogger logger;
  late final PlanetSystem planetSystem;
  late final CivActions civActions;
  late final CivEvents civEvents;
  late final WarSystem warSystem;
  late final ScienceSystem scienceSystem;
  late final AgentSystem agentSystem;

  final List<Planet> planets = [];
  final List<Civilization> civs = [];
  final List<String> historicalCivNames = [];
  final List<Agent> agents = [];

  bool hadCivs = false;
  int year = 0;
  int age = 1;

  SpaceGen(int seed)
      : random = RandomUtils(seed),
        logger = GameLogger() {
    planetSystem = PlanetSystem(random);
    civActions = CivActions(random);
    civEvents = CivEvents(random);
    warSystem = WarSystem(random);
    scienceSystem = ScienceSystem(random);
    agentSystem = AgentSystem(random);
  }

  void init() {
    final numPlanets = 6 + random.dRolls(4, 6);
    final names = List<String>.from(Planet.planetNames);
    for (int i = 0; i < numPlanets && names.isNotEmpty; i++) {
      final nameIdx = random.nextInt(names.length);
      final name = names.removeAt(nameIdx);
      final x = random.nextInt(20);
      final y = random.nextInt(20);
      planets.add(Planet(name: name, x: x, y: y));
    }
  }

  bool interesting(int bound) {
    int pts = 0;
    pts += civs.length * 100;
    pts += year ~/ 6;
    for (final p in planets) {
      pts += p.lifeforms.length * 5;
      pts += p.specials.length * 15;
      pts += p.totalPopulation;
      for (final s in p.strata) {
        if (s is LostArtefact) {
          if (s.artefact.type == ArtefactType.wreck) pts += 20;
          if (s.artefact.type == ArtefactType.pirateHoard) pts += 15;
          if (s.artefact.type == ArtefactType.timeIce) pts += 10;
          pts += 5;
        }
      }
      pts += p.plagues.length * 15;
    }
    pts += agents.length * 25;
    return year > bound ~/ 4 && pts > bound;
  }

  void tick() {
    logger.clearTurnLog();
    year++;
    logger.setYear(year);

    if (!hadCivs && civs.isNotEmpty) {
      logger.log('WE ENTER THE ${_nth(age).toUpperCase()} AGE OF CIVILISATION');
    }
    if (hadCivs && civs.isEmpty) {
      age++;
      logger.log('WE ENTER THE ${_nth(age).toUpperCase()} AGE OF DARKNESS');
    }
    hadCivs = civs.isNotEmpty;

    for (final c in List.from(civs)) {
      if (_checkCivDoom(c)) civs.remove(c);
    }
    _tickPlanets();
    _tickCivs();
    _tickAgents();
  }

  void tickUntilSomethingHappens() {
    logger.clearTurnLog();
    while (logger.turnLog.isEmpty) {
      tick();
    }
  }

  void _tickPlanets() {
    for (final planet in List<Planet>.from(planets)) {
      final logs = planetSystem.tick(planet, year, planets);
      for (final msg in logs) {
        logger.log(msg);
      }

      if (planet.owner != null && !civs.contains(planet.owner)) {
        planet.owner = null;
      }
    }
  }

  void _dispatchCivAction(
    CivActionType action,
    Civilization c,
  ) {
    switch (action) {
      case CivActionType.explorePlanet:
        civActions.explorePlanet(c, planets, civs, historicalCivNames, year, logger.log);
        break;
      case CivActionType.colonisePlanet:
        civActions.colonisePlanet(c, planets, historicalCivNames, year, logger.log);
        break;
      case CivActionType.buildScienceOutpost:
        civActions.buildScienceOutpost(c, planets, year, logger.log);
        break;
      case CivActionType.buildMilitaryBase:
        civActions.buildMilitaryBase(c, planets, year, logger.log);
        break;
      case CivActionType.buildMiningBase:
        civActions.buildMiningBase(c, planets, year, logger.log);
        break;
      case CivActionType.doResearch:
        civActions.doResearch(c);
        break;
      case CivActionType.buildWarships:
        civActions.buildWarships(c);
        break;
      case CivActionType.buildConstruction:
        civActions.buildConstruction(c, planets, year, logger.log);
        break;
    }
  }

  bool _checkCivDoom(Civilization c) {
    final fullCols = c.fullColonies(planets);
    if (fullCols.isEmpty) {
      logger.log('The ${c.name} collapses.');
      for (final col in List<Planet>.from(c.colonies(planets))) {
        col.decivilize(year, null, 'during the collapse of the ${c.name}');
      }
      return true;
    }
    final cols = c.colonies(planets);
    if (cols.length == 1 && cols[0].totalPopulation == 1) {
      logger.log('The ${c.name} collapses, leaving only a few survivors on ${cols[0].name}.');
      cols[0].owner = null;
      return true;
    }
    return false;
  }

  int _calcResources(Civilization c) {
    int newRes = 0;
    for (final col in c.colonies(planets)) {
      if (col.totalPopulation > 7 || (col.totalPopulation > 4 && random.p(3))) {
        col.evolutionPoints = 0;
        col.pollution++;
      }

      if (random.p(6) &&
          col.totalPopulation > 4) {
        final least = c.leastPopulousFullColony(planets);
        if (least != null &&
            least != col &&
            least.totalPopulation < col.totalPopulation - 1) {
          for (final pop in col.inhabitants) {
            if (pop.size > 1) {
              pop.size--;
              final existing = least.inhabitants.where((p) => p.type == pop.type);
              if (existing.isNotEmpty) {
                existing.first.size++;
              } else {
                least.inhabitants.add(Population(type: pop.type, size: 1, planet: least));
              }
              break;
            }
          }
        }
      }

      if (col.totalPopulation == 0 && !col.isOutpost) {
        col.decivilize(year, null, '');
      } else {
        if (col.totalPopulation > 0) {
          newRes++;
          if (col.lifeforms.contains(SpecialLifeform.vastHerds)) newRes++;
        }
        if (col.specials.contains(PlanetSpecial.gemWorld)) newRes++;
        if (col.hasStructure(StructureType.mine)) newRes++;
      }
    }
    return newRes;
  }

  int _calcScience(Civilization c) {
    int newSci = 1;
    for (final col in c.colonies(planets)) {
      if (col.hasStructure(StructureType.laboratory)) newSci += 2;
      for (final pop in col.inhabitants) {
        for (final ss in pop.type.specialStructures) {
          if (col.hasStructure(ss)) newSci += 2;
        }
      }
    }
    return newSci;
  }

  void _tickCivs() {
    for (final c in List<Civilization>.from(civs)) {
      if (!civs.contains(c)) continue;
      if (_checkCivDoom(c)) { civs.remove(c); continue; }

      final newRes = _calcResources(c);
      final newSci = _calcScience(c);

      if (_checkCivDoom(c)) { civs.remove(c); continue; }

      c.resources += newRes;

      if (c.fullMembers.isNotEmpty) {
        final lead = random.pick(c.fullMembers);
        _dispatchCivAction(random.pick(lead.base.behaviour), c);
      }
      if (!civs.contains(c)) continue;
      if (_checkCivDoom(c)) { civs.remove(c); continue; }

      _dispatchCivAction(random.pick(c.government.behaviour), c);
      if (!civs.contains(c)) continue;
      if (_checkCivDoom(c)) { civs.remove(c); continue; }

      c.science += newSci;

      if (c.science > c.nextBreakthrough) {
        c.science -= c.nextBreakthrough;
        final transcended = scienceSystem.advance(c, civs, planets, year, logger.log);
        if (transcended) { civs.remove(c); continue; }
        c.nextBreakthrough = (c.nextBreakthrough * 3 ~/ 2).clamp(0, 500);
      }

      final cAge = year - c.birthYear;
      if (cAge > 5) c.decrepitude++;
      if (cAge > 15) c.decrepitude++;
      if (cAge > 25) c.decrepitude++;
      if (cAge > 40) c.decrepitude++;
      if (cAge > 60) c.decrepitude++;

      if (random.p(3)) {
        final evtTypeRoll = random.d(6);
        final bool good;
        final bool bad;

        if (c.decrepitude < 5) {
          good = evtTypeRoll <= 4;
          bad = false;
        } else if (c.decrepitude < 17) {
          good = evtTypeRoll >= 3;
          bad = evtTypeRoll == 0;
        } else if (c.decrepitude < 25) {
          good = evtTypeRoll == 5;
          bad = evtTypeRoll < 2;
        } else {
          good = evtTypeRoll == 5;
          bad = evtTypeRoll < 4;
        }

        if (good) {
          civEvents.processGoodEvent(c, planets, civs, historicalCivNames, year, logger.log);
        }
        if (!civs.contains(c)) continue;
        if (_checkCivDoom(c)) { civs.remove(c); continue; }

        if (bad) {
          civEvents.processBadEvent(c, planets, civs, historicalCivNames, year, logger.log);
        }
        if (!civs.contains(c)) continue;
        if (_checkCivDoom(c)) { civs.remove(c); continue; }
      }

      warSystem.processWars(civs, planets, historicalCivNames, year, logger.log);
    }
  }

  void _tickAgents() {
    agentSystem.processAgents(agents, planets, civs, year, logger.log);
  }

  String describe() {
    final sb = StringBuffer();

    final sentients = <SentientType>{};
    for (final p in planets) {
      for (final pop in p.inhabitants) {
        sentients.add(pop.type);
      }
    }

    if (sentients.isNotEmpty) sb.write('SENTIENT SPECIES:\n');
    for (final st in sentients) {
      sb.write('${st.name}: ${st.personality}, ${st.goal}\n');
    }

    if (civs.isNotEmpty) sb.write('\nCIVILISATIONS:\n');
    for (final c in civs) {
      sb.write('${c.name} (${c.government.typeName}): '
          '${c.colonies(planets).length} planets, '
          'res=${c.resources}, mil=${c.military}, tech=${c.techLevel}\n');
    }

    sb.write('PLANETS:\n');
    for (final p in planets) {
      sb.write('${p.name}: '
          '${p.habitable ? "habitable" : "barren"}, '
          'pop=${p.totalPopulation}, '
          'pollution=${p.pollution}');
      if (p.owner != null) sb.write(', owned by ${p.owner!.name}');
      sb.write('\n');
    }

    return sb.toString();
  }

  List<String> get fullLog => logger.fullLog;
  List<String> get turnLog => logger.turnLog;

  String _nth(int n) {
    switch (n) {
      case 1: return 'first';
      case 2: return 'second';
      case 3: return 'third';
      case 4: return 'fourth';
      case 5: return 'fifth';
      default: return '${n}th';
    }
  }
}

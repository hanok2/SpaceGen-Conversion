import '../models/agent.dart';
import '../models/planet.dart';
import '../models/civilization.dart';
import '../models/artefact.dart';
import '../models/population.dart';
import '../models/structure.dart';
import '../models/plague.dart';
import '../models/strata/lost_artefact.dart';
import '../models/strata/ruin.dart';
import '../models/sentient_type.dart';
import '../enums/special_lifeform.dart';
import '../enums/government.dart';
import '../enums/diplomacy_outcome.dart';
import '../utils/random_utils.dart';

class AgentSystem {
  final RandomUtils random;

  static const List<String> monsterTypes = ['worm', 'cube', 'crystal', 'jellyfish'];

  AgentSystem(this.random);

  void processAgents(
    List<Agent> agents,
    List<Planet> planets,
    List<Civilization> civs,
    int year,
    void Function(String) log,
  ) {
    for (final agent in List<Agent>.from(agents)) {
      if (!agents.contains(agent)) continue;
      switch (agent.type) {
        case AgentType.pirate:
          _behavePirate(agent, agents, planets, civs, year, log);
          break;
        case AgentType.adventurer:
          _behaveAdventurer(agent, agents, planets, civs, year, log);
          break;
        case AgentType.shapeShifter:
          _behaveShapeShifter(agent, agents, planets, year, log);
          break;
        case AgentType.ultravores:
          _behaveUltravores(agent, agents, planets, year, log);
          break;
        case AgentType.spaceMonster:
          _behaveSpaceMonster(agent, agents, planets, year, log);
          break;
        case AgentType.spaceProbe:
          _behaveSpaceProbe(agent, agents, planets, civs, year, log);
          break;
        case AgentType.rogueAi:
          _behaveRogueAi(agent, agents, planets, civs, year, log);
          break;
      }
    }
  }

  void _behavePirate(
    Agent a,
    List<Agent> agents,
    List<Planet> planets,
    List<Civilization> civs,
    int year,
    void Function(String) log,
  ) {
    a.location = random.pick(planets);
    final age = year - a.birth;
    if (age > 8 + random.d(6)) {
      log('The pirate ${a.name} dies and is buried on ${a.location!.name}.');
      final art = Artefact(
        created: year,
        type: ArtefactType.pirateTomb,
        description: 'Tomb of the Pirate ${a.name}',
        specialValue: a.resources + a.fleet,
      );
      a.location!.strata.add(LostArtefact(status: 'buried', lostTime: year, artefact: art));
      a.location = null;
      agents.remove(a);
      return;
    }

    final loc = a.location!;
    if (loc.owner != null) {
      final tribute = random.d(8) + 1;
      if (loc.owner!.resources >= tribute && !random.p(4)) {
        loc.owner!.resources -= tribute;
        a.resources += tribute;
        log('The pirate ${a.name} receives tribute from ${loc.name} of the ${loc.owner!.name}.');
      } else {
        final attack = a.fleet * 4;
        final defence = loc.totalPopulation +
            (loc.hasStructure(StructureType.fortress)
                ? 5 * (loc.owner!.techLevel + 2 * loc.owner!.weaponLevel)
                : 0);
        final attackRoll = random.dRolls(attack > 0 ? attack : 1, 6);
        final defenceRoll = random.dRolls(defence > 0 ? defence : 1, 6);
        if (attackRoll > defenceRoll) {
          int deaths = 0;
          for (final pop in List<Population>.from(loc.inhabitants)) {
            final pd = random.d(pop.size > 0 ? pop.size : 1) + 1;
            if (pd >= pop.size) {
              loc.depopulate(pop, year, null, 'due to orbital bombardment by the pirate ${a.name}', null);
            } else {
              pop.size -= pd;
            }
            deaths += pd;
          }
          if (loc.totalPopulation == 0) {
            loc.decivilize(year, null, 'due to orbital bombardment by the pirate ${a.name}');
            log('The pirate ${a.name} subjects ${loc.name} to orbital bombardment.');
          } else {
            for (final st in List<Structure>.from(loc.structures)) {
              if (random.coin()) {
                loc.strata.add(Ruin(
                  structure: st,
                  ruinTime: year,
                  reason: 'through orbital bombardment by the pirate ${a.name}',
                ));
                loc.removeStructure(st);
              }
            }
            log('The pirate ${a.name} subjects ${loc.name} to orbital bombardment, killing $deaths billion.');
          }
        } else {
          log('The ${loc.owner!.name} defeat the pirate ${a.name}.');
          loc.owner!.resources += a.resources ~/ 2;
          loc.owner!.military = loc.owner!.military * 5 ~/ 6;
          a.location = null;
          agents.remove(a);
        }
      }
    } else {
      if (a.resources > 5) {
        if (random.p(3)) {
          log('The pirate ${a.name} buries a hoard of treasure on ${loc.name}.');
          final art = Artefact(
            created: year,
            type: ArtefactType.pirateHoard,
            description: 'Hoard of the Pirate ${a.name}',
            specialValue: a.resources - 2,
          );
          a.resources = 2;
          loc.strata.add(LostArtefact(status: 'buried', lostTime: year, artefact: art));
        } else {
          a.fleet++;
          a.resources -= 2;
        }
      }
    }
  }

  bool _adventurerEncounter(
    Agent a,
    Agent ag,
    List<Agent> agents,
    int year,
    void Function(String) log,
  ) {
    switch (ag.type) {
      case AgentType.rogueAi:
        if (random.coin()) {
          if (a.fleet <= 3) {
            log('${a.name} is killed by the rogue AI ${ag.name}.');
            agents.remove(a);
            a.location!.strata.add(LostArtefact(
              status: 'crashed',
              lostTime: year,
              artefact: Artefact(
                created: year,
                creator: a.originator,
                type: ArtefactType.wreck,
                description: 'wreck of the flagship of ${a.name}, destroyed by the rogue AI ${ag.name}',
              ),
            ));
            a.location = null;
          } else {
            final loss = random.d(a.fleet - 1) + 1;
            log('${a.name} is attacked by the rogue AI ${ag.name} and has to retreat, losing $loss ships.');
            a.fleet -= loss;
            a.location!.strata.add(LostArtefact(
              status: 'crashed',
              lostTime: year,
              artefact: Artefact(
                created: year,
                creator: a.originator,
                type: ArtefactType.wreck,
                description: 'shattered wrecks of $loss spaceships of the fleet of ${a.name}, destroyed by the rogue AI ${ag.name}',
              ),
            ));
          }
        } else {
          log('${a.name} manages to confuse the rogue AI ${ag.name} with a clever logic puzzle, distracting it long enough to shut it down.');
          a.resources += 5;
          agents.remove(ag);
          ag.location = null;
        }
        return true;
      case AgentType.spaceProbe:
        if (random.coin()) {
          log('${a.name} attempts to reason with the space probe ${ag.name} but triggers its self-destruct mechanism.');
          if (random.coin()) {
            a.location!.extinguishLife(year, null, 'due to the self-destruction of the insane space probe ${ag.name}');
            log('The resulting shockwave exterminates all life on ${a.location!.name}.');
            agents.remove(a);
            a.location = null;
          }
          agents.remove(ag);
          ag.location = null;
        } else {
          log('${a.name} successfully reasons with the insane space probe ${ag.name}, which transfers its accumulated information into the fleet\'s data banks and then shuts down.');
          if (a.originator != null) a.originator!.techLevel += 3;
          agents.remove(ag);
          ag.location = null;
        }
        return true;
      case AgentType.spaceMonster:
        final attackRoll = random.dRolls(a.fleet > 0 ? a.fleet : 1, 6);
        final defenseRoll = random.dRolls(4, 6);
        if (attackRoll > defenseRoll) {
          log('${a.name} defeats the ${ag.name} in orbit around ${a.location!.name}.');
          agents.remove(ag);
          ag.location = null;
          if (a.location!.owner != null) {
            log('The ${a.location!.owner!.name} rewards the adventurer handsomely.');
            a.resources += a.location!.owner!.resources ~/ 3;
            a.location!.owner!.resources = a.location!.owner!.resources * 2 ~/ 3;
          }
        } else {
          final loss = random.d(2) + 2;
          if (a.fleet - loss <= 0) {
            log('The ${ag.name} in orbit around ${a.location!.name} attacks and kills ${a.name}.');
            agents.remove(a);
            a.location!.strata.add(LostArtefact(
              status: 'crashed',
              lostTime: year,
              artefact: Artefact(
                created: year,
                creator: a.originator,
                type: ArtefactType.wreck,
                description: 'wreck of the flagship of ${a.name}, destroyed by a ${ag.name}',
              ),
            ));
            a.location = null;
          } else {
            a.fleet -= loss;
            log('The ${ag.name} attacks the fleet of ${a.name} near ${a.location!.name} destroying $loss ships.');
            a.location!.strata.add(LostArtefact(
              status: 'crashed',
              lostTime: year,
              artefact: Artefact(
                created: year,
                creator: a.originator,
                type: ArtefactType.wreck,
                description: 'shattered wrecks of $loss spaceships of the fleet of ${a.name}, destroyed by a ${ag.name}',
              ),
            ));
          }
        }
        return true;
      default:
        return false;
    }
  }

  void _behaveAdventurer(
    Agent a,
    List<Agent> agents,
    List<Planet> planets,
    List<Civilization> civs,
    int year,
    void Function(String) log,
  ) {
    a.location = random.pick(planets);
    final age = year - a.birth;
    if (a.originator == null || !civs.contains(a.originator) || age > 8 + random.d(6)) {
      log('The space adventurer ${a.name} dies and is buried on ${a.location!.name}.');
      final art = Artefact(
        created: year,
        type: ArtefactType.adventurerTomb,
        description: 'Tomb of ${a.name}',
        specialValue: a.resources ~/ 3 + a.fleet ~/ 5 + 1,
      );
      a.location!.strata.add(LostArtefact(status: 'buried', lostTime: year, artefact: art));
      agents.remove(a);
      a.location = null;
      return;
    }

    for (final ag in List<Agent>.from(agents)) {
      if (ag != a && ag.location == a.location) {
        if (_adventurerEncounter(a, ag, agents, year, log)) return;
      }
    }

    final loc = a.location!;

    if (random.p(3) &&
        loc.owner != null &&
        loc.owner != a.originator &&
        a.originator!.getRelation(loc.owner!) == DiplomacyOutcome.war) {
      final acts = [
        ' raids the treasury on ',
        ' intercepts a convoy near ',
        ' steals jewels from ',
        ' steals a spaceship from the navy of ',
        ' extorts money from ',
      ];
      final act = random.pick(acts);
      log('${a.name}$act${loc.name}, a planet of the enemy ${loc.owner!.name}.');
      a.resources += 2;
      loc.owner!.resources = loc.owner!.resources * 5 ~/ 6;
      return;
    }

    if (loc.owner == null ||
        (loc.owner != a.originator && a.originator!.getRelation(loc.owner!) == DiplomacyOutcome.peace)) {
      final rep = StringBuffer();
      bool major = false;
      rep.write('An expedition led by ${a.name} explores ${loc.name}. ');

      bool runAway = false;
      for (final slf in List<SpecialLifeform>.from(loc.lifeforms)) {
        if (random.coin()) continue;
        if (slf == SpecialLifeform.brainParasite ||
            slf == SpecialLifeform.ultravores ||
            slf == SpecialLifeform.shapeShifter) {
          final monster = slf.name.toLowerCase();
          major = true;
          rep.write('They encounter the local $monster');
          if (random.p(3)) {
            rep.write(' and exterminate them. ');
            loc.removeLifeform(slf);
          } else {
            if (a.fleet < 1) {
              rep.write('. In a desperate attempt to stop them, ${a.name} activates the ship\'s self-destruct sequence.');
              runAway = true;
              agents.remove(a);
              a.location = null;
              break;
            } else {
              rep.write('. In a desperate attempt to stop them, ${a.name} has half of the exploration fleet blasted to bits.');
              runAway = true;
              a.fleet ~/= 2;
              break;
            }
          }
        }
      }

      if (runAway) {
        log(rep.toString());
        return;
      }

      if (loc.inhabitants.isNotEmpty) {
        major = true;
        rep.write('They trade with the local ${random.pick(loc.inhabitants).type.name}. ');
        loc.evolutionPoints += 5000;
        a.resources += 2;
      }

      for (int stratNum = 0; stratNum < loc.strata.length; stratNum++) {
        final stratum = loc.strata[loc.strata.length - stratNum - 1];
        if (random.p(4 + stratNum * 2)) {
          if (stratum is LostArtefact) {
            final la = stratum;
            if (la.artefact.type == ArtefactType.pirateTomb ||
                la.artefact.type == ArtefactType.pirateHoard ||
                la.artefact.type == ArtefactType.adventurerTomb) {
              rep.write('The expedition loots the ${la.artefact.description}. ');
              a.resources += la.artefact.specialValue;
              loc.strata.remove(stratum);
              stratNum--;
              continue;
            }
            if (la.artefact.type == ArtefactType.stasisCapsule) {
              if (la.artefact.creator != null && !civs.contains(la.artefact.creator)) {
                rep.write('They open a stasis capsule from the ${la.artefact.creator!.name}, which arises once more!');
                civs.add(la.artefact.creator!);
                la.artefact.creator!.techLevel = la.artefact.creatorTechLevel;
                la.artefact.creator!.resources = 10;
                la.artefact.creator!.military = 10;
                if (loc.owner != null) {
                  loc.owner!.setRelation(la.artefact.creator!, DiplomacyOutcome.war);
                  la.artefact.creator!.setRelation(loc.owner!, DiplomacyOutcome.war);
                }
                loc.owner = la.artefact.creator;
                loc.strata.remove(stratum);
                stratNum--;
              }
              continue;
            }
            if (la.artefact.type == ArtefactType.mindArchive) {
              rep.write('They encounter a mind archive of the ${la.artefact.creator?.name ?? 'unknown'} which brings new knowledge and wisdom to the ${a.originator!.name}. ');
              major = true;
              a.originator!.techLevel = a.originator!.techLevel > la.artefact.creatorTechLevel
                  ? a.originator!.techLevel
                  : la.artefact.creatorTechLevel;
              continue;
            }
            if (la.artefact.type == ArtefactType.wreck) {
              rep.write('They recover: $stratum ');
              loc.strata.remove(stratum);
              a.resources += 3;
              stratNum--;
              continue;
            }
            rep.write('They recover: $stratum ');
            major = true;
            loc.strata.remove(stratum);
            a.resources++;
            final destColonies = a.originator!.fullColonies(planets);
            if (destColonies.isNotEmpty) {
              random.pick(destColonies).addArtefact(la.artefact);
            }
            stratNum--;
          }
        }
      }

      if (rep.length > 0 && major) {
        log(rep.toString());
      }
      return;
    }

    if (loc.owner == a.originator) {
      while (a.resources > 4) {
        a.fleet++;
        a.resources -= 4;
      }

      Agent? pir;
      outer:
      for (final p in planets) {
        for (final ag in agents) {
          if (ag.type == AgentType.pirate && ag.location == p) {
            pir = ag;
            break outer;
          }
        }
      }
      if (pir != null) {
        log('${a.name} is sent on a mission to defeat the pirate ${pir.name} by the government of ${loc.name}.');
        if (random.coin()) {
          log('${a.name} fails to find any trace of the pirate ${pir.name}.');
          return;
        }
        a.location = pir.location;
        log('${a.name} tracks down the pirate ${pir.name} in orbit around ${pir.location?.name ?? 'unknown'}.');
        final attack = a.fleet * 4;
        final defence = pir.fleet * 3;
        final attackRoll = random.dRolls(attack > 0 ? attack : 1, 6);
        final defenceRoll = random.dRolls(defence > 0 ? defence : 1, 6);
        if (attackRoll > defenceRoll) {
          log('${a.name} defeats the pirate ${pir.name} - the skies of ${a.location?.name ?? 'unknown'} are safe again.');
          agents.remove(pir);
          pir.location = null;
          a.resources += pir.resources ~/ 2;
          a.originator!.resources += pir.resources ~/ 2;
        } else {
          if (a.fleet < 2) {
            log('${a.name} is defeated utterly by the pirate.');
            agents.remove(a);
            a.location = null;
          } else {
            log('${a.name} is defeated by the pirate ${pir.name} and flees back to ${loc.name}.');
            a.fleet ~/= 2;
          }
        }
        return;
      }

      Agent? mon;
      outer:
      for (final p in planets) {
        for (final ag in agents) {
          if (ag.type == AgentType.spaceMonster && ag.location == p) {
            mon = ag;
            break outer;
          }
        }
      }
      if (mon != null) {
        log('${a.name} is sent on a mission to defeat the ${mon.name} at ${mon.location?.name ?? 'unknown'}.');
        a.location = mon.location;
        _adventurerEncounter(a, mon, agents, year, log);
        return;
      }

      Agent? ai;
      outer:
      for (final p in planets) {
        for (final ag in agents) {
          if (ag.type == AgentType.rogueAi && ag.location == p) {
            ai = ag;
            break outer;
          }
        }
      }
      if (ai != null) {
        log('${a.name} is sent on a mission to stop the rogue AI ${ai.name} at ${ai.location?.name ?? 'unknown'}.');
        a.location = ai.location;
        _adventurerEncounter(a, ai, agents, year, log);
        return;
      }

      Agent? pr;
      outer:
      for (final p in planets) {
        for (final ag in agents) {
          if (ag.type == AgentType.spaceProbe && ag.location == p) {
            pr = ag;
            break outer;
          }
        }
      }
      if (pr != null) {
        log('${a.name} is sent on a mission to stop the insane space probe ${pr.name} threatening ${pr.location?.name ?? 'unknown'}.');
        a.location = pr.location;
        _adventurerEncounter(a, pr, agents, year, log);
        return;
      }

      Civilization? enemy;
      for (final c in civs) {
        if (c != a.originator && a.originator!.getRelation(c) == DiplomacyOutcome.war) {
          enemy = c;
          break;
        }
      }
      if (enemy != null && random.p(4)) {
        log('The ${a.originator!.name} send ${a.name} on a mission of peace to the ${enemy.name}.');
        final enemyColony = enemy.largestColony(planets);
        if (enemyColony != null) a.location = enemyColony;
        if (random.coin()) {
          log('The expert diplomacy of ${a.name} is successful: the two empires are at peace.');
          a.originator!.setRelation(enemy, DiplomacyOutcome.peace);
          enemy.setRelation(a.originator!, DiplomacyOutcome.peace);
        } else {
          final home = a.originator!.largestColony(planets);
          if (home != null) a.location = home;
          log('Unfortunately, the peace mission fails. ${a.name} hastily retreats to ${a.location?.name ?? 'unknown'}.');
        }
        return;
      }

      if (enemy != null) {
        for (final p in enemy.colonies(planets)) {
          if (p.artefacts.isNotEmpty) {
            final art = p.artefacts[0];
            log('The ${a.originator!.name} send ${a.name} on a mission to steal the ${art.type.displayName} on ${p.name}.');
            a.location = p;
            if (random.coin()) {
              final lc = a.originator!.largestColony(planets);
              if (lc != null) {
                log('${a.name} successfully acquires the ${art.type.displayName} and delivers it to ${lc.name}.');
                p.removeArtefact(art);
                lc.addArtefact(art);
              }
            } else {
              if (random.p(3)) {
                log('The ${enemy.name} capture and execute ${a.name} for trying to steal the ${art.type.displayName}.');
                agents.remove(a);
                a.location = null;
              } else {
                final home = a.originator!.largestColony(planets);
                if (home != null) a.location = home;
                log('The attempt to steal the ${art.type.displayName} fails, and ${a.name} swiftly retreats to ${a.location?.name ?? 'unknown'} to avoid capture.');
              }
            }
            return;
          }
        }
      }
    }
  }

  void _behaveShapeShifter(
    Agent a,
    List<Agent> agents,
    List<Planet> planets,
    int year,
    void Function(String) log,
  ) {
    if (a.location == null || a.location!.inhabitants.isEmpty) {
      agents.remove(a);
      a.location = null;
      return;
    }
    final loc = a.location!;
    if (loc.totalPopulation > 1) {
      if (random.p(6)) {
        final victim = random.pick(loc.inhabitants);
        if (victim.size == 1) {
          log('Shape-shifters devour the last remaining ${victim.type.name} on ${loc.name}.');
          loc.depopulate(victim, year, null, 'through predation by shape-shifters', null);
        } else {
          victim.size--;
        }
      }
      if (random.p(40)) {
        log('The inhabitants of ${loc.name} manage to identify the shape-shifters among them and exterminate them.');
        agents.remove(a);
        a.location = null;
      }
    } else {
      log('The population of ${loc.name} turn out to be all shape-shifters. The colony collapses as the shape-shifters need real sentients to keep up their mimicry.');
      loc.decivilize(year, null, 'when the entire population of the planet turned out to be shape-shifters');
      if (!loc.lifeforms.contains(SpecialLifeform.shapeShifter)) {
        loc.addLifeform(SpecialLifeform.shapeShifter);
      }
      agents.remove(a);
      a.location = null;
    }
  }

  void _behaveUltravores(
    Agent a,
    List<Agent> agents,
    List<Planet> planets,
    int year,
    void Function(String) log,
  ) {
    if (a.location == null || a.location!.inhabitants.isEmpty || a.location!.owner == null) {
      agents.remove(a);
      a.location = null;
      return;
    }
    final loc = a.location!;
    if (random.p(6)) {
      if (loc.totalPopulation > 1) {
        final victim = random.pick(loc.inhabitants);
        if (victim.size == 1) {
          log('A billion ${victim.type.name} on ${loc.name} are devoured by ultravores.');
          loc.depopulate(victim, year, null, 'through predation by ultravores', null);
        } else {
          victim.size--;
        }
      } else {
        log('Ultravores devour the final inhabitants of ${loc.name}.');
        loc.decivilize(year, null, 'through predation by ultravores');
      }

      if (random.p(3) && loc.owner != null) {
        for (final p in loc.owner!.fullColonies(planets)) {
          final alreadyThere = agents.any((ag) => ag.type == AgentType.ultravores && ag.location == p);
          if (!alreadyThere) {
            final newAgent = Agent(
              type: AgentType.ultravores,
              birth: year,
              name: 'Hunting pack of Ultravores',
              location: p,
            );
            agents.add(newAgent);
            break;
          }
        }
      }
    }
  }

  void _behaveSpaceMonster(
    Agent a,
    List<Agent> agents,
    List<Planet> planets,
    int year,
    void Function(String) log,
  ) {
    if (a.location == null) return;
    final loc = a.location!;
    if (loc.totalPopulation > 0) {
      log('The ${a.name} threatens ${loc.name}.');
    }
    if (random.p(500)) {
      log('The ${a.name} devours all life on ${loc.name}.');
      loc.extinguishLife(year, null, 'due to the attack of a ${a.name}');
      return;
    }
    if (random.p(8) && loc.totalPopulation > 2) {
      final t = random.pick(loc.inhabitants);
      if (t.size == 1) {
        log('The ${a.name} devours the last of the local ${t.type.name} on ${loc.name}.');
        loc.depopulate(t, year, null, 'due to predation by a ${a.name}', null);
      } else {
        log('The ${a.name} devours one billion ${t.type.name} on ${loc.name}.');
        t.size--;
      }
      return;
    }
    if (random.p(20)) {
      log('The ${a.name} leaves the orbit of ${loc.name} and heads back into deep space.');
      agents.remove(a);
      a.location = null;
    }
  }

  void _behaveSpaceProbe(
    Agent a,
    List<Agent> agents,
    List<Planet> planets,
    List<Civilization> civs,
    int year,
    void Function(String) log,
  ) {
    if (a.location == null) {
      a.timer--;
      if (a.timer == 0) {
        a.location = a.target;
        if (a.location != null) {
          log('The space probe ${a.name} returns to ${a.location!.name}.');
          if (a.originator != null && a.location!.owner == a.originator) {
            log('The ${a.originator!.name} gains a wealth of new knowledge as a result.');
            a.originator!.techLevel += 3;
            agents.remove(a);
            a.location = null;
            return;
          } else {
            log('Unable to contact the ${a.originator?.name ?? 'unknown'} that launched it, the probe goes insane.');
          }
        }
      }
      return;
    }
    final loc = a.location!;
    if (random.p(8) && loc.totalPopulation > 2) {
      final t = random.pick(loc.inhabitants);
      if (t.size == 1) {
        log('The insane space probe ${a.name} bombards ${loc.name}, wiping out the local ${t.type.name}.');
        loc.depopulate(t, year, null, 'due to bombardment by the insane space probe ${a.name}', null);
      } else {
        log('The insane space probe ${a.name} bombards ${loc.name}, killing one billion ${t.type.name}.');
        t.size--;
      }
      return;
    }
    if (random.p(40)) {
      log('The insane space probe ${a.name} crashes into ${loc.name}, wiping out all life on the planet.');
      loc.extinguishLife(year, null, 'due to the impact of the space probe ${a.name}');
      agents.remove(a);
      a.location = null;
    }
  }

  void _behaveRogueAi(
    Agent a,
    List<Agent> agents,
    List<Planet> planets,
    List<Civilization> civs,
    int year,
    void Function(String) log,
  ) {
    if (a.timer > 0) {
      a.timer--;
      if (a.timer == 0) {
        a.location = random.pick(planets);
        log('The rogue AI ${a.name} reappears on ${a.location!.name}.');
      }
      return;
    }
    if (random.p(10)) {
      a.location = random.pick(planets);
    }
    if (a.location == null) return;
    if (random.p(50)) {
      log('The rogue AI ${a.name} vanishes without a trace.');
      a.timer = 40 + random.d(500);
      a.location = null;
      return;
    }
    if (random.p(80)) {
      log('The rogue AI ${a.name} vanishes without a trace.');
      agents.remove(a);
      a.location = null;
      return;
    }

    if (random.p(40)) {
      for (final ag in List<Agent>.from(agents)) {
        if (ag == a) continue;
        if (ag.location != a.location) continue;
        Artefact? art;
        switch (ag.type) {
          case AgentType.adventurer:
            log('The rogue AI ${a.name} encases the adventurer ${ag.name} in a block of time ice.');
            art = Artefact.withCreatorName(
              created: year,
              creatorName: 'the rogue AI ${a.name}',
              type: ArtefactType.timeIce,
              description: 'block of time ice encasing ${ag.name}',
            );
            break;
          case AgentType.pirate:
            log('The rogue AI ${a.name} encases the pirate ${ag.name} in a block of time ice.');
            art = Artefact.withCreatorName(
              created: year,
              creatorName: 'the rogue AI ${a.name}',
              type: ArtefactType.timeIce,
              description: 'block of time ice encasing the pirate ${ag.name}',
            );
            break;
          case AgentType.shapeShifter:
            log('The rogue AI ${a.name} encases the shape-shifters on ${a.location!.name} in a block of time ice.');
            art = Artefact.withCreatorName(
              created: year,
              creatorName: 'the rogue AI ${a.name}',
              type: ArtefactType.timeIce,
              description: 'block of time ice, encasing a group of shape-shifters',
            );
            break;
          case AgentType.ultravores:
            log('The rogue AI ${a.name} encases a pack of ultravores on ${a.location!.name} in a block of time ice.');
            art = Artefact.withCreatorName(
              created: year,
              creatorName: 'the rogue AI ${a.name}',
              type: ArtefactType.timeIce,
              description: 'block of time ice, encasing a pack of ultravores',
            );
            break;
          case AgentType.rogueAi:
            final newName = 'Cluster ${random.nextInt(100)}';
            log('The rogue AI ${a.name} merges with the rogue AI ${ag.name} into a new entity called $newName.');
            a.name = newName;
            agents.remove(ag);
            a.location = null;
            return;
          default:
            break;
        }
        if (art != null) {
          art.containedAgent = ag;
          a.location!.addArtefact(art);
          agents.remove(ag);
          a.location = null;
          return;
        }
      }
    }

    final loc = a.location!;
    if (loc.owner != null) {
      if (random.p(60)) {
        if (loc.owner!.fullMembers.isNotEmpty) {
          final st = random.pick(loc.owner!.fullMembers);
          String title;
          final gov = loc.owner!.government;
          if (gov == Government.dictatorship) {
            title = 'Emperor';
          } else if (gov == Government.feudalState) {
            title = 'King';
          } else if (gov == Government.republic) {
            title = 'President';
          } else if (gov == Government.theocracy) {
            title = 'Autarch';
          } else {
            title = 'Leader';
          }
          final victimName = '${random.pick(['Al', 'Vel', 'Zor', 'Kra', 'Tor'])}${random.pick(['ax', 'on', 'us', 'ix', 'en'])}';
          final ar = Artefact.withCreatorName(
            created: year,
            creatorName: 'the rogue AI ${a.name}',
            type: ArtefactType.timeIce,
            description: 'block of time ice, encasing $victimName, $title of the ${loc.owner!.name}',
          );
          ar.containedSentientType = st;
          loc.addArtefact(ar);
          log('The rogue AI ${a.name} encases $victimName, $title of the ${loc.owner!.name}, in a block of time ice.');
          return;
        }
      }
      if (random.p(60)) {
        log('The rogue AI ${a.name} crashes the ${loc.name} stock exchange.');
        loc.owner!.resources ~/= 2;
        return;
      }
      if (random.p(20) && loc.artefacts.isNotEmpty) {
        final art = random.pick(loc.artefacts);
        final t = random.pick(planets);
        log('The rogue AI ${a.name} steals the ${art.description} on ${loc.name} and hides it on ${t.name}.');
        loc.removeArtefact(art);
        t.strata.add(LostArtefact(status: 'hidden', lostTime: year, artefact: art));
        return;
      }
    }

    if (loc.inhabitants.isNotEmpty) {
      if (random.p(40)) {
        final plague = Plague(
          name: 'AI Plague',
          lethality: random.d(6) + 1,
          mutationRate: random.d(4) + 1,
          transmissivity: random.d(6) + 1,
          curability: random.d(4) + 1,
          color: 'red',
        );
        plague.affects.add(loc.inhabitants[0].type);
        for (int i = 1; i < loc.inhabitants.length; i++) {
          if (random.coin()) plague.affects.add(loc.inhabitants[i].type);
        }
        loc.addPlague(plague);
        log('The rogue AI ${a.name} infects the inhabitants of ${loc.name} with ${plague.description}.');
        return;
      }
      if (loc.totalPopulation > 2 && random.p(25)) {
        for (final t in planets) {
          if (t.habitable && t.owner == null) {
            final victim = random.pick(loc.inhabitants);
            if (victim.size > 1) {
              victim.size--;
              t.inhabitants.add(Population(type: victim.type, size: 1, planet: t));
            }
            log('The rogue AI ${a.name} abducts a billion ${victim.type.name} from ${loc.name} and dumps them on ${t.name}.');
            return;
          }
        }
      }
    }

    if (loc.habitable && random.p(200) && loc.owner == null) {
      log('The rogue AI ${a.name} terraforms ${loc.name}.');
      return;
    }

    if (loc.habitable && random.p(300)) {
      log('The rogue AI ${a.name} releases nanospores on ${loc.name}, destroying all life on the planet.');
      loc.extinguishLife(year, null, 'due to nanospores released by ${a.name}');
      return;
    }

    if (civs.length > 1 && random.p(250)) {
      final c = random.pick(civs);
      final others = civs.where((x) => x != c).toList();
      if (others.isEmpty) return;
      final c2 = random.pick(others);
      if (c.getRelation(c2) == DiplomacyOutcome.peace) {
        log('The rogue AI ${a.name} incites war between the ${c.name} and the ${c2.name}.');
        c.setRelation(c2, DiplomacyOutcome.war);
        c2.setRelation(c, DiplomacyOutcome.war);
      } else {
        log('The rogue AI ${a.name} brokers peace between the ${c.name} and the ${c2.name}.');
        c.setRelation(c2, DiplomacyOutcome.peace);
        c2.setRelation(c, DiplomacyOutcome.peace);
      }
    }
  }

  Agent spawnPirate({
    required Planet location,
    required SentientType sentientType,
    required int year,
    String? name,
  }) {
    final agentName = name ?? '${random.pick(sentientType.name.split(' '))} the Pirate';
    return Agent(
      type: AgentType.pirate,
      birth: year,
      name: agentName,
      location: location,
      sentientType: sentientType,
      fleet: 1 + random.d(3),
      resources: random.d(5),
    );
  }

  Agent spawnAdventurer({
    required Planet location,
    required SentientType sentientType,
    required Civilization originator,
    required int year,
    String? name,
  }) {
    final agentName = name ?? '${random.pick(sentientType.name.split(' '))} the Adventurer';
    return Agent(
      type: AgentType.adventurer,
      birth: year,
      name: agentName,
      location: location,
      sentientType: sentientType,
      originator: originator,
      fleet: 2 + random.d(4),
      resources: random.d(5),
    );
  }

  Agent spawnSpaceMonster({required Planet location, required int year}) {
    final monsterName = random.pick(monsterTypes);
    final adjectives = ['giant', 'cosmic', 'void', 'ancient', 'titanic'];
    final fullName = '${random.pick(adjectives)} space $monsterName';
    return Agent(
      type: AgentType.spaceMonster,
      birth: year,
      name: fullName,
      location: location,
    );
  }

  Agent spawnRogueAi({required Planet location, required int year}) {
    final letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    final name = 'Unit ${random.pick(letters)}${random.nextInt(100)}';
    return Agent(
      type: AgentType.rogueAi,
      birth: year,
      name: name,
      location: location,
    );
  }

  Agent spawnSpaceProbe({
    required Planet target,
    required Civilization originator,
    required int year,
    required int travelTime,
  }) {
    return Agent(
      type: AgentType.spaceProbe,
      birth: year,
      name: 'Probe ${originator.name[0]}${random.nextInt(1000)}',
      location: null,
      target: target,
      originator: originator,
      timer: travelTime,
    );
  }
}

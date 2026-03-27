# Flutter Conversion Guide for SpaceGen

## Overview

This guide provides practical steps and code examples for converting SpaceGen from Java/Swing to Dart/Flutter.

---

## Phase 1: Core Data Models

### 1.1 SpaceGen Core Class

**Java Original**:
```java
public class SpaceGen {
    Random r;
    ArrayList<String> log = new ArrayList<String>();
    ArrayList<Planet> planets = new ArrayList<Planet>();
    ArrayList<Civ> civs = new ArrayList<Civ>();
    int year = 0;
    int age = 1;
}
```

**Dart Conversion**:
```dart
import 'dart:math';

class SpaceGen {
  final Random random;
  final List<String> log = [];
  final List<Planet> planets = [];
  final List<Civ> civs = [];
  final List<Agent> agents = [];
  final List<String> historicalCivNames = [];
  final List<String> historicalSentientNames = [];
  final List<String> turnLog = [];
  
  bool clearTurnLogOnNewEntry = false;
  bool hadCivs = false;
  bool yearAnnounced = false;
  int year = 0;
  int age = 1;
  
  SpaceGen(int seed) : random = Random(seed);
  
  void init() {
    // Initialization logic
    log.add('IN THE BEGINNING, ALL WAS DARK.');
    log.add('THEN, PLANETS BEGAN TO FORM:');
    
    final numPlanets = 6 + dice(4, 6);
    final planetNames = <String>[];
    
    for (var i = 0; i < numPlanets; i++) {
      final planet = Planet(random, this);
      planetNames.add(planet.name);
      planets.add(planet);
    }
    
    log.add(planetNames.join(', '));
  }
  
  void tick() {
    turnLog.clear();
    year++;
    yearAnnounced = false;
    
    // Age transitions
    if (!hadCivs && civs.isNotEmpty) {
      logMessage('WE ENTER THE ${Names.nth(age).toUpperCase()} AGE OF CIVILISATION');
    }
    if (hadCivs && civs.isEmpty) {
      age++;
      logMessage('WE ENTER THE ${Names.nth(age).toUpperCase()} AGE OF DARKNESS');
    }
    hadCivs = civs.isNotEmpty;
    
    // Phase 1: Planet events
    _tickPlanets();
    
    // Phase 2: Civilization tick
    _tickCivs();
    
    // Phase 3: Agent tick
    _tickAgents();
    
    // Phase 4: Planet evolution
    _tickEvolution();
    
    // Phase 5: Erosion
    _tickErosion();
  }
  
  void _tickPlanets() {
    for (final planet in planets) {
      // Space monster spawning
      if (probability(2500)) {
        final color = pick(Names.colors);
        final mType = pick(AgentType.monsterTypes);
        final mName = 'giant spaceborne ${color.toLowerCase()} $mType';
        logMessage('A $mName appears from the depths of space and menaces the skies of ${planet.name}.');
        
        final monster = Agent(
          type: AgentType.spaceMonster,
          birth: year,
          name: mName,
          sg: this,
        )..mType = mType
         ..color = color
         ..location = planet;
        
        agents.add(monster);
      }
      
      // Pollution management
      if ((planet.population > 12 || (planet.population > 7 && probability(10))) 
          && planet.pollution < 4) {
        planet.pollution++;
      }
      
      // Population dynamics
      _tickPopulations(planet);
      
      // Plague management
      _tickPlagues(planet);
    }
  }
  
  void _tickPopulations(Planet planet) {
    final popsToRemove = <Population>[];
    
    for (final pop in List<Population>.from(planet.inhabitants)) {
      // Mutation
      if (planet.owner == null && 
          probability(100) && 
          pop.type.base != SentientBase.robots &&
          pop.type.base != SentientBase.parasites) {
        final newType = pop.type.mutate(this, null);
        logMessage('The ${pop.type.name} on ${planet.name} mutate into ${newType.name}.');
        pop.type = newType;
        pop.update();
      }
      
      // Pollution vs growth
      final roll = dice(6);
      if (roll < planet.pollution) {
        planet.pollution--;
        if (pop.size == 1) {
          pop.eliminate();
          planet.dePop(pop, year, null, 'from the effects of pollution', null);
          logMessage('${pop.type.name} have died out on ${planet.name}!');
          popsToRemove.add(pop);
          continue;
        } else {
          pop.size--;
        }
      } else {
        // Growth conditions
        if (roll == 6 || 
            (pop.type.base == SentientBase.antoids && roll > 3) ||
            (planet.owner != null && roll == 5) ||
            (planet.hasStructure(pop.type.base.specialStructure) && roll > 2)) {
          pop.size++;
        }
      }
      
      // Plague effects
      _applyPlagues(planet, pop);
    }
  }
  
  void _tickCivs() {
    final civsToRemove = <Civ>[];
    
    for (final civ in List<Civ>.from(civs)) {
      if (checkCivDoom(civ)) {
        civsToRemove.add(civ);
        continue;
      }
      
      var newRes = 0;
      var newSci = 1;
      
      // Resource generation from colonies
      for (final colony in List<Planet>.from(civ.colonies)) {
        // Special artefact effects
        if (civ.hasArtefact(ArtefactType.universalAntidote)) {
          for (final plague in colony.plagues) {
            logMessage('The ${plague.name} on ${colony.name} is cured by the universal antidote.');
          }
          colony.clearPlagues();
        }
        
        // Overcrowding pollution
        if (colony.population > 7 || (colony.population > 4 && probability(3))) {
          colony.evoPoints = 0;
          colony.pollution++;
        }
        
        // Population redistribution
        if (probability(6) && 
            colony.population > 4 && 
            colony != civ.leastPopulousFullColony() &&
            civ.leastPopulousFullColony().population < colony.population - 1) {
          for (final pop in colony.inhabitants) {
            if (pop.size > 1) {
              pop.send(civ.leastPopulousFullColony());
              break;
            }
          }
        }
        
        // Resource calculation
        if (colony.population == 0 && !colony.isOutpost) {
          colony.deCiv(year, null, '');
        } else {
          if (colony.population > 0) {
            newRes++;
            if (colony.lifeforms.contains(SpecialLifeform.vastHerds)) {
              newRes++;
            }
          }
          if (colony.specials.contains(PlanetSpecial.gemWorld)) {
            newRes++;
          }
          if (colony.hasStructure(StructureType.miningBase)) {
            newRes++;
          }
          if (colony.hasStructure(StructureType.scienceLab)) {
            newSci += 2;
          }
        }
      }
      
      if (checkCivDoom(civ)) {
        civsToRemove.add(civ);
        continue;
      }
      
      // Apply artefact bonuses
      if (civ.hasArtefact(ArtefactType.masterComputer)) {
        newRes += 2;
        newSci += 3;
      }
      
      civ.resources += newRes;
      
      // Execute behaviors
      final leadSpecies = pick(civ.fullMembers);
      pick(leadSpecies.base.behavior).invoke(civ, this);
      
      if (checkCivDoom(civ)) {
        civsToRemove.add(civ);
        continue;
      }
      
      pick(civ.govt.behavior).invoke(civ, this);
      
      if (checkCivDoom(civ)) {
        civsToRemove.add(civ);
        continue;
      }
      
      civ.science += newSci;
      
      // Scientific breakthroughs
      if (civ.science > civ.nextBreakthrough) {
        civ.science -= civ.nextBreakthrough;
        if (Science.advance(civ, this)) {
          civsToRemove.add(civ);
          continue;
        }
        civ.nextBreakthrough = min(500, (civ.nextBreakthrough * 3 / 2).toInt());
      }
      
      // Decrepitude
      final civAge = year - civ.birthYear;
      if (civAge > 5) civ.decrepitude++;
      if (civAge > 15) civ.decrepitude++;
      if (civAge > 25) civ.decrepitude++;
      if (civAge > 40) civ.decrepitude++;
      if (civAge > 60) civ.decrepitude++;
      
      // Random events
      if (probability(3)) {
        final eventRoll = dice(6);
        final (good, bad) = _calculateEventProbability(civ.decrepitude, eventRoll);
        
        if (good) {
          pick(GoodCivEvent.values).invoke(civ, this);
        }
        
        if (checkCivDoom(civ)) {
          civsToRemove.add(civ);
          continue;
        }
        
        if (bad) {
          pick(BadCivEvent.values).invoke(civ, this);
        }
        
        if (checkCivDoom(civ)) {
          civsToRemove.add(civ);
          continue;
        }
      }
      
      // War
      War.doWar(civ, this);
    }
    
    civs.removeWhere((civ) => civsToRemove.contains(civ));
  }
  
  (bool good, bool bad) _calculateEventProbability(int decrepitude, int roll) {
    bool good, bad;
    
    if (decrepitude < 5) {
      good = roll <= 5;
      bad = false;
    } else if (decrepitude < 17) {
      good = roll >= 4;
      bad = roll == 1;
    } else if (decrepitude < 25) {
      good = roll == 6;
      bad = roll < 3;
    } else {
      good = roll == 6;
      bad = roll < 5;
    }
    
    return (good, bad);
  }
  
  void _tickAgents() {
    for (final agent in List<Agent>.from(agents)) {
      if (!agents.contains(agent)) continue;
      agent.type.behave(agent, this);
    }
    
    // Second pass for adventurers
    for (final agent in List<Agent>.from(agents)) {
      if (!agents.contains(agent)) continue;
      if (agent.type == AgentType.adventurer) {
        agent.type.behave(agent, this);
      }
    }
  }
  
  void _tickEvolution() {
    for (final planet in planets) {
      // Cataclysms
      if (planet.habitable && probability(500)) {
        final cataclysm = pick(Cataclysm.values);
        final civ = planet.owner;
        logMessage(cataclysm.desc.replaceAll('\$name', planet.name));
        planet.deLive(year, cataclysm, null);
        
        if (civ != null) {
          if (checkCivDoom(civ)) {
            civs.remove(civ);
          }
        }
        continue;
      }
      
      // Pollution reduction
      if (probability(200) && planet.pollution > 1 && 
          !planet.specials.contains(PlanetSpecial.poisonWorld)) {
        logMessage('Pollution on ${planet.name} abates.');
        planet.pollution--;
      }
      
      // Planet specials
      if (probability(300 + 5000 * planet.specials.length)) {
        final special = pick(PlanetSpecial.values);
        if (!planet.specials.contains(special)) {
          planet.specials.add(special);
          special.apply(planet);
          logMessage(special.announcement.replaceAll('\$name', planet.name));
        }
      }
      
      // Evolution
      planet.evoPoints += dice(6) * dice(6) * dice(6) * dice(6) * dice(6) * 
                          3 * (6 - planet.pollution);
      
      if (planet.evoPoints > planet.evoNeeded && 
          probability(12) && 
          planet.pollution < 2) {
        planet.evoPoints = 0;
        
        if (!planet.habitable) {
          planet.habitable = true;
          logMessage('Life arises on ${planet.name}');
        } else {
          if (planet.inhabitants.isNotEmpty && coin()) {
            if (planet.owner == null) {
              // Civilization emergence
              final govt = pick(Government.values);
              final starter = pick(planet.inhabitants);
              starter.size++;
              
              final civ = Civ(
                year: year,
                st: starter.type,
                home: planet,
                govt: govt,
                resources: dice(3),
                sg: this,
              );
              
              logMessage('The ${starter.type.name} on ${planet.name} achieve spaceflight '
                        'and organise as a ${govt.typeName}, the ${civ.name}.');
              historicalCivNames.add(civ.name);
              civs.add(civ);
              
              for (final pop in planet.inhabitants) {
                pop.addUpdateImgs();
              }
            }
          } else {
            if (probability(3) || planet.lifeforms.length >= 3) {
              // Sentient species
              final st = SentientType.invent(this, null, planet, null);
              Population(st, 2 + dice(1), planet);
              logMessage('Sentient ${st.name} arise on ${planet.name}.');
            } else {
              // Special lifeform
              final lifeform = pick(SpecialLifeform.values);
              if (!planet.lifeforms.contains(lifeform)) {
                planet.addLifeform(lifeform);
                logMessage('${lifeform.name} evolve on ${planet.name}.');
              }
            }
          }
        }
      }
    }
  }
  
  void _tickErosion() {
    for (final planet in planets) {
      final strataToRemove = <Stratum>[];
      
      for (final stratum in List<Stratum>.from(planet.strata)) {
        final age = year - stratum.time + 1;
        
        if (stratum is Fossil) {
          if (probability((12000 / age + 800).toInt())) {
            strataToRemove.add(stratum);
          }
        } else if (stratum is LostArtefact) {
          if (stratum.artefact.type != ArtefactType.stasisCapsule) {
            if (probability((10000 / age + 500).toInt())) {
              strataToRemove.add(stratum);
            }
          }
        } else if (stratum is Remnant) {
          if (probability((4000 / age + 400).toInt())) {
            strataToRemove.add(stratum);
          }
        } else if (stratum is Ruin) {
          final baseRate = _getRuinBaseRate(stratum.structure.type);
          if (probability((baseRate / age + 150).toInt())) {
            strataToRemove.add(stratum);
          }
        }
      }
      
      planet.strata.removeWhere((s) => strataToRemove.contains(s));
    }
  }
  
  int _getRuinBaseRate(StructureType type) {
    if (type == StructureType.militaryBase ||
        type == StructureType.miningBase ||
        type == StructureType.scienceLab) {
      return 1000;
    }
    return 3000;
  }
  
  bool checkCivDoom(Civ civ) {
    if (civ.fullColonies.isEmpty) {
      logMessage('The ${civ.name} collapses.');
      for (final colony in List<Planet>.from(civ.colonies)) {
        colony.deCiv(year, null, 'during the collapse of the ${civ.name}');
      }
      return true;
    }
    
    if (civ.colonies.length == 1 && civ.colonies[0].population == 1) {
      final remnant = civ.colonies[0];
      logMessage('The ${civ.name} collapses, leaving only a few survivors on ${remnant.name}.');
      remnant.owner = null;
      return true;
    }
    
    return false;
  }
  
  // Utility methods
  T pick<T>(List<T> items) => items[random.nextInt(items.length)];
  
  bool coin() => random.nextBool();
  
  bool probability(int n) => dice(n) == 0;
  
  int dice(int n) => random.nextInt(n);
  
  int diceMultiple(int rolls, int sides) {
    var sum = 0;
    for (var i = 0; i < rolls; i++) {
      sum += dice(sides);
    }
    return sum;
  }
  
  void logMessage(String message) {
    if (clearTurnLogOnNewEntry) {
      turnLog.clear();
      clearTurnLogOnNewEntry = false;
    }
    
    if (!yearAnnounced) {
      yearAnnounced = true;
      logMessage('$year:');
    }
    
    log.add(message);
    turnLog.add(message);
  }
}
```

---

## Phase 2: Planet Model

**Dart Implementation**:
```dart
class Planet {
  static const planetNames = [
    'Taranis', 'Krantor', 'Mycon', 'Urbon', 'Metatron', 'Autorog',
    'Pastinakos', 'Orra', 'Hylon', 'Wotan', 'Erebus', 'Regor',
    'Sativex', 'Vim', 'Freia', 'Tabernak', 'Helmettepol', 'Lumen',
    'Atria', 'Bal', 'Orgus', 'Hylus', 'Jurvox', 'Kalamis', 'Ziggurat',
    'Xarlan', 'Chroma', 'Nid', 'Mera'
  ];
  
  final String name;
  final int x;
  final int y;
  
  int _pollution = 0;
  bool habitable = false;
  int evoPoints = 0;
  int evoNeeded = 0;
  
  final List<PlanetSpecial> specials = [];
  final List<SpecialLifeform> lifeforms = [];
  final List<Population> inhabitants = [];
  final List<Artefact> artefacts = [];
  final List<Structure> structures = [];
  final List<Plague> plagues = [];
  final List<Stratum> strata = [];
  
  Civ? _owner;
  PlanetSprite? sprite;
  
  Planet(Random random, SpaceGen sg)
      : name = planetNames[random.nextInt(planetNames.length)],
        x = random.nextInt(800),
        y = random.nextInt(600),
        evoNeeded = random.nextInt(1000000) + 500000 {
    sprite = PlanetSprite(this);
  }
  
  int get pollution => _pollution;
  
  set pollution(int value) {
    _pollution = value;
    // Trigger animation
    if (sprite != null) {
      Main.animate([Stage.change(sprite!, Imager.get(this))]);
    }
  }
  
  Civ? get owner => _owner;
  
  set owner(Civ? value) {
    if (_owner != null && sprite != null) {
      _owner!.sprites.remove(sprite!.ownerSprite);
      Main.animate([
        Stage.tracking(sprite!, Stage.remove(sprite!.ownerSprite!))
      ]);
      sprite!.ownerSprite = null;
    }
    
    _owner = value;
    
    if (value != null && sprite != null) {
      sprite!.ownerSprite = CivSprite(value, false);
      value.sprites.add(sprite!.ownerSprite!);
      sprite!.ownerSprite!.init();
      Main.animate([
        Stage.tracking(sprite!, Stage.add(sprite!.ownerSprite!, sprite!))
      ]);
    }
    
    Main.animate([Stage.delay()]);
  }
  
  int get population {
    return inhabitants.fold(0, (sum, pop) => sum + pop.size);
  }
  
  bool get isOutpost {
    return structures.any((s) => 
      s.type == StructureType.militaryBase ||
      s.type == StructureType.miningBase ||
      s.type == StructureType.scienceLab
    );
  }
  
  bool hasStructure(StructureType type) {
    return structures.any((s) => s.type == type);
  }
  
  void addPlague(Plague plague) {
    plagues.add(plague);
    if (sprite != null) {
      final ps = Sprite(
        Imager.get(plague),
        (plagues.length - 1) * 36,
        36 * 4,
      );
      sprite!.plagueSprites[plague] = ps;
      Main.animate([
        Stage.tracking(sprite!, Stage.delay()),
        Stage.add(ps, sprite!),
      ]);
    }
  }
  
  void removePlague(Plague plague) {
    if (sprite != null) {
      final sIndex = plagues.indexOf(plague);
      final ss = sprite!.plagueSprites[plague];
      
      Main.animate([
        Stage.tracking(sprite!, Stage.delay()),
        Stage.remove(ss!),
      ]);
      
      for (var i = sIndex + 1; i < plagues.length; i++) {
        Main.add(Stage.move(
          sprite!.plagueSprites[plagues[i]]!,
          (i - 1) * 36,
          36 * 2,
        ));
      }
      
      Main.animate([]);
      sprite!.plagueSprites.remove(plague);
    }
    
    plagues.remove(plague);
  }
  
  void clearPlagues() {
    if (sprite != null) {
      for (final plague in plagues) {
        Main.add(Stage.remove(sprite!.plagueSprites[plague]!));
      }
      Main.animate([]);
      sprite!.plagueSprites.clear();
    }
    plagues.clear();
  }
  
  void addArtefact(Artefact artefact) {
    artefacts.add(artefact);
    if (sprite != null) {
      final as = Sprite(
        Imager.get(artefact),
        (artefacts.length - 1) * 36,
        36,
      );
      sprite!.artefactSprites[artefact] = as;
      Main.animate([
        Stage.tracking(sprite!, Stage.delay()),
        Stage.add(as, sprite!),
      ]);
    }
  }
  
  void removeArtefact(Artefact artefact) {
    if (sprite != null) {
      final aIndex = artefacts.indexOf(artefact);
      final as = sprite!.artefactSprites[artefact];
      
      Main.animate([
        Stage.tracking(sprite!, Stage.delay()),
        Stage.remove(as!),
      ]);
      
      for (var i = aIndex + 1; i < artefacts.length; i++) {
        Main.add(Stage.move(
          sprite!.artefactSprites[artefacts[i]]!,
          (i - 1) * 36,
          36,
        ));
      }
      
      Main.animate([]);
      sprite!.artefactSprites.remove(artefact);
    }
    
    artefacts.remove(artefact);
  }
  
  void addStructure(Structure structure) {
    structures.add(structure);
    if (sprite != null) {
      final ss = Sprite(
        Imager.get(structure),
        (structures.length - 1) * 36,
        36 * 2,
      );
      sprite!.structureSprites[structure] = ss;
      Main.animate([
        Stage.tracking(sprite!, Stage.delay()),
        Stage.add(ss, sprite!),
      ]);
    }
  }
  
  void removeStructure(Structure structure) {
    if (sprite != null) {
      final sIndex = structures.indexOf(structure);
      final ss = sprite!.structureSprites[structure];
      
      Main.animate([
        Stage.tracking(sprite!, Stage.delay()),
        Stage.remove(ss!),
      ]);
      
      for (var i = sIndex + 1; i < structures.length; i++) {
        Main.add(Stage.move(
          sprite!.structureSprites[structures[i]]!,
          (i - 1) * 36,
          36 * 2,
        ));
      }
      
      Main.animate([]);
      sprite!.structureSprites.remove(structure);
    }
    
    structures.remove(structure);
  }
  
  void addLifeform(SpecialLifeform lifeform) {
    lifeforms.add(lifeform);
    if (sprite != null) {
      final slfs = Sprite(
        Imager.get(lifeform),
        (lifeforms.length - 1) * 36,
        36 * 3,
      );
      sprite!.lifeformSprites[lifeform] = slfs;
      Main.animate([
        Stage.tracking(sprite!, Stage.delay()),
        Stage.add(slfs, sprite!),
      ]);
    }
  }
  
  void dePop(Population pop, int time, Cataclysm? cat, String reason, Plague? plague) {
    strata.add(Remnant(pop, time, cat, reason, plague));
    pop.eliminate();
    
    // Remove plagues that no longer have hosts
    final plaguesToRemove = <Plague>[];
    for (final plague in plagues) {
      var hasHost = false;
      for (final otherPop in inhabitants) {
        if (plague.affects.contains(otherPop.type)) {
          hasHost = true;
          break;
        }
      }
      if (!hasHost) {
        plaguesToRemove.add(plague);
      }
    }
    
    for (final plague in plaguesToRemove) {
      removePlague(plague);
    }
  }
  
  void deCiv(int time, Cataclysm? cat, String reason) {
    // Dark age - civilization collapses
    for (final structure in structures) {
      strata.add(Ruin(structure, time, cat, reason));
    }
    clearStructures();
    
    for (final artefact in artefacts) {
      strata.add(LostArtefact('lost', time, artefact));
    }
    clearArtefacts();
    
    owner = null;
  }
  
  void deLive(int time, Cataclysm? cat, String? reason) {
    // Complete extinction
    for (final pop in inhabitants) {
      strata.add(Fossil(pop.type, time, cat));
      pop.eliminate();
    }
    inhabitants.clear();
    habitable = false;
    
    for (final lifeform in List<SpecialLifeform>.from(lifeforms)) {
      removeLifeform(lifeform);
    }
  }
  
  void clearStructures() {
    if (sprite != null) {
      for (final structure in structures) {
        Main.add(Stage.remove(sprite!.structureSprites[structure]!));
      }
      Main.animate([]);
      sprite!.structureSprites.clear();
    }
    structures.clear();
  }
  
  void clearArtefacts() {
    if (sprite != null) {
      for (final artefact in artefacts) {
        Main.add(Stage.remove(sprite!.artefactSprites[artefact]!));
      }
      Main.animate([]);
      sprite!.artefactSprites.clear();
    }
    artefacts.clear();
  }
  
  void removeLifeform(SpecialLifeform lifeform) {
    if (sprite != null) {
      final lfIndex = lifeforms.indexOf(lifeform);
      final slfs = sprite!.lifeformSprites[lifeform];
      
      Main.animate([
        Stage.tracking(sprite!, Stage.delay()),
        Stage.remove(slfs!),
      ]);
      
      for (var i = lfIndex + 1; i < lifeforms.length; i++) {
        Main.add(Stage.move(
          sprite!.lifeformSprites[lifeforms[i]]!,
          (i - 1) * 36,
          36 * 3,
        ));
      }
      
      Main.animate([]);
      sprite!.lifeformSprites.remove(lifeform);
    }
    
    lifeforms.remove(lifeform);
  }
  
  String fullDesc(SpaceGen sg) {
    final sb = StringBuffer();
    sb.writeln('$name:');
    
    if (!habitable) {
      sb.writeln('  Lifeless world');
    } else {
      if (inhabitants.isNotEmpty) {
        sb.writeln('  Inhabitants:');
        for (final pop in inhabitants) {
          sb.writeln('    ${pop.type.name}: ${pop.size} billion');
        }
      }
      
      if (owner != null) {
        sb.writeln('  Owned by: ${owner!.name}');
      }
      
      if (structures.isNotEmpty) {
        sb.writeln('  Structures:');
        for (final structure in structures) {
          sb.writeln('    $structure');
        }
      }
      
      if (artefacts.isNotEmpty) {
        sb.writeln('  Artefacts:');
        for (final artefact in artefacts) {
          sb.writeln('    $artefact');
        }
      }
      
      if (specials.isNotEmpty) {
        sb.writeln('  Special features:');
        for (final special in specials) {
          sb.writeln('    ${special.explanation}');
        }
      }
      
      if (lifeforms.isNotEmpty) {
        sb.writeln('  Lifeforms:');
        for (final lifeform in lifeforms) {
          sb.writeln('    ${lifeform.name}');
        }
      }
      
      if (plagues.isNotEmpty) {
        sb.writeln('  Plagues:');
        for (final plague in plagues) {
          sb.writeln('    ${plague.name}');
        }
      }
      
      if (pollution > 0) {
        sb.writeln('  Pollution level: $pollution');
      }
    }
    
    if (strata.isNotEmpty) {
      sb.writeln('  Archaeological record:');
      for (final stratum in strata) {
        sb.writeln('    $stratum');
      }
    }
    
    return sb.toString();
  }
}
```

---

## Phase 3: Flutter UI Integration

### 3.1 State Management with Provider

```dart
import 'package:flutter/foundation.dart';

class SpaceGenProvider extends ChangeNotifier {
  late SpaceGen _spaceGen;
  late Stage _stage;
  bool _isRunning = false;
  bool _autorun = false;
  
  SpaceGen get spaceGen => _spaceGen;
  Stage get stage => _stage;
  bool get isRunning => _isRunning;
  bool get autorun => _autorun;
  
  void initialize(int seed) {
    _spaceGen = SpaceGen(seed);
    _stage = Stage();
    _spaceGen.init();
    notifyListeners();
  }
  
  void tick() {
    if (!_isRunning) return;
    
    _spaceGen.tick();
    notifyListeners();
  }
  
  void start() {
    _isRunning = true;
    notifyListeners();
  }
  
  void pause() {
    _isRunning = false;
    notifyListeners();
  }
  
  void toggleAutorun() {
    _autorun = !_autorun;
    notifyListeners();
  }
  
  void confirm() {
    // Handle confirmation logic
    notifyListeners();
  }
}
```

### 3.2 Main Game Screen

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    
    // 40 FPS (25ms per frame)
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 25),
    )..addListener(() {
      final provider = context.read<SpaceGenProvider>();
      if (provider.isRunning) {
        provider.tick();
      }
    });
    
    _controller.repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SpaceGen'),
        actions: [
          Consumer<SpaceGenProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  IconButton(
                    icon: Icon(provider.isRunning ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      if (provider.isRunning) {
                        provider.pause();
                      } else {
                        provider.start();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next),
                    onPressed: () => provider.tick(),
                  ),
                  Switch(
                    value: provider.autorun,
                    onChanged: (_) => provider.toggleAutorun(),
                  ),
                  Text('Autorun'),
                  SizedBox(width: 16),
                ],
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: GameCanvas(),
          ),
          Expanded(
            flex: 1,
            child: LogPanel(),
          ),
        ],
      ),
    );
  }
}
```

### 3.3 Game Canvas with CustomPainter

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

class GameCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SpaceGenProvider>(
      builder: (context, provider, child) {
        return CustomPaint(
          painter: GamePainter(provider.stage),
          child: Container(),
        );
      },
    );
  }
}

class GamePainter extends CustomPainter {
  final Stage stage;
  
  GamePainter(this.stage);
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black,
    );
    
    // Apply camera transform
    canvas.save();
    canvas.translate(
      size.width / 2 - stage.camX,
      size.height / 2 - stage.camY,
    );
    
    // Draw all sprites
    for (final sprite in stage.sprites) {
      _drawSprite(canvas, sprite, 0, 0);
    }
    
    canvas.restore();
  }
  
  void _drawSprite(Canvas canvas, Sprite sprite, double dx, double dy) {
    final paint = Paint();
    
    if (sprite.flash) {
      // Apply flash effect (yellow tint)
      paint.colorFilter = ColorFilter.mode(
        Colors.yellow.withOpacity(0.5),
        BlendMode.srcATop,
      );
    } else if (sprite.highlight) {
      // Draw border for highlight
      final borderPaint = Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawRect(
        Rect.fromLTWH(
          dx + sprite.x - 1,
          dy + sprite.y - 1,
          sprite.img.width.toDouble() + 2,
          sprite.img.height.toDouble() + 2,
        ),
        borderPaint,
      );
    }
    
    // Draw sprite image
    canvas.drawImage(
      sprite.img,
      Offset(dx + sprite.x, dy + sprite.y),
      paint,
    );
    
    // Draw children
    for (final child in sprite.children) {
      _drawSprite(canvas, child, dx + sprite.x, dy + sprite.y);
    }
  }
  
  @override
  bool shouldRepaint(GamePainter oldDelegate) => true;
}
```

### 3.4 Log Panel

```dart
class LogPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SpaceGenProvider>(
      builder: (context, provider, child) {
        return Container(
          color: Colors.grey[900],
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Year: ${provider.spaceGen.year}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(color: Colors.grey),
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: provider.spaceGen.turnLog.length,
                  itemBuilder: (context, index) {
                    final reversedIndex = 
                        provider.spaceGen.turnLog.length - 1 - index;
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        provider.spaceGen.turnLog[reversedIndex],
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## Phase 4: Animation System

### 4.1 Stage Class

```dart
import 'dart:ui' as ui;

class Stage {
  bool doTrack = true;
  final List<Sprite> sprites = [];
  final List<Animation> animations = [];
  
  double camX = 0;
  double camY = 0;
  
  void animate(Animation animation) {
    animations.add(animation);
  }
  
  void animateAll(List<Animation> anims) {
    animations.addAll(anims);
  }
  
  bool tick() {
    animations.removeWhere((anim) => anim.tick(this));
    return animations.isEmpty;
  }
  
  // Factory methods for animations
  static Animation delay([int wait = 10, Animation? next]) {
    return DelayAnimation(wait, next);
  }
  
  static Animation tracking(Sprite sprite, Animation? next) {
    return TrackingAnimation(sprite, next);
  }
  
  static Animation move(Sprite sprite, double tx, double ty, [int? time]) {
    return MoveAnimation(sprite, tx, ty, time);
  }
  
  static Animation add(Sprite sprite, [Sprite? parent]) {
    return AddAnimation(sprite, parent);
  }
  
  static Animation remove(Sprite sprite) {
    return RemoveAnimation(sprite);
  }
  
  static Animation change(Sprite sprite, ui.Image newImage) {
    return ChangeAnimation(sprite, newImage);
  }
  
  static Animation seq(List<Animation> animations) {
    return SeqAnimation(animations);
  }
  
  static Animation sim(List<Animation> animations) {
    return SimAnimation(animations);
  }
}
```

### 4.2 Animation Implementations

```dart
import 'dart:math';
import 'dart:ui' as ui;

abstract class Animation {
  bool tick(Stage stage);
}

class DelayAnimation implements Animation {
  int wait;
  final Animation? next;
  
  DelayAnimation(this.wait, this.next);
  
  @override
  bool tick(Stage stage) {
    if (wait > 0) {
      wait--;
      return false;
    }
    return next?.tick(stage) ?? true;
  }
}

class TrackingAnimation implements Animation {
  final Sprite sprite;
  final Animation? next;
  int _tick = 0;
  int _time = 0;
  double _sx = 0, _sy = 0;
  bool _lock = false;
  
  TrackingAnimation(this.sprite, this.next);
  
  @override
  bool tick(Stage stage) {
    if (!stage.doTrack) {
      return next?.tick(stage) ?? true;
    }
    
    final tx = sprite.globalX + sprite.img.width / 2;
    final ty = sprite.globalY + sprite.img.height / 2;
    
    if (_tick == 0) {
      _sx = stage.camX;
      _sy = stage.camY;
      final distance = sqrt(pow(_sx - tx, 2) + pow(_sy - ty, 2));
      _time = (distance / 120).toInt() + 3;
    }
    
    if (!_lock) {
      stage.camX = _sx + (tx - _sx) * _tick / _time;
      stage.camY = _sy + (ty - _sy) * _tick / _time;
      _tick++;
      _lock = _tick > _time;
      return false;
    } else {
      stage.camX = tx;
      stage.camY = ty;
      return next?.tick(stage) ?? true;
    }
  }
}

class MoveAnimation implements Animation {
  final Sprite sprite;
  final double tx, ty;
  int? time;
  int _tick = 0;
  double _sx = 0, _sy = 0;
  
  MoveAnimation(this.sprite, this.tx, this.ty, this.time);
  
  @override
  bool tick(Stage stage) {
    if (_tick == 0) {
      _sx = sprite.x;
      _sy = sprite.y;
      if (time == null) {
        final distance = sqrt(pow(_sx - tx, 2) + pow(_sy - ty, 2));
        time = (distance / 60).toInt() + 2;
      }
    }
    
    sprite.highlight = true;
    sprite.x = _sx + (tx - _sx) * _tick / time!;
    sprite.y = _sy + (ty - _sy) * _tick / time!;
    
    if (_tick++ >= time!) {
      sprite.highlight = false;
      return true;
    }
    return false;
  }
}

class AddAnimation implements Animation {
  final Sprite sprite;
  final Sprite? parent;
  int _tick = 0;
  
  AddAnimation(this.sprite, this.parent);
  
  @override
  bool tick(Stage stage) {
    sprite.flash = true;
    if (_tick++ == 0) {
      if (parent == null) {
        stage.sprites.add(sprite);
      } else {
        parent!.children.add(sprite);
        sprite.parent = parent;
      }
      return false;
    }
    if (_tick > 5) {
      sprite.flash = false;
      return true;
    }
    return false;
  }
}

class RemoveAnimation implements Animation {
  final Sprite sprite;
  int _tick = 0;
  
  RemoveAnimation(this.sprite);
  
  @override
  bool tick(Stage stage) {
    sprite.flash = true;
    if (_tick++ > 5) {
      if (sprite.parent == null) {
        stage.sprites.remove(sprite);
      } else {
        sprite.parent!.children.remove(sprite);
      }
      return true;
    }
    return false;
  }
}

class ChangeAnimation implements Animation {
  final Sprite sprite;
  final ui.Image newImage;
  int _tick = 0;
  
  ChangeAnimation(this.sprite, this.newImage);
  
  @override
  bool tick(Stage stage) {
    sprite.flash = true;
    if (_tick++ > 3) {
      sprite.img = newImage;
      sprite.flash = false;
      return true;
    }
    return false;
  }
}

class SeqAnimation implements Animation {
  final List<Animation> animations;
  int _index = 0;
  
  SeqAnimation(this.animations);
  
  @override
  bool tick(Stage stage) {
    if (_index >= animations.length) return true;
    
    if (animations[_index].tick(stage)) {
      _index++;
    }
    return _index >= animations.length;
  }
}

class SimAnimation implements Animation {
  final List<Animation?> animations;
  
  SimAnimation(List<Animation> anims) 
      : animations = List<Animation?>.from(anims);
  
  @override
  bool tick(Stage stage) {
    var anyLive = false;
    
    for (var i = 0; i < animations.length; i++) {
      if (animations[i] != null) {
        if (animations[i]!.tick(stage)) {
          animations[i] = null;
        } else {
          anyLive = true;
        }
      }
    }
    
    return !anyLive;
  }
}
```

### 4.3 Sprite Class

```dart
import 'dart:ui' as ui;

class Sprite {
  double x;
  double y;
  ui.Image img;
  final List<Sprite> children = [];
  Sprite? parent;
  bool highlight = false;
  bool flash = false;
  
  Sprite(this.img, this.x, this.y);
  
  double get globalX {
    if (parent == null) return x;
    return parent!.globalX + x;
  }
  
  double get globalY {
    if (parent == null) return y;
    return parent!.globalY + y;
  }
}
```

---

## Phase 5: Image Loading

```dart
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class Imager {
  static final Map<String, ui.Image> _cache = {};
  
  static Future<ui.Image> load(String assetPath) async {
    if (_cache.containsKey(assetPath)) {
      return _cache[assetPath]!;
    }
    
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
    );
    final frame = await codec.getNextFrame();
    _cache[assetPath] = frame.image;
    return frame.image;
  }
  
  static ui.Image get(dynamic entity) {
    // Implement logic to get appropriate image for entity
    if (entity is Planet) {
      return _getPlanetImage(entity);
    } else if (entity is Civ) {
      return _getCivImage(entity);
    } else if (entity is Agent) {
      return _getAgentImage(entity);
    } else if (entity is Artefact) {
      return _getArtefactImage(entity);
    } else if (entity is Structure) {
      return _getStructureImage(entity);
    } else if (entity is Plague) {
      return _getPlagueImage(entity);
    } else if (entity is SpecialLifeform) {
      return _getLifeformImage(entity);
    }
    
    throw Exception('Unknown entity type: ${entity.runtimeType}');
  }
  
  static ui.Image _getPlanetImage(Planet planet) {
    // Generate or load planet image based on properties
    // This would be implemented based on your image generation logic
    return _cache['planet_default']!;
  }
  
  // Implement other _get*Image methods similarly
}
```

---

## Phase 6: Main Entry Point

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(SpaceGenApp());
}

class SpaceGenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SpaceGenProvider()
        ..initialize(DateTime.now().millisecondsSinceEpoch),
      child: MaterialApp(
        title: 'SpaceGen',
        theme: ThemeData.dark(),
        home: GameScreen(),
      ),
    );
  }
}
```

---

## Testing Strategy

### Unit Tests

```dart
import 'package:test/test.dart';

void main() {
  group('SpaceGen', () {
    test('initialization creates planets', () {
      final sg = SpaceGen(12345);
      sg.init();
      
      expect(sg.planets.length, greaterThanOrEqualTo(6));
      expect(sg.planets.length, lessThanOrEqualTo(30));
    });
    
    test('tick increments year', () {
      final sg = SpaceGen(12345);
      sg.init();
      
      final initialYear = sg.year;
      sg.tick();
      
      expect(sg.year, equals(initialYear + 1));
    });
    
    test('probability works correctly', () {
      final sg = SpaceGen(12345);
      var trueCount = 0;
      
      for (var i = 0; i < 1000; i++) {
        if (sg.probability(10)) {
          trueCount++;
        }
      }
      
      // Should be approximately 100 (10%)
      expect(trueCount, greaterThan(50));
      expect(trueCount, lessThan(150));
    });
  });
  
  group('Planet', () {
    test('population calculation', () {
      final sg = SpaceGen(12345);
      final planet = Planet(sg.random, sg);
      
      expect(planet.population, equals(0));
      
      final pop1 = Population(
        SentientType.invent(sg, null, planet, null),
        3,
        planet,
      );
      planet.inhabitants.add(pop1);
      
      expect(planet.population, equals(3));
      
      final pop2 = Population(
        SentientType.invent(sg, null, planet, null),
        2,
        planet,
      );
      planet.inhabitants.add(pop2);
      
      expect(planet.population, equals(5));
    });
  });
  
  group('Civ', () {
    test('doom check with no colonies', () {
      final sg = SpaceGen(12345);
      sg.init();
      
      final planet = sg.planets.first;
      planet.habitable = true;
      
      final pop = Population(
        SentientType.invent(sg, null, planet, null),
        3,
        planet,
      );
      planet.inhabitants.add(pop);
      
      final civ = Civ(
        year: sg.year,
        st: pop.type,
        home: planet,
        govt: Government.republic,
        resources: 5,
        sg: sg,
      );
      
      sg.civs.add(civ);
      
      // Remove all colonies
      planet.owner = null;
      
      expect(sg.checkCivDoom(civ), isTrue);
    });
  });
}
```

---

## Performance Considerations

### 1. Image Caching

```dart
class ImageCache {
  static final Map<String, ui.Image> _cache = {};
  static const maxCacheSize = 100;
  
  static Future<ui.Image> get(String key, Future<ui.Image> Function() loader) async {
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }
    
    if (_cache.length >= maxCacheSize) {
      // Remove oldest entry
      _cache.remove(_cache.keys.first);
    }
    
    final image = await loader();
    _cache[key] = image;
    return image;
  }
}
```

### 2. Lazy Loading

```dart
class LazySpaceGen {
  SpaceGen? _instance;
  
  Future<SpaceGen> get instance async {
    if (_instance == null) {
      _instance = SpaceGen(DateTime.now().millisecondsSinceEpoch);
      await _loadAssets();
      _instance!.init();
    }
    return _instance!;
  }
  
  Future<void> _loadAssets() async {
    // Load all necessary images
    await Future.wait([
      Imager.load('assets/images/planet_default.png'),
      Imager.load('assets/images/civ_icon.png'),
      // ... more assets
    ]);
  }
}
```

### 3. Efficient Rendering

```dart
class OptimizedGamePainter extends CustomPainter {
  final Stage stage;
  final Rect viewport;
  
  OptimizedGamePainter(this.stage, this.viewport);
  
  @override
  void paint(Canvas canvas, Size size) {
    // Only draw sprites within viewport
    for (final sprite in stage.sprites) {
      if (_isInViewport(sprite)) {
        _drawSprite(canvas, sprite, 0, 0);
      }
    }
  }
  
  bool _isInViewport(Sprite sprite) {
    final spriteRect = Rect.fromLTWH(
      sprite.globalX,
      sprite.globalY,
      sprite.img.width.toDouble(),
      sprite.img.height.toDouble(),
    );
    return viewport.overlaps(spriteRect);
  }
  
  @override
  bool shouldRepaint(OptimizedGamePainter oldDelegate) {
    return true; // Or implement more sophisticated change detection
  }
}
```

---

## Summary

This conversion guide provides:

1. **Direct Dart translations** of core Java classes
2. **Flutter-specific implementations** for UI and rendering
3. **State management** using Provider pattern
4. **Animation system** adapted to Flutter's paradigm
5. **Testing strategies** for validation
6. **Performance optimizations** for smooth gameplay

The key differences from Java:
- Use `List<T>` instead of `ArrayList<T>`
- Use `Map<K,V>` instead of `HashMap<K,V>`
- Use `ChangeNotifier` for reactive state updates
- Use `CustomPainter` for rendering instead of Graphics2D
- Use Flutter's animation framework instead of manual threading
- Use `async/await` for asynchronous operations

Next steps:
1. Implement remaining entity classes (Civ, Agent, etc.)
2. Port all enum types
3. Implement behavior systems (CivAction, Events, etc.)
4. Create UI components for game controls
5. Add save/load functionality
6. Implement procedural image generation

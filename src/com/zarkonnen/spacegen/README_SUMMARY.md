# SpaceGen Analysis Summary

## Quick Reference Guide

This document provides a high-level overview and quick reference for the SpaceGen project analysis.

---

## Project Overview

**SpaceGen** is a procedural space civilization simulator that generates emergent narratives about the rise and fall of civilizations across multiple planets.

**Key Features**:
- Procedural planet generation
- Life and sentient species evolution
- Civilization emergence, expansion, and collapse
- Archaeological record system (strata)
- Agent-based interactions (monsters, pirates, adventurers)
- War and diplomacy systems
- Scientific advancement and artefact creation
- Visual animation system

**Technology Stack**:
- **Current**: Java with Swing/AWT
- **Target**: Dart with Flutter

---

## Core Concepts

### 1. Tick-Based Simulation

The game runs on a turn-based system where each "tick" represents a time unit:

```
Tick → Planet Events → Civ Actions → Agent Behaviors → Evolution → Erosion
```

**Tick Rate**: 40 FPS (25ms per frame)

### 2. Five-Phase Processing

Each tick processes in 5 distinct phases:

1. **Planet Events**: Pollution, population dynamics, plagues
2. **Civilization Tick**: Resource generation, behaviors, events, war
3. **Agent Tick**: Monster attacks, pirate raids, adventurer discoveries
4. **Planet Evolution**: Life emergence, sentience, civilization formation
5. **Erosion**: Archaeological decay of historical records

### 3. Archaeological System

Everything that happens leaves traces in planetary strata:
- **Fossils**: Extinct species
- **Remnants**: Dead populations
- **Ruins**: Collapsed structures
- **Lost Artefacts**: Hidden treasures

### 4. Emergent Narrative

The system generates stories through:
- Random events weighted by civilization age
- Behavior-driven actions based on government type
- Species-specific behaviors
- War and diplomacy outcomes
- Scientific breakthroughs

---

## Key Components

### SpaceGen (Core Engine)

**Purpose**: Main simulation controller

**Key Responsibilities**:
- Manages all game entities
- Executes tick phases
- Generates random events
- Maintains event log

**Critical Methods**:
- `init()` - Creates initial planets
- `tick()` - Executes one simulation step
- `checkCivDoom()` - Determines civilization collapse
- `interesting()` - Evaluates world complexity

### Planet

**Purpose**: Celestial body that hosts life and civilizations

**Key Properties**:
- Pollution level (affects life)
- Habitability status
- Evolution points
- Inhabitants (populations)
- Owner (civilization)
- Structures and artefacts
- Archaeological strata

**Key Methods**:
- `dePop()` - Remove population, add to strata
- `deCiv()` - Civilization collapse
- `deLive()` - Complete extinction

### Civilization

**Purpose**: Spacefaring society with government and technology

**Key Properties**:
- Full members (species with citizenship)
- Government type
- Resources, science, military
- Technology and weapon levels
- Decrepitude (age-based decline)

**Key Methods**:
- `getColonies()` - List of controlled planets
- `reachables()` - Planets within travel range
- `hasArtefact()` - Check for special items

### Agent

**Purpose**: Independent actors affecting the world

**Types**:
- **Space Monster**: Attacks inhabited planets
- **Pirate**: Raids civilizations
- **Adventurer**: Discovers artefacts
- **Refugee**: Seeks safe haven
- **Merchant**: Trades between civs

### Stage (Animation System)

**Purpose**: Manages visual animations and camera

**Key Features**:
- Sprite hierarchy (parent-child relationships)
- Animation queue
- Camera tracking
- Flash and highlight effects

**Animation Types**:
- Delay, Move, Add, Remove, Change
- Tracking (camera follows sprite)
- Sequential and simultaneous

---

## Important Algorithms

### 1. Civilization Doom Check

```
IF no full colonies:
    → Collapse all colonies
    → Return DOOMED
ELSE IF only 1 colony with 1 population:
    → Leave remnant survivors
    → Return DOOMED
ELSE:
    → Return ALIVE
```

### 2. War Resolution

```
1. Find enemies (relations = WAR)
2. Calculate military strength
3. Find reachable targets
4. IF attacker stronger:
     IF bombardment:
         → Increase pollution
         → Kill population
     ELSE invasion:
         → Determine fate of each population
         → Transfer ownership
5. Apply casualties
6. Check for doom
```

### 3. Evolution Event

```
IF planet not habitable:
    → Make habitable
ELSE IF has inhabitants AND coin flip:
    IF no owner:
        → Create new civilization
ELSE:
    IF probability(3) OR lifeforms >= 3:
        → Create sentient species
    ELSE:
        → Add special lifeform
```

### 4. Science Advancement

```
Roll d20:
    0-2: Tech level increase
    3-4: Weapon level increase
    5-7: Discover artefact from strata
    8-9: Create new artefact
    10:  Transcendence (civ removed)
    11+: Minor breakthrough
```

---

## Probability Reference

| Event | Chance | Context |
|-------|--------|---------|
| Space Monster Spawn | 1/2500 | Per planet per tick |
| Population Mutation | 1/100 | Per pop if no owner |
| Civ Random Event | 3/100 | Per civ per tick |
| Cataclysm | 1/500 | Per habitable planet |
| Planet Special | 1/(300+5000×specials) | Per planet |
| Evolution Event | 1/12 | If evo points sufficient |
| Pollution Reduction | 1/200 | Per planet |
| Population Growth | 1/6 | Base chance (modified) |

---

## Government Types

| Government | Title | Bombardment | Encounter Behavior | Focus |
|------------|-------|-------------|-------------------|-------|
| Dictatorship | Empire | 50% | Mostly exterminate/subjugate | Military |
| Theocracy | Church | 25% | Subjugate > exterminate | Colonization |
| Feudal State | Kingdom | 50% | Balanced | Balanced |
| Republic | Republic | 100% | Mostly give membership | Science |

---

## Artefact Types

### Regular Artefacts
- **Wreck**: Destroyed spacecraft
- **Pirate Hoard**: Hidden treasure
- **Time Ice**: Frozen in time
- **Art**: Cultural masterpiece

### Functional Devices
- **Master Computer**: +2 resources, +3 science
- **Mind Control Device**: Prevents slave revolts
- **Virtual Reality Matrix**: Prevents slave revolts
- **Planet Destroyer**: Intimidates enemies
- **Teleport Gate**: Infinite travel range
- **Universal Antidote**: Cures all plagues
- **Mind Reader**: Population growth boost
- **Stasis Capsule**: Never erodes

---

## Cataclysm Types

1. **Nova**: Star explosion
2. **Volcanic Eruptions**: Massive eruptions
3. **Axial Shift**: Orbital axis change
4. **Meteorite Impact**: Asteroid strike
5. **Nanofungal Bloom**: Consuming fungus
6. **Psionic Shockwave**: Psychic wave

All cataclysms:
- Kill all life on planet
- Make planet uninhabitable
- Add fossils to strata
- Can doom civilizations

---

## Conversion Checklist

### Phase 1: Core Models ✓
- [ ] SpaceGen class
- [ ] Planet class
- [ ] Civilization class
- [ ] Agent class
- [ ] Population class
- [ ] SentientType class
- [ ] Artefact class
- [ ] Structure class
- [ ] Stratum classes (Fossil, Remnant, Ruin, LostArtefact)

### Phase 2: Enumerations ✓
- [ ] Government
- [ ] AgentType
- [ ] ArtefactType
- [ ] Cataclysm
- [ ] PlanetSpecial
- [ ] SpecialLifeform
- [ ] StructureType
- [ ] CivAction
- [ ] SentientEncounterOutcome

### Phase 3: Logic Systems ✓
- [ ] CivAction behaviors
- [ ] GoodCivEvent
- [ ] BadCivEvent
- [ ] War system
- [ ] Science system
- [ ] Diplomacy system
- [ ] Agent behaviors

### Phase 4: Animation System ✓
- [ ] Stage class
- [ ] Sprite class
- [ ] Animation interface
- [ ] DelayAnimation
- [ ] TrackingAnimation
- [ ] MoveAnimation
- [ ] AddAnimation
- [ ] RemoveAnimation
- [ ] ChangeAnimation
- [ ] SeqAnimation
- [ ] SimAnimation

### Phase 5: Flutter UI ✓
- [ ] Main app structure
- [ ] State management (Provider)
- [ ] Game screen
- [ ] Game canvas (CustomPainter)
- [ ] Log panel
- [ ] Control panel
- [ ] Info displays

### Phase 6: Assets & Resources ✓
- [ ] Image loading system
- [ ] Procedural image generation
- [ ] Font resources
- [ ] Color schemes
- [ ] Asset management

### Phase 7: Testing ✓
- [ ] Unit tests for core logic
- [ ] Widget tests for UI
- [ ] Integration tests
- [ ] Performance testing

---

## Key Differences: Java vs Dart/Flutter

### Data Structures
| Java | Dart |
|------|------|
| `ArrayList<T>` | `List<T>` |
| `HashMap<K,V>` | `Map<K,V>` |
| `HashSet<T>` | `Set<T>` |
| `Random` | `Random` (dart:math) |

### Threading
| Java | Flutter |
|------|---------|
| `Thread` + `Runnable` | `Timer.periodic` |
| `Thread.sleep()` | `Duration` |
| Manual threading | Automatic frame scheduling |

### Rendering
| Java | Flutter |
|------|---------|
| `Graphics2D` | `Canvas` |
| `BufferedImage` | `ui.Image` |
| `BufferStrategy` | Automatic double buffering |
| Manual drawing | `CustomPainter` |

### State Management
| Java | Flutter |
|------|---------|
| Direct field access | `ChangeNotifier` |
| Manual updates | `notifyListeners()` |
| Observer pattern | Provider/Riverpod |

---

## Performance Considerations

### Optimization Strategies

1. **Image Caching**
   - Cache all loaded images
   - Limit cache size (e.g., 100 images)
   - Use LRU eviction

2. **Viewport Culling**
   - Only render sprites in viewport
   - Calculate visible bounds
   - Skip off-screen animations

3. **Lazy Loading**
   - Load assets on demand
   - Defer heavy computations
   - Use async/await

4. **Efficient Collections**
   - Use appropriate data structures
   - Avoid unnecessary copies
   - Batch operations

5. **Animation Optimization**
   - Remove completed animations
   - Combine similar animations
   - Use hardware acceleration

---

## Common Patterns

### 1. Random Selection
```dart
T pick<T>(List<T> items) => items[random.nextInt(items.length)];
```

### 2. Probability Check
```dart
bool probability(int n) => dice(n) == 0;  // 1 in n chance
```

### 3. Logging with Substitution
```dart
void log(String message, {Planet? planet, Civ? civ}) {
  message = message
    .replaceAll('\$name', planet?.name ?? civ?.name ?? '')
    .replaceAll('\$pname', planet?.name ?? '');
  log.add(message);
}
```

### 4. Animation Chaining
```dart
Main.animate([
  Stage.tracking(sprite, Stage.delay()),
  Stage.add(newSprite, parent),
]);
```

### 5. Safe Iteration with Modification
```dart
for (final item in List<T>.from(collection)) {
  // Safe to modify collection here
  if (condition) {
    collection.remove(item);
  }
}
```

---

## Debugging Tips

### 1. Enable Verbose Logging
```dart
void logMessage(String message) {
  if (kDebugMode) {
    print('[$year] $message');
  }
  log.add(message);
}
```

### 2. Visualize State
```dart
String debugState() {
  return '''
Year: $year
Planets: ${planets.length}
Civs: ${civs.length}
Agents: ${agents.length}
''';
}
```

### 3. Track Animation Queue
```dart
void debugAnimations() {
  print('Active animations: ${animations.length}');
  for (final anim in animations) {
    print('  - ${anim.runtimeType}');
  }
}
```

### 4. Validate Consistency
```dart
void validateState() {
  // Check planet ownership
  for (final planet in planets) {
    if (planet.owner != null) {
      assert(planet.owner!.colonies.contains(planet));
      assert(civs.contains(planet.owner));
    }
  }
  
  // Check civ colonies
  for (final civ in civs) {
    for (final colony in civ.colonies) {
      assert(colony.owner == civ);
    }
  }
}
```

---

## Testing Strategies

### 1. Deterministic Testing
```dart
test('same seed produces same result', () {
  final sg1 = SpaceGen(12345);
  final sg2 = SpaceGen(12345);
  
  sg1.init();
  sg2.init();
  
  expect(sg1.planets.length, equals(sg2.planets.length));
  expect(sg1.planets[0].name, equals(sg2.planets[0].name));
});
```

### 2. Probability Testing
```dart
test('probability distribution', () {
  final sg = SpaceGen(12345);
  var count = 0;
  
  for (var i = 0; i < 10000; i++) {
    if (sg.probability(10)) count++;
  }
  
  // Should be approximately 1000 (10%)
  expect(count, greaterThan(900));
  expect(count, lessThan(1100));
});
```

### 3. State Transition Testing
```dart
test('civilization lifecycle', () {
  final sg = SpaceGen(12345);
  sg.init();
  
  // Create a civilization
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
  
  expect(civ.colonies.length, equals(1));
  expect(planet.owner, equals(civ));
  
  // Simulate collapse
  planet.owner = null;
  expect(sg.checkCivDoom(civ), isTrue);
});
```

---

## Resources

### Documentation Files
1. **DESIGN_ANALYSIS.md** - Complete architecture and design
2. **FLUTTER_CONVERSION_GUIDE.md** - Step-by-step conversion guide
3. **UML_DIAGRAMS.md** - Visual diagrams and relationships
4. **README_SUMMARY.md** - This quick reference

### Key Sections to Reference
- **Architecture Overview** → DESIGN_ANALYSIS.md
- **Code Examples** → FLUTTER_CONVERSION_GUIDE.md
- **Class Relationships** → UML_DIAGRAMS.md
- **Algorithms** → DESIGN_ANALYSIS.md (Key Algorithms section)
- **Probabilities** → This document (Probability Reference)

---

## Next Steps

### For Understanding the System
1. Read DESIGN_ANALYSIS.md for complete overview
2. Study UML_DIAGRAMS.md for visual understanding
3. Review key algorithms in DESIGN_ANALYSIS.md
4. Trace through a complete tick cycle

### For Flutter Conversion
1. Set up Flutter project structure
2. Implement core data models (Phase 1)
3. Port enumeration types (Phase 2)
4. Implement logic systems (Phase 3)
5. Build animation system (Phase 4)
6. Create Flutter UI (Phase 5)
7. Add assets and resources (Phase 6)
8. Write tests (Phase 7)

### For Extending the System
1. Understand the tick-based architecture
2. Study existing event systems
3. Follow probability patterns
4. Maintain archaeological record
5. Add animations for new features
6. Update log messages

---

## Quick Command Reference

### Running the Java Version
```bash
# Compile
javac -d bin src/com/zarkonnen/spacegen/*.java

# Run with default settings
java -cp bin com.zarkonnen.spacegen.Main

# Run with specific parameters
java -cp bin com.zarkonnen.spacegen.SpaceGen <bound> <seed>
```

### Running Flutter Version (Future)
```bash
# Get dependencies
flutter pub get

# Run in debug mode
flutter run

# Run tests
flutter test

# Build release
flutter build apk  # Android
flutter build ios  # iOS
flutter build web  # Web
```

---

## Glossary

**Tick**: One simulation step, representing a unit of game time

**Stratum**: A layer in a planet's archaeological record

**Decrepitude**: Age-based decline of a civilization

**Full Colony**: A colony with population > 0

**Outpost**: A colony with only structures, no population

**Full Member**: A species with full citizenship in a civilization

**Reachable**: Planets within a civilization's travel range

**Transcendence**: A civilization ascending beyond physical reality

**Dark Age**: Loss of spaceflight technology, colonies become independent

**Doom**: Condition where a civilization must be removed from the game

**Evolution Points**: Accumulated points toward an evolution event

**Breakthrough**: Scientific advancement requiring accumulated science points

---

## Contact & Contribution

**Original Author**: David Stark (Zarkonnen)
**License**: Apache License 2.0
**Year**: 2012

For the Flutter conversion project, maintain the same license and attribution.

---

## Version History

- **v1.0** (2012): Original Java/Swing implementation
- **v2.0** (TBD): Flutter/Dart conversion

---

*This summary document is part of the SpaceGen analysis package. For detailed information, refer to the complete documentation set.*

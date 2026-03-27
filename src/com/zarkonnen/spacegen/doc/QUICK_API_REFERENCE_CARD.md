# Quick API Reference Card

**For**: SpaceGen Dart/Flutter Conversion  
**Stages**: 1 (Enums) + 2 (Models)

---

## Stage 1: Enumerations

### Import Statements
```dart
import 'package:dart_conversion/enums/sentient_encounter_outcome.dart';
import 'package:dart_conversion/enums/cataclysm.dart';
import 'package:dart_conversion/enums/special_lifeform.dart';
import 'package:dart_conversion/enums/planet_special.dart';
import 'package:dart_conversion/enums/government.dart';
```

### Quick Reference

| Enum | Values | Properties |
|------|--------|------------|
| **SentientEncounterOutcome** | extinction, enslavement, coexistence, integration, war, avoidance | name, description |
| **Cataclysm** | nova, volcanicEruptions, axialShift, meteoriteImpact, nanofungalBloom, psionicShockwave | name, desc |
| **SpecialLifeform** | ultravores, pharmaceuticals, shapeShifter, brainParasite, vastHerds, flyingCreatures, oceanGiants, livingIslands, gasBags, radiovores | name, desc |
| **PlanetSpecial** | ancientRuins, richMinerals, fertileGround, strategicLocation, beautifulVistas, harshEnvironment, unstableCore, magneticAnomaly, temporalFlux, psionicResonance | name, description, effect |
| **Government** | democracy, autocracy, oligarchy, theocracy, technocracy, militaryJunta, corporatocracy, hiveMind, aiGovernance, anarchy | name, description, traits |

### Common Patterns

```dart
// Access enum properties
print(cataclysm.name);
print(cataclysm.desc);

// Switch statement
switch (outcome) {
  case SentientEncounterOutcome.extinction:
    // Handle extinction
    break;
  // ... other cases
}

// Random selection
final random = Random();
final cataclysm = Cataclysm.values[random.nextInt(Cataclysm.values.length)];

// Using RandomUtils
final lifeform = RandomUtils.pick(SpecialLifeform.values, random);
```

---

## Stage 2: Models

### Import Statements
```dart
import 'package:dart_conversion/models/planet.dart';
import 'package:dart_conversion/models/civilization.dart';
import 'package:dart_conversion/models/agent.dart';
import 'package:dart_conversion/models/population.dart';
import 'package:dart_conversion/models/sentient_type.dart';
import 'package:dart_conversion/models/artefact.dart';
import 'package:dart_conversion/models/structure.dart';
import 'package:dart_conversion/models/plague.dart';
import 'package:dart_conversion/models/strata/stratum.dart';
import 'package:dart_conversion/models/strata/fossil.dart';
import 'package:dart_conversion/models/strata/remnant.dart';
import 'package:dart_conversion/models/strata/ruin.dart';
import 'package:dart_conversion/models/strata/lost_artefact.dart';
```

### Core Models Quick Reference

#### Planet
```dart
// Create
final planet = Planet(
  name: 'Earth',
  x: 3, y: 4,
  habitable: true,
);

// Key properties
planet.totalPopulation        // int - total population
planet.owner                  // Civilization? - owner
planet.inhabitants            // List<Population>
planet.structures             // List<Structure>
planet.artefacts             // List<Artefact>
planet.strata                // List<Stratum>

// Key methods
planet.hasStructure(type)                    // bool
planet.depopulate(pop, time, ...)           // void
planet.extinguishLife(time, cataclysm, ...)  // void
planet.addStructure(structure)               // void
planet.addArtefact(artefact)                // void
```

#### Civilization
```dart
// Create
final civ = Civilization(
  name: 'Terran Federation',
  government: Government.democracy,
  birthYear: 2150,
);

// Key properties
civ.resources        // int
civ.science          // int
civ.military         // int
civ.techLevel        // int
civ.weaponLevel      // int
civ.fullMembers      // List<SentientType>
civ.relations        // Map<Civilization, DiplomacyOutcome>

// Key methods
civ.getRelation(other)           // DiplomacyOutcome
civ.setRelation(other, outcome)  // void
```

#### Agent
```dart
// Create
final agent = Agent(
  type: AgentType.explorer,
  name: 'USS Discovery',
  birth: 2200,
  location: earth,
  originator: terrans,
);

// Key properties
agent.location       // Planet?
agent.target         // Planet?
agent.type           // AgentType
agent.resources      // int
agent.fleet          // int
```

#### Population
```dart
// Create
final pop = Population(
  type: humanType,
  size: 100,
  planet: earth,
);

// Key properties
pop.size             // int
pop.type             // SentientType
pop.planet           // Planet
pop.isEnslaved       // bool

// Key methods
pop.increase(amount)  // void
pop.decrease(amount)  // void
```

### Supporting Models Quick Reference

#### SentientType
```dart
final type = SentientType(
  name: 'Humans',
  color: '#0000FF',
  adjective: 'Human',
  plural: 'Humans',
);
```

#### Artefact
```dart
final artefact = Artefact(
  type: ArtefactType.weapon,
  name: 'Plasma Cannon',
  description: 'Ancient weapon',
  discoveryYear: 2300,
  discoverer: civ,
);
```

#### Structure
```dart
final structure = Structure(
  type: StructureType.laboratory,
  name: 'Research Facility',
);
```

#### Plague
```dart
final plague = Plague(
  name: 'Red Death',
  affects: [humanType],
  severity: 8,
);
```

### Stratum System Quick Reference

```dart
// Fossil - extinct lifeform
final fossil = Fossil(
  fossil: SpecialLifeform.ultravores,
  fossilisationTime: 2200,
  cataclysm: Cataclysm.meteoriteImpact,
);

// Remnant - extinct population
final remnant = Remnant(
  remnant: population,
  collapseTime: 2300,
  cataclysm: Cataclysm.nova,
);

// Ruin - destroyed structure
final ruin = Ruin(
  structure: fortress,
  ruinTime: 2250,
  reason: 'during collapse',
);

// LostArtefact - buried artefact
final lost = LostArtefact(
  status: 'buried',
  lostTime: 2280,
  artefact: ancientWeapon,
);
```

---

## Common Workflows

### 1. Create a Planet with Life
```dart
final planet = Planet(name: 'Kepler-442b', x: 5, y: 3, habitable: true);
planet.addLifeform(SpecialLifeform.vastHerds);
planet.specials.add(PlanetSpecial.fertileGround);
```

### 2. Create a Civilization
```dart
final civ = Civilization(
  name: 'Keplarians',
  government: Government.democracy,
  birthYear: 2200,
);
civ.fullMembers.add(alienType);
planet.owner = civ;
```

### 3. Add Population
```dart
final pop = Population(type: alienType, size: 50, planet: planet);
planet.inhabitants.add(pop);
```

### 4. Build Structures
```dart
planet.addStructure(Structure(
  type: StructureType.laboratory,
  name: 'Science Center',
));
```

### 5. Handle Extinction
```dart
planet.extinguishLife(
  2300,
  Cataclysm.meteoriteImpact,
  'massive asteroid',
);
// Automatically creates strata (fossils, remnants, ruins)
```

### 6. Create an Agent
```dart
final explorer = Agent(
  type: AgentType.explorer,
  name: 'Explorer One',
  birth: 2250,
  location: homeworld,
  originator: civ,
  fleet: 5,
);
```

### 7. Set Diplomatic Relations
```dart
civ1.setRelation(civ2, DiplomacyOutcome.alliance);
civ2.setRelation(civ1, DiplomacyOutcome.alliance);
```

### 8. Handle Plague
```dart
final plague = Plague(
  name: 'Crimson Fever',
  affects: [humanType],
  severity: 5,
);
planet.addPlague(plague);

for (final pop in planet.inhabitants) {
  if (plague.affects.contains(pop.type)) {
    pop.decrease(plague.severity);
  }
}
```

---

## Enums Reference

### DiplomacyOutcome
```dart
enum DiplomacyOutcome { peace, war, alliance, trade, cold }
```

### AgentType
```dart
enum AgentType {
  explorer, colonist, trader, diplomat,
  spy, pirate, adventurer, missionary, scientist
}
```

### StructureType
```dart
enum StructureType {
  fortress, laboratory, mine, farm,
  factory, spaceport, monument, temple
}
```

### ArtefactType
```dart
enum ArtefactType { weapon, device, knowledge }
```

---

## Best Practices Checklist

- ✅ Use null-aware operators (`?.`, `??`)
- ✅ Check for null before accessing nullable properties
- ✅ Use lifecycle methods (don't manually manage state)
- ✅ Use enums for type safety (not strings)
- ✅ Use switch statements for exhaustive handling
- ✅ Maintain bidirectional relationships
- ✅ Create strata for historical records
- ✅ Use collection helper methods (addStructure, etc.)

---

## Testing Quick Reference

```dart
import 'package:test/test.dart';

void main() {
  group('Planet', () {
    test('calculates total population', () {
      final planet = Planet(name: 'Test', x: 0, y: 0);
      final pop = Population(type: type, size: 100, planet: planet);
      planet.inhabitants.add(pop);
      
      expect(planet.totalPopulation, equals(100));
    });
  });
}
```

---

## Documentation Links

- **Full Stage 1 API**: [STAGE_1_API_DOCUMENTATION.md](STAGE_1_API_DOCUMENTATION.md)
- **Full Stage 2 API**: [STAGE_2_API_DOCUMENTATION.md](STAGE_2_API_DOCUMENTATION.md)
- **Conversion Plan**: [STAGED_CONVERSION_PLAN.md](STAGED_CONVERSION_PLAN.md)
- **Status Tracker**: [CONVERSION_STATUS.md](CONVERSION_STATUS.md)

---

**Print this card for quick reference while coding!**

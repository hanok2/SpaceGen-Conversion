# Stage 2: Models - API Documentation

**Stage**: 2 - Basic Models  
**Status**: ✅ Complete  
**Package**: `dart_conversion/lib/models/`

---

## Overview

Stage 2 provides all core data models for the SpaceGen system. These models represent the fundamental entities in the game: planets, civilizations, agents, populations, and their relationships.

---

## Table of Contents

1. [Core Models](#core-models)
   - [Planet](#planet)
   - [Civilization](#civilization)
   - [Agent](#agent)
   - [Population](#population)
2. [Supporting Models](#supporting-models)
   - [SentientType](#sentienttype)
   - [Artefact](#artefact)
   - [Structure](#structure)
   - [Plague](#plague)
3. [Stratum System](#stratum-system)
   - [Stratum Interface](#stratum-interface)
   - [Fossil](#fossil)
   - [Remnant](#remnant)
   - [Ruin](#ruin)
   - [LostArtefact](#lostartefact)
4. [UML Diagrams](#uml-diagrams)
5. [Usage Examples](#usage-examples)
6. [Best Practices](#best-practices)

---

## Core Models

### Planet

**File**: `lib/models/planet.dart`

The central model representing a planet in the game universe.

#### Properties

```dart
class Planet {
  final String name;                          // Planet name
  int pollution;                              // Pollution level (0-6+)
  bool habitable;                             // Can support life
  int evolutionPoints;                        // Evolution progress
  int evolutionNeeded;                        // Points needed for sentience
  final List<PlanetSpecial> specials;        // Special features
  final List<SpecialLifeform> lifeforms;     // Notable lifeforms
  final List<Population> inhabitants;         // Sentient populations
  final List<Artefact> artefacts;            // Artefacts on planet
  Civilization? owner;                        // Owning civilization
  final List<Structure> structures;           // Built structures
  final List<Plague> plagues;                // Active plagues
  final List<Stratum> strata;                // Historical layers
  int x, y;                                   // Grid coordinates
}
```

#### Constructors

```dart
// Create a new planet
Planet({
  required String name,
  int pollution = 0,
  bool habitable = false,
  int evolutionPoints = 0,
  int evolutionNeeded = 15000,
  List<PlanetSpecial>? specials,
  List<SpecialLifeform>? lifeforms,
  List<Population>? inhabitants,
  List<Artefact>? artefacts,
  Civilization? owner,
  List<Structure>? structures,
  List<Plague>? plagues,
  List<Stratum>? strata,
  int x = 0,
  int y = 0,
});
```

#### Key Methods

```dart
// Get total population
int get totalPopulation;

// Check if planet has a structure type
bool hasStructure(StructureType type);

// Check if planet is an outpost (has military/science/mining base)
bool get isOutpost;

// Population management
void depopulate(Population pop, int time, Cataclysm? cataclysm, 
                String? reason, Plague? plague);

// Civilization collapse
void darkAge(int time);

// Population transcendence
void transcend(int time);

// Complete civilization removal
void decivilize(int time, Cataclysm? cataclysm, String? reason);

// Total extinction
void extinguishLife(int time, Cataclysm? cataclysm, String? reason);

// Collection management
void addPlague(Plague plague);
void removePlague(Plague plague);
void clearPlagues();
void addArtefact(Artefact artefact);
void removeArtefact(Artefact artefact);
void clearArtefacts();
void addStructure(Structure structure);
void removeStructure(Structure structure);
void clearStructures();
void addLifeform(SpecialLifeform lifeform);
void removeLifeform(SpecialLifeform lifeform);
void clearLifeforms();
```

#### Usage Examples

```dart
// Create a planet
final earth = Planet(
  name: 'Earth',
  x: 3,
  y: 4,
  habitable: true,
  evolutionPoints: 20000,
);

// Add inhabitants
final humans = Population(
  type: humanType,
  size: 100,
  planet: earth,
);
earth.inhabitants.add(humans);

// Check population
print('Total population: ${earth.totalPopulation} billion');

// Add structures
earth.addStructure(Structure(
  type: StructureType.fortress,
  name: 'Planetary Defense Grid',
));

// Check for structures
if (earth.hasStructure(StructureType.laboratory)) {
  print('Science bonus available!');
}

// Handle extinction event
earth.extinguishLife(
  2350,
  Cataclysm.meteoriteImpact,
  'massive asteroid impact',
);

// Check strata after extinction
for (final stratum in earth.strata) {
  print(stratum); // Shows historical record
}
```

#### Lifecycle Methods

The Planet class provides methods for major state transitions:

**depopulate()** - Remove a population and create historical record
```dart
void depopulate(
  Population pop,      // Population to remove
  int time,           // Current year
  Cataclysm? cataclysm, // Optional cataclysm cause
  String? reason,     // Optional reason text
  Plague? plague,     // Optional plague cause
);
```

**darkAge()** - Civilization collapses but populations survive
```dart
void darkAge(int time);
// - Converts structures to ruins
// - Converts artefacts to lost artefacts
// - Removes owner
// - Populations remain
```

**transcend()** - Civilization transcends to higher plane
```dart
void transcend(int time);
// - Creates transcendence remnants
// - Converts structures to ruins
// - Converts artefacts to lost artefacts
// - Removes all populations
// - Clears plagues
```

**decivilize()** - Complete civilization removal
```dart
void decivilize(int time, Cataclysm? cataclysm, String? reason);
// - Removes all populations (creates remnants)
// - Converts structures to ruins
// - Converts artefacts to lost artefacts
// - Removes owner
```

**extinguishLife()** - Total extinction
```dart
void extinguishLife(int time, Cataclysm? cataclysm, String? reason);
// - Calls decivilize()
// - Resets evolution points
// - Creates fossils from lifeforms
// - Clears all plagues
// - Sets habitable = false
```

---

### Civilization

**File**: `lib/models/civilization.dart`

Represents a spacefaring civilization.

#### Properties

```dart
class Civilization {
  final List<SentientType> fullMembers;      // Member species
  Government government;                      // Government type
  final Map<Civilization, DiplomacyOutcome> relations; // Diplomatic relations
  int number;                                 // Civilization ID
  int resources;                              // Resource stockpile
  int science;                                // Science points
  int military;                               // Military strength
  int weaponLevel;                            // Weapon technology
  int techLevel;                              // General technology
  String name;                                // Civilization name
  int birthYear;                              // Year founded
  int nextBreakthrough;                       // Years to next tech
  int decrepitude;                            // Decline level
}
```

#### Enums

```dart
enum DiplomacyOutcome {
  peace,      // Peaceful relations
  war,        // At war
  alliance,   // Allied
  trade,      // Trade agreement
  cold,       // Cold war
}
```

#### Constructors

```dart
Civilization({
  List<SentientType>? fullMembers,
  required Government government,
  Map<Civilization, DiplomacyOutcome>? relations,
  int number = 0,
  int resources = 0,
  int science = 0,
  int military = 0,
  int weaponLevel = 0,
  int techLevel = 0,
  required String name,
  required int birthYear,
  int nextBreakthrough = 6,
  int decrepitude = 0,
});
```

#### Key Methods

```dart
// Get diplomatic relation with another civilization
DiplomacyOutcome getRelation(Civilization other);

// Set diplomatic relation
void setRelation(Civilization other, DiplomacyOutcome outcome);
```

#### Usage Examples

```dart
// Create a civilization
final terrans = Civilization(
  name: 'Terran Federation',
  government: Government.democracy,
  birthYear: 2150,
  resources: 100,
  science: 50,
  military: 75,
  techLevel: 3,
  weaponLevel: 2,
);

// Add member species
terrans.fullMembers.add(humanType);

// Set diplomatic relations
final aliens = Civilization(
  name: 'Zorgon Empire',
  government: Government.autocracy,
  birthYear: 2100,
);

terrans.setRelation(aliens, DiplomacyOutcome.war);

// Check relations
if (terrans.getRelation(aliens) == DiplomacyOutcome.war) {
  print('We are at war with ${aliens.name}!');
}

// Advance technology
terrans.techLevel++;
terrans.science += 10;
```

---

### Agent

**File**: `lib/models/agent.dart`

Represents individual agents (explorers, traders, etc.) that move between planets.

#### Properties

```dart
class Agent {
  Planet? location;                // Current location
  AgentType type;                  // Agent type
  int resources;                   // Carried resources
  int fleet;                       // Fleet size
  int birth;                       // Year created
  String name;                     // Agent name
  SentientType? sentientType;      // Species
  Civilization? originator;        // Home civilization
  int timer;                       // Action timer
  Planet? target;                  // Target destination
  String? color;                   // Display color
  String? missionType;             // Mission description
}
```

#### Enums

```dart
enum AgentType {
  explorer,      // Explores unknown planets
  colonist,      // Establishes colonies
  trader,        // Trades resources
  diplomat,      // Conducts diplomacy
  spy,           // Gathers intelligence
  pirate,        // Raids planets
  adventurer,    // Independent agent
  missionary,    // Spreads culture
  scientist,     // Conducts research
}
```

#### Constructors

```dart
Agent({
  Planet? location,
  required AgentType type,
  int resources = 0,
  int fleet = 0,
  required int birth,
  required String name,
  SentientType? sentientType,
  Civilization? originator,
  int timer = 0,
  Planet? target,
  String? color,
  String? missionType,
});
```

#### Usage Examples

```dart
// Create an explorer
final explorer = Agent(
  type: AgentType.explorer,
  name: 'Captain Kirk',
  birth: 2250,
  location: earth,
  originator: terrans,
  sentientType: humanType,
  fleet: 5,
);

// Move agent
explorer.location = mars;
explorer.target = null;

// Create a trader
final trader = Agent(
  type: AgentType.trader,
  name: 'Merchant Vex',
  birth: 2260,
  resources: 50,
  fleet: 3,
  originator: terrans,
);

// Check agent type
switch (agent.type) {
  case AgentType.explorer:
    print('Exploring new worlds...');
    break;
  case AgentType.trader:
    print('Trading goods...');
    break;
  // ... other cases
}
```

---

### Population

**File**: `lib/models/population.dart`

Represents a population of a sentient species on a planet.

#### Properties

```dart
class Population {
  final SentientType type;    // Species type
  int size;                   // Population in billions
  final Planet planet;        // Home planet
}
```

#### Constructors

```dart
Population({
  required SentientType type,
  required int size,
  required Planet planet,
});
```

#### Key Methods

```dart
// Increase population
void increase(int amount);

// Decrease population
void decrease(int amount);

// Check if population is enslaved
bool get isEnslaved;

// String representations
String toString();              // Includes enslaved status
String toUnenslavedString();    // Without enslaved status
```

#### Usage Examples

```dart
// Create a population
final humans = Population(
  type: humanType,
  size: 100,
  planet: earth,
);

// Population growth
humans.increase(10);
print('Population: ${humans.size} billion');

// Population decline
humans.decrease(5);

// Check enslaved status
if (humans.isEnslaved) {
  print('${humans.type.name} are enslaved!');
}

// Display
print(humans); // "100 billion Humans" or "100 billion enslaved Humans"
```

---

## Supporting Models

### SentientType

**File**: `lib/models/sentient_type.dart`

Represents a sentient species.

#### Properties

```dart
class SentientType {
  final String name;        // Species name (e.g., "Humans")
  final String color;       // Display color
  final String adjective;   // Adjective form (e.g., "Human")
  final String plural;      // Plural form (e.g., "Humans")
}
```

#### Usage Examples

```dart
final humanType = SentientType(
  name: 'Humans',
  color: '#0000FF',
  adjective: 'Human',
  plural: 'Humans',
);

final robotType = SentientType(
  name: 'Robots',
  color: '#808080',
  adjective: 'Robotic',
  plural: 'Robots',
);

print('The ${humanType.adjective} civilization...');
print('A population of ${humanType.plural}...');
```

---

### Artefact

**File**: `lib/models/artefact.dart`

Represents an ancient or advanced artefact.

#### Properties

```dart
class Artefact {
  final ArtefactType type;        // Type of artefact
  final String name;              // Artefact name
  final String description;       // Description
  final int discoveryYear;        // When discovered
  final Civilization? discoverer; // Who discovered it
}
```

#### Enums

```dart
enum ArtefactType {
  weapon,      // Weapon technology
  device,      // Technological device
  knowledge,   // Information/knowledge
}
```

#### Usage Examples

```dart
final ancientWeapon = Artefact(
  type: ArtefactType.weapon,
  name: 'Plasma Cannon',
  description: 'An ancient weapon of immense power',
  discoveryYear: 2300,
  discoverer: terrans,
);

planet.addArtefact(ancientWeapon);

// Check for artefacts
if (planet.artefacts.any((a) => a.type == ArtefactType.weapon)) {
  print('Weapon technology discovered!');
}
```

---

### Structure

**File**: `lib/models/structure.dart`

Represents a built structure on a planet.

#### Properties

```dart
class Structure {
  final StructureType type;  // Type of structure
  final String name;         // Structure name
}
```

#### Enums

```dart
enum StructureType {
  fortress,      // Military base
  laboratory,    // Science facility
  mine,          // Mining operation
  farm,          // Agricultural facility
  factory,       // Manufacturing plant
  spaceport,     // Space travel hub
  monument,      // Cultural monument
  temple,        // Religious building
}
```

#### Usage Examples

```dart
final lab = Structure(
  type: StructureType.laboratory,
  name: 'Quantum Research Facility',
);

planet.addStructure(lab);

// Check for specific structures
if (planet.hasStructure(StructureType.laboratory)) {
  civilization.science += 5;
}
```

---

### Plague

**File**: `lib/models/plague.dart`

Represents a disease affecting populations.

#### Properties

```dart
class Plague {
  final String name;                      // Plague name
  final List<SentientType> affects;       // Affected species
  final int severity;                     // Severity (1-10)
}
```

#### Key Methods

```dart
// Get description
String desc();
```

#### Usage Examples

```dart
final plague = Plague(
  name: 'Red Death',
  affects: [humanType, alienType],
  severity: 8,
);

planet.addPlague(plague);

// Check if species is affected
if (plague.affects.contains(population.type)) {
  population.decrease(plague.severity);
}

print(plague.desc()); // "Red Death (severity 8)"
```

---

## Stratum System

The stratum system records historical events on planets as geological/archaeological layers.

### Stratum Interface

**File**: `lib/models/strata/stratum.dart`

Base interface for all stratum types.

```dart
abstract class Stratum {
  int get time;           // When this layer was created
  String toString();      // Description of the stratum
}
```

---

### Fossil

**File**: `lib/models/strata/fossil.dart`

Records extinct lifeforms.

#### Properties

```dart
class Fossil implements Stratum {
  final SpecialLifeform fossil;      // Extinct lifeform
  final int fossilisationTime;       // When it went extinct
  final Cataclysm? cataclysm;       // Optional cause
}
```

#### Usage Examples

```dart
final fossil = Fossil(
  fossil: SpecialLifeform.ultravores,
  fossilisationTime: 2200,
  cataclysm: Cataclysm.meteoriteImpact,
);

planet.strata.add(fossil);

// Display
print(fossil);
// "Fossils of ultravores that went extinct in 2200 due to a massive asteroid impact."
```

---

### Remnant

**File**: `lib/models/strata/remnant.dart`

Records extinct populations.

#### Properties

```dart
class Remnant implements Stratum {
  final Population remnant;          // Extinct population
  final int collapseTime;           // When they died out
  final Cataclysm? cataclysm;       // Optional cataclysm
  final String? reason;             // Optional reason
  final Plague? plague;             // Optional plague
  final bool transcended;           // Did they transcend?
}
```

#### Constructors

```dart
// Normal extinction
Remnant({
  required Population remnant,
  required int collapseTime,
  Cataclysm? cataclysm,
  String? reason,
  Plague? plague,
  bool transcended = false,
});

// Transcendence
Remnant.transcended({
  required Population remnant,
  required int transcendenceTime,
});
```

#### Usage Examples

```dart
// Normal extinction
final remnant = Remnant(
  remnant: humans,
  collapseTime: 2350,
  cataclysm: Cataclysm.nova,
);

// Transcendence
final transcended = Remnant.transcended(
  remnant: ancients,
  transcendenceTime: 2400,
);

print(remnant);
// "Remnants of the 100 billion Humans who died out in 2350 due to a nova."

print(transcended);
// "Remnants of the 50 billion Ancients who transcended in 2400."
```

---

### Ruin

**File**: `lib/models/strata/ruin.dart`

Records destroyed structures.

#### Properties

```dart
class Ruin implements Stratum {
  final Structure structure;         // Destroyed structure
  final int ruinTime;               // When destroyed
  final Cataclysm? cataclysm;       // Optional cataclysm
  final String? reason;             // Optional reason
}
```

#### Usage Examples

```dart
final ruin = Ruin(
  structure: fortress,
  ruinTime: 2300,
  reason: 'during the collapse of the Terran Federation',
);

print(ruin);
// "Ruins of a fortress from 2300 during the collapse of the Terran Federation."
```

---

### LostArtefact

**File**: `lib/models/strata/lost_artefact.dart`

Records buried or lost artefacts.

#### Properties

```dart
class LostArtefact implements Stratum {
  final String status;              // How it was lost
  final int lostTime;              // When it was lost
  final Artefact artefact;         // The lost artefact
}
```

#### Usage Examples

```dart
final lostArtefact = LostArtefact(
  status: 'buried',
  lostTime: 2350,
  artefact: ancientWeapon,
);

print(lostArtefact);
// "A Plasma Cannon, buried in 2350."
```

---

## UML Diagrams

### Core Model Class Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                          Planet                              │
├─────────────────────────────────────────────────────────────┤
│ - name: String                                              │
│ - pollution: int                                            │
│ - habitable: bool                                           │
│ - evolutionPoints: int                                      │
│ - evolutionNeeded: int                                      │
│ - x, y: int                                                 │
│ - owner: Civilization?                                      │
│ - specials: List<PlanetSpecial>                            │
│ - lifeforms: List<SpecialLifeform>                         │
│ - inhabitants: List<Population>                             │
│ - artefacts: List<Artefact>                                │
│ - structures: List<Structure>                               │
│ - plagues: List<Plague>                                     │
│ - strata: List<Stratum>                                     │
├─────────────────────────────────────────────────────────────┤
│ + totalPopulation: int                                      │
│ + hasStructure(type): bool                                  │
│ + isOutpost: bool                                           │
│ + depopulate(pop, time, cataclysm, reason, plague): void   │
│ + darkAge(time): void                                       │
│ + transcend(time): void                                     │
│ + decivilize(time, cataclysm, reason): void               │
│ + extinguishLife(time, cataclysm, reason): void           │
│ + addPlague(plague): void                                   │
│ + addArtefact(artefact): void                              │
│ + addStructure(structure): void                             │
│ + addLifeform(lifeform): void                              │
└─────────────────────────────────────────────────────────────┘
                    │
                    │ owns
                    ▼
┌─────────────────────────────────────────────────────────────┐
│                      Civilization                            │
├─────────────────────────────────────────────────────────────┤
│ - name: String                                              │
│ - government: Government                                     │
│ - birthYear: int                                            │
│ - number: int                                               │
│ - resources: int                                            │
│ - science: int                                              │
│ - military: int                                             │
│ - weaponLevel: int                                          │
│ - techLevel: int                                            │
│ - nextBreakthrough: int                                     │
│ - decrepitude: int                                          │
│ - fullMembers: List<SentientType>                          │
│ - relations: Map<Civilization, DiplomacyOutcome>           │
├─────────────────────────────────────────────────────────────┤
│ + getRelation(other): DiplomacyOutcome                     │
│ + setRelation(other, outcome): void                         │
└─────────────────────────────────────────────────────────────┘
                    │
                    │ originates
                    ▼
┌─────────────────────────────────────────────────────────────┐
│                          Agent                               │
├─────────────────────────────────────────────────────────────┤
│ - name: String                                              │
│ - type: AgentType                                           │
│ - birth: int                                                │
│ - resources: int                                            │
│ - fleet: int                                                │
│ - timer: int                                                │
│ - color: String?                                            │
│ - missionType: String?                                      │
│ - location: Planet?                                         │
│ - target: Planet?                                           │
│ - sentientType: SentientType?                              │
│ - originator: Civilization?                                 │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                       Population                             │
├─────────────────────────────────────────────────────────────┤
│ - type: SentientType                                        │
│ - size: int                                                 │
│ - planet: Planet                                            │
├─────────────────────────────────────────────────────────────┤
│ + increase(amount): void                                    │
│ + decrease(amount): void                                    │
│ + isEnslaved: bool                                          │
│ + toString(): String                                        │
│ + toUnenslavedString(): String                             │
└─────────────────────────────────────────────────────────────┘
```

### Supporting Models Class Diagram

```
┌──────────────────────┐
│    SentientType      │
├──────────────────────┤
│ - name: String       │
│ - color: String      │
│ - adjective: String  │
│ - plural: String     │
└──────────────────────┘
          ▲
          │ has type
          │
┌──────────────────────┐
│     Population       │
└──────────────────────┘

┌──────────────────────────────┐
│         Artefact             │
├──────────────────────────────┤
│ - type: ArtefactType         │
│ - name: String               │
│ - description: String        │
│ - discoveryYear: int         │
│ - discoverer: Civilization?  │
└──────────────────────────────┘

┌──────────────────────┐
│      Structure       │
├──────────────────────┤
│ - type: StructureType│
│ - name: String       │
└──────────────────────┘

┌──────────────────────────────┐
│          Plague              │
├──────────────────────────────┤
│ - name: String               │
│ - affects: List<SentientType>│
│ - severity: int              │
├──────────────────────────────┤
│ + desc(): String             │
└──────────────────────────────┘
```

### Stratum System Class Diagram

```
┌──────────────────────┐
│   <<interface>>      │
│      Stratum         │
├──────────────────────┤
│ + time: int          │
│ + toString(): String │
└──────────────────────┘
          ▲
          │ implements
          │
    ┌─────┴─────┬─────────┬──────────┐
    │           │         │          │
┌───────┐  ┌─────────┐ ┌──────┐ ┌──────────────┐
│Fossil │  │ Remnant │ │ Ruin │ │ LostArtefact │
└───────┘  └─────────┘ └──────┘ └──────────────┘

┌─────────────────────────────────┐
│           Fossil                │
├─────────────────────────────────┤
│ - fossil: SpecialLifeform       │
│ - fossilisationTime: int        │
│ - cataclysm: Cataclysm?        │
├─────────────────────────────────┤
│ + time: int                     │
│ + toString(): String            │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│          Remnant                │
├─────────────────────────────────┤
│ - remnant: Population           │
│ - collapseTime: int             │
│ - cataclysm: Cataclysm?        │
│ - reason: String?               │
│ - plague: Plague?               │
│ - transcended: bool             │
├─────────────────────────────────┤
│ + time: int                     │
│ + toString(): String            │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│            Ruin                 │
├─────────────────────────────────┤
│ - structure: Structure          │
│ - ruinTime: int                 │
│ - cataclysm: Cataclysm?        │
│ - reason: String?               │
├─────────────────────────────────┤
│ + time: int                     │
│ + toString(): String            │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│        LostArtefact             │
├─────────────────────────────────┤
│ - status: String                │
│ - lostTime: int                 │
│ - artefact: Artefact           │
├─────────────────────────────────┤
│ + time: int                     │
│ + toString(): String            │
└─────────────────────────────────┘
```

### Model Relationships Diagram

```
                    ┌──────────────┐
                    │    Planet    │
                    └──────┬───────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        │ has              │ has              │ has
        ▼                  ▼                  ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│  Population  │   │  Structure   │   │   Artefact   │
└──────┬───────┘   └──────────────┘   └──────────────┘
       │
       │ has type
       ▼
┌──────────────┐
│ SentientType │
└──────────────┘

┌──────────────┐
│    Planet    │───owns───┐
└──────────────┘          │
                          ▼
                  ┌──────────────┐
                  │ Civilization │
                  └──────┬───────┘
                         │
                         │ originates
                         ▼
                  ┌──────────────┐
                  │    Agent     │
                  └──────┬───────┘
                         │
                         │ located at
                         ▼
                  ┌──────────────┐
                  │    Planet    │
                  └──────────────┘

┌──────────────┐
│    Planet    │───has───┐
└──────────────┘         │
                         ▼
                  ┌──────────────┐
                  │   Stratum    │
                  └──────┬───────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
   ┌────────┐      ┌─────────┐      ┌──────┐
   │ Fossil │      │ Remnant │      │ Ruin │
   └────────┘      └─────────┘      └──────┘
```

---

## Usage Examples

### Complete Planet Lifecycle

```dart
import 'package:dart_conversion/models/planet.dart';
import 'package:dart_conversion/models/civilization.dart';
import 'package:dart_conversion/models/population.dart';
import 'package:dart_conversion/enums/government.dart';
import 'package:dart_conversion/enums/cataclysm.dart';

void main() {
  // Create a planet
  final planet = Planet(
    name: 'Kepler-442b',
    x: 5,
    y: 3,
    habitable: true,
    evolutionPoints: 20000,
  );
  
  // Add special lifeforms
  planet.addLifeform(SpecialLifeform.vastHerds);
  planet.addLifeform(SpecialLifeform.oceanGiants);
  
  // Create sentient species
  final alienType = SentientType(
    name: 'Keplarians',
    color: '#00FF00',
    adjective: 'Keplarian',
    plural: 'Keplarians',
  );
  
  // Add population
  final population = Population(
    type: alienType,
    size: 50,
    planet: planet,
  );
  planet.inhabitants.add(population);
  
  // Create civilization
  final civilization = Civilization(
    name: 'Keplarian Collective',
    government: Government.hiveMind,
    birthYear: 2200,
    resources: 100,
    science: 75,
  );
  civilization.fullMembers.add(alienType);
  planet.owner = civilization;
  
  // Build structures
  planet.addStructure(Structure(
    type: StructureType.laboratory,
    name: 'Quantum Research Center',
  ));
  planet.addStructure(Structure(
    type: StructureType.fortress,
    name: 'Planetary Shield',
  ));
  
  // Discover artefact
  planet.addArtefact(Artefact(
    type: ArtefactType.knowledge,
    name: 'Ancient Database',
    description: 'Contains knowledge of precursor civilization',
    discoveryYear: 2250,
    discoverer: civilization,
  ));
  
  print('Planet: ${planet.name}');
  print('Population: ${planet.totalPopulation} billion');
  print('Owner: ${planet.owner?.name}');
  print('Structures: ${planet.structures.length}');
  print('Artefacts: ${planet.artefacts.length}');
  
  // Disaster strikes!
  planet.extinguishLife(
    2300,
    Cataclysm.meteoriteImpact,
    'massive asteroid impact',
  );
  
  print('\nAfter extinction:');
  print('Habitable: ${planet.habitable}');
  print('Population: ${planet.totalPopulation}');
  print('Strata layers: ${planet.strata.length}');
  
  // View historical record
  print('\nHistorical record:');
  for (final stratum in planet.strata.reversed) {
    print('  $stratum');
  }
}
```

### Civilization Diplomacy

```dart
void demonstrateDiplomacy() {
  // Create two civilizations
  final humans = Civilization(
    name: 'United Earth',
    government: Government.democracy,
    birthYear: 2150,
  );
  
  final aliens = Civilization(
    name: 'Zorgon Empire',
    government: Government.autocracy,
    birthYear: 2100,
  );
  
  // Initial contact - peaceful
  humans.setRelation(aliens, DiplomacyOutcome.peace);
  aliens.setRelation(humans, DiplomacyOutcome.peace);
  
  print('Initial relations: ${humans.getRelation(aliens)}');
  
  // Trade agreement
  humans.setRelation(aliens, DiplomacyOutcome.trade);
  aliens.setRelation(humans, DiplomacyOutcome.trade);
  
  print('After trade: ${humans.getRelation(aliens)}');
  
  // War breaks out
  humans.setRelation(aliens, DiplomacyOutcome.war);
  aliens.setRelation(humans, DiplomacyOutcome.war);
  
  print('War declared: ${humans.getRelation(aliens)}');
  
  // Peace treaty
  humans.setRelation(aliens, DiplomacyOutcome.peace);
  aliens.setRelation(humans, DiplomacyOutcome.peace);
  
  print('Peace restored: ${humans.getRelation(aliens)}');
}
```

### Agent Movement

```dart
void demonstrateAgents() {
  final earth = Planet(name: 'Earth', x: 0, y: 0);
  final mars = Planet(name: 'Mars', x: 1, y: 0);
  final jupiter = Planet(name: 'Jupiter', x: 2, y: 0);
  
  final terrans = Civilization(
    name: 'Terran Federation',
    government: Government.democracy,
    birthYear: 2150,
  );
  
  // Create explorer
  final explorer = Agent(
    type: AgentType.explorer,
    name: 'USS Discovery',
    birth: 2200,
    location: earth,
    originator: terrans,
    fleet: 5,
  );
  
  print('${explorer.name} at ${explorer.location?.name}');
  
  // Explore Mars
  explorer.target = mars;
  explorer.location = mars;
  print('Exploring ${explorer.location?.name}');
  
  // Continue to Jupiter
  explorer.target = jupiter;
  explorer.location = jupiter;
  print('Reached ${explorer.location?.name}');
  
  // Create trader
  final trader = Agent(
    type: AgentType.trader,
    name: 'Merchant Vessel',
    birth: 2210,
    location: earth,
    originator: terrans,
    resources: 100,
  );
  
  // Trade route
  trader.target = mars;
  trader.location = mars;
  trader.resources -= 50; // Deliver goods
  print('${trader.name} delivered goods to ${trader.location?.name}');
}
```

### Plague Outbreak

```dart
void demonstratePlague() {
  final planet = Planet(name: 'Plague World', habitable: true);
  
  final humanType = SentientType(
    name: 'Humans',
    color: '#0000FF',
    adjective: 'Human',
    plural: 'Humans',
  );
  
  final alienType = SentientType(
    name: 'Aliens',
    color: '#00FF00',
    adjective: 'Alien',
    plural: 'Aliens',
  );
  
  final humans = Population(type: humanType, size: 100, planet: planet);
  final aliens = Population(type: alienType, size: 50, planet: planet);
  
  planet.inhabitants.addAll([humans, aliens]);
  
  // Plague outbreak
  final plague = Plague(
    name: 'Crimson Fever',
    affects: [humanType], // Only affects humans
    severity: 5,
  );
  
  planet.addPlague(plague);
  
  print('Plague outbreak: ${plague.desc()}');
  print('Affects: ${plague.affects.map((t) => t.name).join(", ")}');
  
  // Apply plague effects
  for (final pop in planet.inhabitants) {
    if (plague.affects.contains(pop.type)) {
      pop.decrease(plague.severity);
      print('${pop.type.name} population reduced to ${pop.size} billion');
    }
  }
  
  // If population dies out
  if (humans.size <= 0) {
    planet.depopulate(humans, 2300, null, null, plague);
    print('${humans.type.name} extinct due to plague');
  }
}
```

---

## Best Practices

### 1. Use Null Safety Properly

```dart
// ✅ Good - Check for null
if (planet.owner != null) {
  print('Owned by ${planet.owner!.name}');
}

// ✅ Better - Use null-aware operators
print('Owner: ${planet.owner?.name ?? "None"}');

// ❌ Bad - Force unwrap without checking
print(planet.owner!.name); // Crashes if null
```

### 2. Manage Collections Safely

```dart
// ✅ Good - Use collection methods
planet.addStructure(structure);
planet.removeStructure(structure);

// ✅ Good - Check before accessing
if (planet.structures.isNotEmpty) {
  final first = planet.structures.first;
}

// ❌ Bad - Direct list manipulation without validation
planet.structures.add(structure); // OK but less semantic
```

### 3. Use Lifecycle Methods

```dart
// ✅ Good - Use provided lifecycle methods
planet.extinguishLife(year, cataclysm, reason);

// ❌ Bad - Manual state management
planet.inhabitants.clear();
planet.structures.clear();
planet.habitable = false;
// ... missing strata creation, etc.
```

### 4. Maintain Bidirectional Relationships

```dart
// ✅ Good - Keep relationships consistent
final pop = Population(type: humanType, size: 100, planet: planet);
planet.inhabitants.add(pop);

// ✅ Good - Update both sides
planet.owner = civilization;
// Civilization tracks colonies separately (Stage 3)

// ❌ Bad - Inconsistent state
planet.owner = civilization;
// But civilization doesn't know about planet
```

### 5. Use Enums for Type Safety

```dart
// ✅ Good - Type safe
if (agent.type == AgentType.explorer) {
  exploreNewPlanet(agent);
}

// ❌ Bad - String comparison
if (agent.type.toString() == 'explorer') {
  // Error prone
}
```

### 6. Create Immutable Data Where Appropriate

```dart
// ✅ Good - Immutable properties
final planet = Planet(name: 'Earth', x: 0, y: 0);
// planet.name = 'Mars'; // Compile error - name is final

// ✅ Good - Mutable state
planet.pollution = 5; // OK - pollution can change
```

### 7. Use Descriptive Names

```dart
// ✅ Good - Clear intent
planet.extinguishLife(year, cataclysm, reason);
planet.depopulate(pop, year, cataclysm, reason, plague);

// ❌ Bad - Unclear
planet.kill(year);
planet.remove(pop);
```

### 8. Handle Strata Properly

```dart
// ✅ Good - Strata created automatically by lifecycle methods
planet.extinguishLife(year, cataclysm, reason);
// Creates Fossil, Remnant, Ruin, LostArtefact strata

// ✅ Good - Manual stratum creation when needed
planet.strata.add(Fossil(
  fossil: lifeform,
  fossilisationTime: year,
  cataclysm: cataclysm,
));

// ❌ Bad - Forgetting to create historical record
planet.lifeforms.clear(); // Lost history!
```

---

## Testing

### Unit Test Examples

```dart
import 'package:test/test.dart';
import 'package:dart_conversion/models/planet.dart';

void main() {
  group('Planet', () {
    test('calculates total population correctly', () {
      final planet = Planet(name: 'Test', x: 0, y: 0);
      final pop1 = Population(type: type1, size: 100, planet: planet);
      final pop2 = Population(type: type2, size: 50, planet: planet);
      
      planet.inhabitants.addAll([pop1, pop2]);
      
      expect(planet.totalPopulation, equals(150));
    });
    
    test('hasStructure returns true when structure exists', () {
      final planet = Planet(name: 'Test', x: 0, y: 0);
      planet.addStructure(Structure(
        type: StructureType.laboratory,
        name: 'Lab',
      ));
      
      expect(planet.hasStructure(StructureType.laboratory), isTrue);
      expect(planet.hasStructure(StructureType.fortress), isFalse);
    });
    
    test('extinguishLife creates proper strata', () {
      final planet = Planet(name: 'Test', x: 0, y: 0, habitable: true);
      planet.addLifeform(SpecialLifeform.ultravores);
      
      final pop = Population(type: humanType, size: 100, planet: planet);
      planet.inhabitants.add(pop);
      
      planet.addStructure(Structure(
        type: StructureType.fortress,
        name: 'Fort',
      ));
      
      planet.extinguishLife(2300, Cataclysm.nova, 'star went nova');
      
      expect(planet.habitable, isFalse);
      expect(planet.inhabitants, isEmpty);
      expect(planet.structures, isEmpty);
      expect(planet.strata.length, greaterThan(0));
      expect(planet.strata.any((s) => s is Fossil), isTrue);
      expect(planet.strata.any((s) => s is Remnant), isTrue);
      expect(planet.strata.any((s) => s is Ruin), isTrue);
    });
  });
  
  group('Civilization', () {
    test('manages diplomatic relations', () {
      final civ1 = Civilization(
        name: 'Civ1',
        government: Government.democracy,
        birthYear: 2100,
      );
      final civ2 = Civilization(
        name: 'Civ2',
        government: Government.autocracy,
        birthYear: 2150,
      );
      
      civ1.setRelation(civ2, DiplomacyOutcome.war);
      
      expect(civ1.getRelation(civ2), equals(DiplomacyOutcome.war));
    });
  });
  
  group('Population', () {
    test('increase and decrease work correctly', () {
      final pop = Population(type: humanType, size: 100, planet: planet);
      
      pop.increase(50);
      expect(pop.size, equals(150));
      
      pop.decrease(30);
      expect(pop.size, equals(120));
      
      pop.decrease(200);
      expect(pop.size, equals(0)); // Can't go negative
    });
    
    test('isEnslaved returns correct status', () {
      final planet = Planet(name: 'Test', x: 0, y: 0);
      final civ = Civilization(
        name: 'Civ',
        government: Government.democracy,
        birthYear: 2100,
      );
      planet.owner = civ;
      
      final memberPop = Population(type: memberType, size: 100, planet: planet);
      final slavePop = Population(type: slaveType, size: 50, planet: planet);
      
      civ.fullMembers.add(memberType);
      
      expect(memberPop.isEnslaved, isFalse);
      expect(slavePop.isEnslaved, isTrue);
    });
  });
}
```

---

## Migration Notes

### From Java to Dart

**Key Differences**:

1. **Null Safety**: Dart requires explicit null handling
   ```dart
   Civilization? owner;  // Can be null
   String name;          // Cannot be null
   ```

2. **Collections**: Dart uses generic collections
   ```dart
   List<Population> inhabitants = [];
   Map<Civilization, DiplomacyOutcome> relations = {};
   ```

3. **Properties**: Dart uses getters/setters or direct access
   ```dart
   int get totalPopulation => ...;  // Computed property
   int size;                         // Direct access
   ```

4. **Constructors**: Dart uses named parameters
   ```dart
   Planet({
     required String name,
     int pollution = 0,
   });
   ```

---

## Summary

Stage 2 models provide:
- ✅ Complete data structures for all game entities
- ✅ Planet lifecycle management
- ✅ Historical record keeping (strata)
- ✅ Relationship management
- ✅ Type-safe enums and collections
- ✅ Null-safe design
- ✅ Ready for game logic implementation (Stages 3-6)

**Next**: Implement game logic in Stages 3-6
- Stage 3: Planet System (evolution, cataclysms)
- Stage 4: Civilization System (actions, events)
- Stage 5: Agent System (behaviors, AI)
- Stage 6: Animation System (sprites, rendering)

---

**Previous**: [Stage 1 Enumerations Documentation](STAGE_1_API_DOCUMENTATION.md)  
**Next**: [Stage 3 Planet System](STAGED_CONVERSION_PLAN.md#stage-3-planet-system)

# Stage 1: Enumerations - API Documentation

**Stage**: 1 - Enumerations  
**Status**: ✅ Complete  
**Package**: `dart_conversion/lib/enums/`

---

## Overview

Stage 1 provides all enumeration types used throughout the SpaceGen system. These enums define fixed sets of values for game concepts like governments, cataclysms, special lifeforms, and more.

---

## Table of Contents

1. [SentientEncounterOutcome](#sentientencounteroutcome)
2. [Cataclysm](#cataclysm)
3. [SpecialLifeform](#speciallifeform)
4. [PlanetSpecial](#planetspecial)
5. [Government](#government)
6. [UML Diagrams](#uml-diagrams)

---

## SentientEncounterOutcome

**File**: `lib/enums/sentient_encounter_outcome.dart`

Defines possible outcomes when a civilization encounters a sentient species.

### Enum Values

```dart
enum SentientEncounterOutcome {
  extinction,      // Species is wiped out
  enslavement,     // Species is enslaved
  coexistence,     // Species coexists peacefully
  integration,     // Species joins the civilization
  war,            // War breaks out
  avoidance,      // Species avoids contact
}
```

### Properties

Each enum value has:
- `name` (String) - The display name
- `description` (String) - Detailed description of the outcome

### Usage Examples

```dart
import 'package:dart_conversion/enums/sentient_encounter_outcome.dart';

// Check outcome type
void handleEncounter(SentientEncounterOutcome outcome) {
  switch (outcome) {
    case SentientEncounterOutcome.extinction:
      print('The species was wiped out!');
      break;
    case SentientEncounterOutcome.integration:
      print('The species joined our civilization!');
      break;
    // ... other cases
  }
}

// Access properties
final outcome = SentientEncounterOutcome.integration;
print(outcome.name);         // "Integration"
print(outcome.description);  // "The species joins the civilization..."

// Get all outcomes
final allOutcomes = SentientEncounterOutcome.values;
```

### When to Use

- Processing first contact events
- Determining species relationships
- Generating encounter narratives
- AI decision making for species interactions

---

## Cataclysm

**File**: `lib/enums/cataclysm.dart`

Defines catastrophic events that can destroy life on planets.

### Enum Values

```dart
enum Cataclysm {
  nova,                  // Star goes nova
  volcanicEruptions,     // Massive volcanic activity
  axialShift,           // Orbital axis shift
  meteoriteImpact,      // Asteroid impact
  nanofungalBloom,      // Nanofungal outbreak
  psionicShockwave,     // Psionic wave
}
```

### Properties

Each enum value has:
- `name` (String) - Short name of the cataclysm
- `desc` (String) - Description with `$name` placeholder for planet name

### Usage Examples

```dart
import 'package:dart_conversion/enums/cataclysm.dart';

// Trigger a cataclysm
void triggerCataclysm(Planet planet, Cataclysm cataclysm) {
  final description = cataclysm.desc.replaceAll('\$name', planet.name);
  print(description);
  // "All life on Earth is killed off by a massive asteroid impact!"
  
  planet.extinguishLife(currentYear, cataclysm, cataclysm.name);
}

// Random cataclysm
final randomCataclysm = Cataclysm.values[random.nextInt(Cataclysm.values.length)];

// Check cataclysm type
if (cataclysm == Cataclysm.nova) {
  // Handle star going nova - affects entire system
}
```

### When to Use

- Implementing extinction events
- Creating historical records (Fossil, Remnant strata)
- Generating dramatic narrative events
- Planet lifecycle management

---

## SpecialLifeform

**File**: `lib/enums/special_lifeform.dart`

Defines unique and notable lifeforms that can exist on planets.

### Enum Values

```dart
enum SpecialLifeform {
  ultravores,          // Apex predators
  pharmaceuticals,     // Medicinal plants
  shapeShifter,       // Mimicking creatures
  brainParasite,      // Mind-controlling parasites
  vastHerds,          // Large grazing animals
  flyingCreatures,    // Beautiful flying creatures
  oceanGiants,        // Huge sea creatures
  livingIslands,      // Floating island ecosystems
  gasBags,            // Hydrogen-filled floaters
  radiovores,         // Radioactive material eaters
}
```

### Properties

Each enum value has:
- `name` (String) - Display name of the lifeform
- `desc` (String) - Detailed description

### Usage Examples

```dart
import 'package:dart_conversion/enums/special_lifeform.dart';

// Add special lifeform to planet
void addLifeform(Planet planet, SpecialLifeform lifeform) {
  planet.addLifeform(lifeform);
  print('Discovered ${lifeform.name}!');
  print(lifeform.desc);
}

// Check for specific lifeforms
if (planet.lifeforms.contains(SpecialLifeform.pharmaceuticals)) {
  civilization.science += 10; // Bonus for medicinal plants
}

// Create fossil record
final fossil = Fossil(
  fossil: SpecialLifeform.ultravores,
  fossilisationTime: currentYear,
  cataclysm: Cataclysm.meteoriteImpact,
);
```

### When to Use

- Planet generation and evolution
- Creating biodiversity
- Providing gameplay bonuses/penalties
- Generating fossil records
- Creating narrative flavor

---

## PlanetSpecial

**File**: `lib/enums/planet_special.dart`

Defines special planetary features and anomalies.

### Enum Values

```dart
enum PlanetSpecial {
  ancientRuins,        // Ruins of ancient civilization
  richMinerals,        // Abundant mineral deposits
  fertileGround,       // Excellent for agriculture
  strategicLocation,   // Important position
  beautifulVistas,     // Stunning landscapes
  harshEnvironment,    // Difficult conditions
  unstableCore,        // Geological instability
  magneticAnomaly,     // Strange magnetic fields
  temporalFlux,        // Time distortions
  psionicResonance,    // Psionic energy
}
```

### Properties

Each enum value has:
- `name` (String) - Display name
- `description` (String) - Detailed description
- `effect` (String) - Game effect description

### Usage Examples

```dart
import 'package:dart_conversion/enums/planet_special.dart';

// Add special to planet
void addSpecial(Planet planet, PlanetSpecial special) {
  planet.specials.add(special);
  print('${planet.name} has ${special.name}!');
  print(special.description);
  print('Effect: ${special.effect}');
}

// Check for specials
if (planet.specials.contains(PlanetSpecial.richMinerals)) {
  resourceBonus += 5;
}

// Apply special effects
for (final special in planet.specials) {
  applySpecialEffect(planet, special);
}

// Generate planet description
String describePlanet(Planet planet) {
  final buffer = StringBuffer();
  for (final special in planet.specials) {
    buffer.writeln(special.description);
  }
  return buffer.toString();
}
```

### When to Use

- Planet generation
- Applying gameplay modifiers
- Creating strategic value
- Generating planet descriptions
- Determining colonization priorities

---

## Government

**File**: `lib/enums/government.dart`

Defines types of government for civilizations.

### Enum Values

```dart
enum Government {
  democracy,           // Democratic government
  autocracy,          // Single ruler
  oligarchy,          // Rule by few
  theocracy,          // Religious rule
  technocracy,        // Rule by experts
  militaryJunta,      // Military rule
  corporatocracy,     // Corporate rule
  hiveMind,           // Collective consciousness
  aiGovernance,       // AI-controlled
  anarchy,            // No central government
}
```

### Properties

Each enum value has:
- `name` (String) - Display name
- `description` (String) - Description of government type
- `traits` (List<String>) - Characteristic traits

### Usage Examples

```dart
import 'package:dart_conversion/enums/government.dart';

// Create civilization with government
final civ = Civilization(
  name: 'Terran Federation',
  government: Government.democracy,
  birthYear: 2150,
);

// Check government type
if (civ.government == Government.hiveMind) {
  // Hive minds don't have internal conflicts
  civ.decrepitude = 0;
}

// Display government info
print('Government: ${civ.government.name}');
print(civ.government.description);
print('Traits: ${civ.government.traits.join(", ")}');

// Government affects behavior
int getDiplomacyModifier(Civilization civ1, Civilization civ2) {
  if (civ1.government == Government.democracy && 
      civ2.government == Government.democracy) {
    return 10; // Democracies get along better
  }
  return 0;
}
```

### When to Use

- Civilization creation
- Determining diplomatic relations
- Affecting civilization behavior
- Generating narrative flavor
- Calculating gameplay modifiers

---

## UML Diagrams

### Enum Class Diagram

```
┌─────────────────────────────────┐
│   SentientEncounterOutcome      │
├─────────────────────────────────┤
│ + extinction                    │
│ + enslavement                   │
│ + coexistence                   │
│ + integration                   │
│ + war                           │
│ + avoidance                     │
├─────────────────────────────────┤
│ + name: String                  │
│ + description: String           │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│         Cataclysm               │
├─────────────────────────────────┤
│ + nova                          │
│ + volcanicEruptions             │
│ + axialShift                    │
│ + meteoriteImpact               │
│ + nanofungalBloom               │
│ + psionicShockwave              │
├─────────────────────────────────┤
│ + name: String                  │
│ + desc: String                  │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│      SpecialLifeform            │
├─────────────────────────────────┤
│ + ultravores                    │
│ + pharmaceuticals               │
│ + shapeShifter                  │
│ + brainParasite                 │
│ + vastHerds                     │
│ + flyingCreatures               │
│ + oceanGiants                   │
│ + livingIslands                 │
│ + gasBags                       │
│ + radiovores                    │
├─────────────────────────────────┤
│ + name: String                  │
│ + desc: String                  │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│       PlanetSpecial             │
├─────────────────────────────────┤
│ + ancientRuins                  │
│ + richMinerals                  │
│ + fertileGround                 │
│ + strategicLocation             │
│ + beautifulVistas               │
│ + harshEnvironment              │
│ + unstableCore                  │
│ + magneticAnomaly               │
│ + temporalFlux                  │
│ + psionicResonance              │
├─────────────────────────────────┤
│ + name: String                  │
│ + description: String           │
│ + effect: String                │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│         Government              │
├─────────────────────────────────┤
│ + democracy                     │
│ + autocracy                     │
│ + oligarchy                     │
│ + theocracy                     │
│ + technocracy                   │
│ + militaryJunta                 │
│ + corporatocracy                │
│ + hiveMind                      │
│ + aiGovernance                  │
│ + anarchy                       │
├─────────────────────────────────┤
│ + name: String                  │
│ + description: String           │
│ + traits: List<String>          │
└─────────────────────────────────┘
```

### Enum Usage Relationships

```
┌──────────────┐
│   Planet     │────uses────┐
└──────────────┘            │
                            ▼
                    ┌──────────────────┐
                    │  SpecialLifeform │
                    └──────────────────┘
                            ▲
                            │
┌──────────────┐            │
│   Fossil     │────records─┘
└──────────────┘

┌──────────────┐
│   Planet     │────uses────┐
└──────────────┘            │
                            ▼
                    ┌──────────────────┐
                    │  PlanetSpecial   │
                    └──────────────────┘

┌──────────────┐
│ Civilization │────uses────┐
└──────────────┘            │
                            ▼
                    ┌──────────────────┐
                    │   Government     │
                    └──────────────────┘

┌──────────────┐
│   Planet     │────uses────┐
│   Remnant    │            │
│   Fossil     │            ▼
│   Ruin       │    ┌──────────────────┐
└──────────────┘    │    Cataclysm     │
                    └──────────────────┘

┌──────────────┐
│ Civilization │────uses────┐
└──────────────┘            │
                            ▼
                    ┌─────────────────────────┐
                    │ SentientEncounterOutcome│
                    └─────────────────────────┘
```

---

## Best Practices

### 1. Use Enums for Type Safety

```dart
// ✅ Good - Type safe
void handleCataclysm(Planet planet, Cataclysm cataclysm) {
  // Compiler ensures valid cataclysm type
}

// ❌ Bad - String based, error prone
void handleCataclysm(Planet planet, String cataclysm) {
  // Typos and invalid values possible
}
```

### 2. Use Switch Statements for Exhaustive Handling

```dart
// ✅ Good - Compiler warns if cases are missing
String getOutcomeEffect(SentientEncounterOutcome outcome) {
  switch (outcome) {
    case SentientEncounterOutcome.extinction:
      return 'Species extinct';
    case SentientEncounterOutcome.enslavement:
      return 'Species enslaved';
    case SentientEncounterOutcome.coexistence:
      return 'Species coexists';
    case SentientEncounterOutcome.integration:
      return 'Species integrated';
    case SentientEncounterOutcome.war:
      return 'War declared';
    case SentientEncounterOutcome.avoidance:
      return 'Contact avoided';
  }
}
```

### 3. Access Properties, Not toString()

```dart
// ✅ Good - Use properties
print(cataclysm.name);
print(cataclysm.desc);

// ❌ Bad - toString() gives enum name, not display name
print(cataclysm.toString()); // "Cataclysm.meteoriteImpact"
```

### 4. Use Enums in Collections

```dart
// Store multiple specials
final specials = <PlanetSpecial>[
  PlanetSpecial.richMinerals,
  PlanetSpecial.fertileGround,
];

// Check for specific special
if (specials.contains(PlanetSpecial.ancientRuins)) {
  // Handle ancient ruins
}

// Iterate over specials
for (final special in specials) {
  applyEffect(special);
}
```

### 5. Random Selection

```dart
import 'dart:math';

final random = Random();

// Random cataclysm
final cataclysm = Cataclysm.values[random.nextInt(Cataclysm.values.length)];

// Random government
final government = Government.values[random.nextInt(Government.values.length)];

// Using RandomUtils (from Stage 0)
final lifeform = RandomUtils.pick(SpecialLifeform.values, random);
```

---

## Testing

All enums have comprehensive tests in `dart_conversion/test/enums/`:

```bash
# Run all enum tests
flutter test test/enums/

# Run specific enum test
flutter test test/enums/cataclysm_test.dart
```

### Test Coverage

- ✅ All enum values accessible
- ✅ All properties return correct values
- ✅ Enum equality works correctly
- ✅ Switch statements are exhaustive

---

## Migration Notes

### From Java to Dart

**Java**:
```java
public enum Cataclysm {
    NOVA("nova", "The star goes nova..."),
    VOLCANIC_ERUPTIONS("volcanic eruptions", "Massive eruptions...");
    
    private final String name;
    private final String desc;
    
    Cataclysm(String name, String desc) {
        this.name = name;
        this.desc = desc;
    }
    
    public String getName() { return name; }
    public String getDesc() { return desc; }
}
```

**Dart**:
```dart
enum Cataclysm {
  nova('nova', 'The star goes nova...'),
  volcanicEruptions('volcanic eruptions', 'Massive eruptions...');
  
  final String name;
  final String desc;
  
  const Cataclysm(this.name, this.desc);
}
```

**Key Differences**:
- Dart enums use camelCase, not UPPER_CASE
- Dart enum constructors are `const`
- Dart properties are `final` by default
- No getters needed in Dart (direct property access)

---

## Summary

Stage 1 enumerations provide:
- ✅ Type-safe constants for game concepts
- ✅ Rich metadata (names, descriptions, effects)
- ✅ Foundation for Stage 2 models
- ✅ Compile-time validation
- ✅ Easy to extend and maintain

**Next**: [Stage 2 Models Documentation](STAGE_2_API_DOCUMENTATION.md)

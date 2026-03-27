# SpaceGen Dart Version - Quick Reference

**Version**: 0.0.1 (In Development)  
**Last Updated**: [Date]  
**Status**: Stage 0 - Not Started

---

## Project Structure

```
dart_conversion/
├── lib/
│   ├── core/              # Core engine (SpaceGen, GameState)
│   ├── models/            # Data models (Planet, Civ, Agent, etc.)
│   ├── enums/             # Enumeration types
│   ├── systems/           # Game systems (War, Science, etc.)
│   ├── rendering/         # Animation and rendering
│   ├── ui/                # Flutter UI components
│   ├── providers/         # State management
│   └── utils/             # Utility classes
├── test/                  # Unit and integration tests
├── assets/                # Images, fonts, etc.
├── doc/                   # Documentation
└── pubspec.yaml           # Dependencies
```

---

## Current Implementation Status

### ✅ Completed Components
- None yet

### 🟡 In Progress Components
- None yet

### 🔴 Not Started Components
- All components (see CONVERSION_STATUS.md)

---

## API Reference (Dart)

### Core Classes

#### SpaceGen
```dart
class SpaceGen {
  // Properties
  Random random;
  List<String> log;
  List<Planet> planets;
  List<Civ> civs;
  List<Agent> agents;
  int year;
  int age;
  
  // Constructor
  SpaceGen(int seed);
  
  // Methods
  void init();
  void tick();
  bool checkCivDoom(Civ civ);
  T pick<T>(List<T> items);
  bool probability(int n);
  int dice(int n);
  void logMessage(String message);
}
```

**Status**: 🔴 Not Implemented

---

#### Planet
```dart
class Planet {
  // Properties
  String name;
  int x, y;
  int pollution;
  bool habitable;
  int evoPoints;
  int evoNeeded;
  List<PlanetSpecial> specials;
  List<SpecialLifeform> lifeforms;
  List<Population> inhabitants;
  List<Artefact> artefacts;
  List<Structure> structures;
  List<Plague> plagues;
  List<Stratum> strata;
  Civ? owner;
  
  // Methods
  int population();
  void addPlague(Plague plague);
  void removePlague(Plague plague);
  void addArtefact(Artefact artefact);
  void removeArtefact(Artefact artefact);
  void addStructure(Structure structure);
  void removeStructure(Structure structure);
  void dePop(Population pop, int amount, Cataclysm? cause, String? reason, Plague? plague);
  void deCiv(int amount, Cataclysm? cause, String? reason);
  void deLive(int amount, Cataclysm? cause, String? reason);
  bool hasStructure(StructureType type);
}
```

**Status**: 🔴 Not Implemented

---

#### Civilization
```dart
class Civ {
  // Properties
  List<SentientType> fullMembers;
  Government govt;
  Map<Civ, DiplomacyOutcome> relations;
  int resources;
  int science;
  int military;
  int weapLevel;
  int techLevel;
  String name;
  int birthYear;
  int nextBreakthrough;
  int decrepitude;
  
  // Methods
  List<Planet> getColonies();
  List<Planet> fullColonies();
  List<Planet> reachables(SpaceGen sg);
  bool hasArtefact(ArtefactType type);
  Planet? leastPopulousFullColony();
  Planet? closestColony(Planet target);
  int population();
}
```

**Status**: 🔴 Not Implemented

---

#### Agent
```dart
class Agent {
  // Properties
  Planet location;
  AgentType type;
  int resources;
  int fleet;
  int birth;
  String name;
  SentientType? st;
  Civ? originator;
  int timer;
  Planet? target;
  String color;
  String mType;
  
  // Methods
  void setLocation(Planet planet);
}
```

**Status**: 🔴 Not Implemented

---

### Enumerations

#### Government
```dart
enum Government {
  dictatorship,
  theocracy,
  feudalState,
  republic;
  
  String get typeName;
  String get title;
  int get bombardProbability;
  List<SentientEncounterOutcome> get encounterOutcomes;
  List<CivAction> get behavior;
}
```

**Status**: 🔴 Not Implemented

---

#### AgentType
```dart
enum AgentType {
  spaceMonster,
  pirate,
  adventurer,
  refugee,
  merchant;
  
  void behave(Agent agent, SpaceGen sg);
}
```

**Status**: 🔴 Not Implemented

---

#### ArtefactType
```dart
enum ArtefactType {
  wreck,
  pirateHoard,
  timeIce,
  art,
  masterComputer,
  mindControlDevice,
  virtualRealityMatrix,
  planetDestroyer,
  teleportGate,
  universalAntidote,
  mindReader,
  stasisCapsule;
  
  String getName();
  bool isDevice();
}
```

**Status**: 🔴 Not Implemented

---

### Systems

#### PlanetEvolution
```dart
class PlanetEvolution {
  static void processPlanet(Planet planet, SpaceGen sg);
  static void handleLifeEmergence(Planet planet, SpaceGen sg);
  static void handleSentienceEmergence(Planet planet, SpaceGen sg);
  static void handleCataclysm(Planet planet, SpaceGen sg);
}
```

**Status**: 🔴 Not Implemented

---

#### WarSystem
```dart
class WarSystem {
  static void doWar(Civ civ, SpaceGen sg);
  static void resolveCombat(Civ attacker, Civ defender, Planet target, SpaceGen sg);
  static void bombardPlanet(Planet planet, Civ attacker, SpaceGen sg);
  static void invadePlanet(Planet planet, Civ attacker, Civ defender, SpaceGen sg);
}
```

**Status**: 🔴 Not Implemented

---

#### ScienceSystem
```dart
class ScienceSystem {
  static void processBreakthrough(Civ civ, SpaceGen sg);
  static void advanceTechnology(Civ civ, SpaceGen sg);
  static void createArtefact(Civ civ, Planet planet, SpaceGen sg);
  static void transcend(Civ civ, SpaceGen sg);
}
```

**Status**: 🔴 Not Implemented

---

### Animation System

#### Stage
```dart
class Stage {
  // Properties
  bool doTrack;
  List<Sprite> sprites;
  List<Animation> animations;
  double camX, camY;
  
  // Methods
  void animate(Animation anim);
  void animateAll(List<Animation> anims);
  bool tick();
  Animation delay(int ticks, Animation? next);
  Animation tracking(Sprite sprite, Animation? next);
  Animation move(Sprite sprite, double x, double y);
  Animation add(Sprite sprite, Sprite? parent);
  Animation remove(Sprite sprite);
}
```

**Status**: 🔴 Not Implemented

---

#### Sprite
```dart
class Sprite {
  // Properties
  double x, y;
  ui.Image? img;
  List<Sprite> children;
  Sprite? parent;
  bool highlight;
  bool flash;
  
  // Methods
  double globalX();
  double globalY();
}
```

**Status**: 🔴 Not Implemented

---

#### Animation
```dart
abstract class Animation {
  bool tick(Stage stage);
}

class DelayAnimation implements Animation { ... }
class MoveAnimation implements Animation { ... }
class TrackingAnimation implements Animation { ... }
class AddAnimation implements Animation { ... }
class RemoveAnimation implements Animation { ... }
class ChangeAnimation implements Animation { ... }
class SeqAnimation implements Animation { ... }
class SimAnimation implements Animation { ... }
```

**Status**: 🔴 Not Implemented

---

### Flutter UI

#### SpaceGenProvider
```dart
class SpaceGenProvider extends ChangeNotifier {
  SpaceGen? _spaceGen;
  bool _isRunning = false;
  Timer? _timer;
  
  SpaceGen? get spaceGen => _spaceGen;
  bool get isRunning => _isRunning;
  
  void initialize(int seed);
  void start();
  void pause();
  void step();
  void reset();
}
```

**Status**: 🔴 Not Implemented

---

#### GameScreen
```dart
class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(child: GameCanvas()),
          SizedBox(width: 300, child: InfoPanel()),
        ],
      ),
      bottomNavigationBar: ControlPanel(),
    );
  }
}
```

**Status**: 🔴 Not Implemented

---

#### GameCanvas
```dart
class GameCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SpaceGenProvider>(
      builder: (context, provider, child) {
        return CustomPaint(
          painter: GamePainter(provider.spaceGen?.stage),
          child: GestureDetector(
            onTapDown: (details) => _handleTap(details, provider),
            onScaleUpdate: (details) => _handleZoom(details, provider),
          ),
        );
      },
    );
  }
}
```

**Status**: 🔴 Not Implemented

---

## Usage Examples

### Creating a New Game

```dart
// Initialize SpaceGen with seed
final spaceGen = SpaceGen(12345);
spaceGen.init();

// Run simulation
while (true) {
  spaceGen.tick();
  
  // Check if interesting
  if (spaceGen.interesting()) {
    print('Interesting world generated!');
    break;
  }
}
```

**Status**: 🔴 Not Implemented

---

### Using with Flutter

```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SpaceGenProvider()..initialize(12345),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameScreen(),
    );
  }
}
```

**Status**: 🔴 Not Implemented

---

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models/planet_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Status**: 🔴 Not Implemented

---

## Common Patterns

### Random Selection
```dart
T pick<T>(List<T> items) {
  return items[random.nextInt(items.length)];
}
```

### Probability Check
```dart
bool probability(int n) {
  return dice(n) == 0;  // 1 in n chance
}

int dice(int n) {
  return random.nextInt(n);
}
```

### Logging with Substitution
```dart
void log(String message, {Planet? planet, Civ? civ}) {
  message = message
    .replaceAll('\$name', planet?.name ?? civ?.name ?? '')
    .replaceAll('\$pname', planet?.name ?? '');
  log.add(message);
}
```

### Safe Iteration with Modification
```dart
for (final item in List<T>.from(collection)) {
  if (condition) {
    collection.remove(item);
  }
}
```

---

## Differences from Java Version

### Language Differences

| Feature | Java | Dart |
|---------|------|------|
| Null Safety | `@Nullable` annotations | Built-in `?` operator |
| Collections | `ArrayList<T>` | `List<T>` |
| Generics | `<T>` | `<T>` (similar) |
| Enums | Limited | Enhanced with methods |
| Threading | `Thread` | `Timer`, `Future`, `async/await` |

### Architecture Differences

| Component | Java | Dart/Flutter |
|-----------|------|--------------|
| UI Framework | Swing/AWT | Flutter |
| Rendering | `Graphics2D` | `CustomPainter` |
| State Management | Manual | Provider/Riverpod |
| Animation | Manual timing | Built-in animation framework |
| Threading | Manual threads | Event loop + isolates |

---

## Performance Considerations

### Optimization Strategies

1. **Image Caching**
   - Cache loaded images
   - Limit cache size
   - Use LRU eviction

2. **Viewport Culling**
   - Only render visible sprites
   - Calculate visible bounds
   - Skip off-screen animations

3. **Efficient Collections**
   - Use appropriate data structures
   - Avoid unnecessary copies
   - Batch operations

4. **Animation Optimization**
   - Remove completed animations
   - Combine similar animations
   - Use hardware acceleration

---

## Known Issues

### Current Issues
- None yet (project not started)

### Planned Improvements
- TBD based on implementation

---

## Testing Strategy

### Unit Tests
- Test each class in isolation
- Mock dependencies
- Aim for >80% coverage

### Integration Tests
- Test system interactions
- Test complete game flow
- Test edge cases

### Widget Tests
- Test UI components
- Test user interactions
- Test state updates

### Performance Tests
- Profile rendering
- Profile tick processing
- Measure memory usage

---

## Development Workflow

### Setting Up Development Environment

```bash
# Install Flutter
# See: https://flutter.dev/docs/get-started/install

# Clone repository
git clone [repository-url]
cd dart_conversion

# Get dependencies
flutter pub get

# Run tests
flutter test

# Run app
flutter run
```

### Making Changes

1. Create feature branch
2. Implement changes
3. Write tests
4. Run tests
5. Update documentation
6. Submit pull request

### Code Style

- Follow Dart style guide
- Use `dart format` for formatting
- Use `dart analyze` for linting
- Document public APIs

---

## Resources

### Documentation
- [STAGED_CONVERSION_PLAN.md](STAGED_CONVERSION_PLAN.md) - Conversion plan
- [CONVERSION_STATUS.md](CONVERSION_STATUS.md) - Current status
- [DESIGN_ANALYSIS.md](../DESIGN_ANALYSIS.md) - Original design
- [FLUTTER_CONVERSION_GUIDE.md](../FLUTTER_CONVERSION_GUIDE.md) - Conversion guide

### External Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

---

## Contributing

### How to Contribute

1. Check CONVERSION_STATUS.md for current stage
2. Pick an uncompleted task
3. Follow development workflow
4. Submit pull request
5. Update status document

### Code Review Checklist

- [ ] Code follows Dart style guide
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
- [ ] Performance acceptable

---

## Version History

### v0.0.1 (In Development)
- Project initialized
- Documentation created
- Ready to begin Stage 0

---

## Contact

**Project Lead**: [Your Name]  
**Repository**: [Repository URL]  
**Issues**: [Issues URL]

---

*This quick reference is updated as the Dart version is developed. For the most current status, see CONVERSION_STATUS.md.*

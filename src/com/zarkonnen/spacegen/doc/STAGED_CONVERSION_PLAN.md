# SpaceGen Staged Conversion Plan

## Overview

This document outlines a **staged, incremental approach** to converting SpaceGen from Java to Dart/Flutter. Each stage can be completed independently, tested in isolation, and integrated progressively.

---

## Conversion Strategy

### Core Principles

1. **Incremental Development**: Convert one system at a time
2. **Continuous Testing**: Each stage includes unit tests
3. **Minimal Dependencies**: Start with foundation, build upward
4. **Parallel Development**: Some stages can be done simultaneously
5. **Stub Interfaces**: Use stubs for not-yet-converted systems
6. **Progressive Integration**: Integrate as each stage completes

### Dependency Graph

```
Stage 0: Foundation (Required for all)
    ↓
Stage 1: Enumerations (Required for models)
    ↓
Stage 2: Basic Models (Planet, Civ, Agent, Population)
    ↓
    ├─→ Stage 3: Planet System (Independent)
    ├─→ Stage 4: Civilization System (Independent)
    ├─→ Stage 5: Agent System (Independent)
    └─→ Stage 6: Animation System (Independent)
    ↓
Stage 7: Integration Systems (War, Diplomacy, Science)
    ↓
Stage 8: Core Engine (SpaceGen)
    ↓
Stage 9: Flutter UI
    ↓
Stage 10: Polish & Optimization
```

---

## Stage 0: Foundation Setup

**Duration**: 1-2 hours  
**Dependencies**: None  
**Can Start**: Immediately

### Goals
- Set up Dart project structure
- Configure dependencies
- Create utility classes
- Establish testing framework

### Deliverables

#### Files to Create
```
dart_conversion/
├── pubspec.yaml
├── analysis_options.yaml
├── lib/
│   ├── utils/
│   │   ├── random_utils.dart
│   │   ├── constants.dart
│   │   └── name_generator.dart
│   └── core/
│       └── game_logger.dart
└── test/
    └── utils/
        └── random_utils_test.dart
```

### Tasks
- [ ] Create `pubspec.yaml` with dependencies
- [ ] Set up `analysis_options.yaml` for linting
- [ ] Implement `RandomUtils` class
- [ ] Implement `Constants` class
- [ ] Implement `NameGenerator` class
- [ ] Implement `GameLogger` class
- [ ] Write unit tests for utilities
- [ ] Document utility APIs

### Testing Strategy
```dart
// Test random utilities
test('probability distribution', () { ... });
test('dice rolling', () { ... });
test('pick from list', () { ... });

// Test name generation
test('generate planet names', () { ... });
test('generate civ names', () { ... });
```

### Success Criteria
- ✓ All utility tests pass
- ✓ Random number generation is deterministic with seed
- ✓ Name generation produces valid names
- ✓ Logger captures messages correctly

---

## Stage 1: Enumerations

**Duration**: 2-3 hours  
**Dependencies**: Stage 0  
**Can Start**: After Stage 0

### Goals
- Convert all Java enums to Dart
- Implement enum behaviors
- Create enum utilities

### Deliverables

#### Files to Create
```
lib/enums/
├── government.dart
├── agent_type.dart
├── artefact_type.dart
├── cataclysm.dart
├── planet_special.dart
├── special_lifeform.dart
├── structure_type.dart
├── sentient_base.dart
├── sentient_encounter_outcome.dart
├── civ_action.dart
├── bad_civ_event.dart
└── diplomacy_outcome.dart
```

### Tasks
- [ ] Convert `Government` enum
- [ ] Convert `AgentType` enum
- [ ] Convert `ArtefactType` enum
- [ ] Convert `Cataclysm` enum
- [ ] Convert `PlanetSpecial` enum
- [ ] Convert `SpecialLifeform` enum
- [ ] Convert `StructureType` enum
- [ ] Convert `SentientBase` enum
- [ ] Convert `SentientEncounterOutcome` enum
- [ ] Convert `CivAction` enum (stub behaviors)
- [ ] Convert `BadCivEvent` enum (stub behaviors)
- [ ] Convert `DiplomacyOutcome` enum
- [ ] Write enum tests

### Testing Strategy
```dart
// Test enum properties
test('government has correct properties', () { ... });
test('artefact types categorized correctly', () { ... });

// Test enum behaviors (stubs for now)
test('civ action stubs work', () { ... });
```

### Success Criteria
- ✓ All enums converted with properties
- ✓ Enum tests pass
- ✓ Behavior stubs in place (to be implemented later)
- ✓ Documentation complete

---

## Stage 2: Basic Models

**Duration**: 3-4 hours  
**Dependencies**: Stage 0, Stage 1  
**Can Start**: After Stage 1

### Goals
- Create core data models
- Implement basic properties and constructors
- Stub out complex methods

### Deliverables

#### Files to Create
```
lib/models/
├── planet.dart
├── civilization.dart
├── agent.dart
├── population.dart
├── sentient_type.dart
├── artefact.dart
├── structure.dart
├── plague.dart
└── strata/
    ├── stratum.dart
    ├── fossil.dart
    ├── remnant.dart
    ├── ruin.dart
    └── lost_artefact.dart
```

### Tasks
- [ ] Create `Planet` model (properties only)
- [ ] Create `Civilization` model (properties only)
- [ ] Create `Agent` model (properties only)
- [ ] Create `Population` model (properties only)
- [ ] Create `SentientType` model
- [ ] Create `Artefact` model
- [ ] Create `Structure` model
- [ ] Create `Plague` model
- [ ] Create `Stratum` interface and implementations
- [ ] Add basic getters/setters
- [ ] Stub complex methods
- [ ] Write model tests

### Testing Strategy
```dart
// Test model creation
test('create planet with properties', () { ... });
test('create civilization with properties', () { ... });

// Test relationships
test('planet can have owner', () { ... });
test('civ can have colonies', () { ... });
```

### Success Criteria
- ✓ All models created with properties
- ✓ Basic tests pass
- ✓ Models can be instantiated
- ✓ Relationships defined (but not fully implemented)

---

## Stage 3: Planet System

**Duration**: 4-6 hours  
**Dependencies**: Stage 2  
**Can Start**: After Stage 2  
**Parallel**: Can work alongside Stage 4, 5, 6

### Goals
- Implement complete Planet logic
- Evolution system
- Population dynamics
- Cataclysm handling
- Strata management

### Deliverables

#### Files to Implement
```
lib/models/planet.dart (complete implementation)
lib/systems/planet_evolution.dart
lib/systems/planet_events.dart
test/models/planet_test.dart
test/systems/planet_evolution_test.dart
```

### Tasks
- [ ] Implement `Planet.population()` getter
- [ ] Implement `Planet.addPlague()` / `removePlague()`
- [ ] Implement `Planet.addArtefact()` / `removeArtefact()`
- [ ] Implement `Planet.addStructure()` / `removeStructure()`
- [ ] Implement `Planet.dePop()` (depopulation with strata)
- [ ] Implement `Planet.deCiv()` (civilization collapse)
- [ ] Implement `Planet.deLive()` (extinction)
- [ ] Implement `Planet.hasStructure()`
- [ ] Create `PlanetEvolution` system
- [ ] Create `PlanetEvents` system
- [ ] Implement evolution point accumulation
- [ ] Implement life emergence logic
- [ ] Implement sentience emergence logic
- [ ] Implement cataclysm logic
- [ ] Implement pollution mechanics
- [ ] Write comprehensive tests

### Testing Strategy
```dart
// Test population management
test('planet tracks total population', () { ... });
test('depopulation adds to strata', () { ... });

// Test evolution
test('evolution points accumulate', () { ... });
test('life emerges when threshold reached', () { ... });
test('sentience emerges from life', () { ... });

// Test cataclysms
test('cataclysm kills all life', () { ... });
test('cataclysm creates fossils', () { ... });

// Test strata
test('strata preserves history', () { ... });
test('erosion removes old strata', () { ... });
```

### Success Criteria
- ✓ All Planet methods implemented
- ✓ Evolution system works correctly
- ✓ Cataclysms handled properly
- ✓ Strata system preserves history
- ✓ All tests pass (>90% coverage)

---

## Stage 4: Civilization System

**Duration**: 5-7 hours  
**Dependencies**: Stage 2  
**Can Start**: After Stage 2  
**Parallel**: Can work alongside Stage 3, 5, 6

### Goals
- Implement complete Civilization logic
- Resource management
- Science accumulation
- Technology advancement
- Government behaviors
- Colony management

### Deliverables

#### Files to Implement
```
lib/models/civilization.dart (complete implementation)
lib/systems/civ_resources.dart
lib/systems/civ_science.dart
lib/systems/civ_behaviors.dart
lib/systems/civ_events.dart
test/models/civilization_test.dart
test/systems/civ_resources_test.dart
test/systems/civ_science_test.dart
```

### Tasks
- [ ] Implement `Civ.getColonies()`
- [ ] Implement `Civ.fullColonies()`
- [ ] Implement `Civ.reachables()`
- [ ] Implement `Civ.hasArtefact()`
- [ ] Implement `Civ.leastPopulousFullColony()`
- [ ] Implement `Civ.closestColony()`
- [ ] Implement `Civ.population()`
- [ ] Create `CivResources` system
- [ ] Create `CivScience` system
- [ ] Create `CivBehaviors` system
- [ ] Create `CivEvents` system
- [ ] Implement resource generation
- [ ] Implement science accumulation
- [ ] Implement technology breakthroughs
- [ ] Implement government-specific behaviors
- [ ] Implement decrepitude system
- [ ] Implement random events
- [ ] Write comprehensive tests

### Testing Strategy
```dart
// Test colony management
test('civ tracks colonies correctly', () { ... });
test('civ finds reachable planets', () { ... });

// Test resources
test('resources generated from colonies', () { ... });
test('resources consumed by actions', () { ... });

// Test science
test('science accumulates from colonies', () { ... });
test('breakthroughs occur at threshold', () { ... });

// Test behaviors
test('government affects behavior', () { ... });
test('decrepitude increases with age', () { ... });

// Test events
test('random events occur', () { ... });
test('events affect civ state', () { ... });
```

### Success Criteria
- ✓ All Civilization methods implemented
- ✓ Resource system works correctly
- ✓ Science system works correctly
- ✓ Behaviors execute properly
- ✓ Events trigger appropriately
- ✓ All tests pass (>90% coverage)

---

## Stage 5: Agent System

**Duration**: 3-4 hours  
**Dependencies**: Stage 2  
**Can Start**: After Stage 2  
**Parallel**: Can work alongside Stage 3, 4, 6

### Goals
- Implement complete Agent logic
- Agent behaviors (monster, pirate, adventurer, etc.)
- Agent movement
- Agent interactions

### Deliverables

#### Files to Implement
```
lib/models/agent.dart (complete implementation)
lib/systems/agent_behaviors.dart
test/models/agent_test.dart
test/systems/agent_behaviors_test.dart
```

### Tasks
- [ ] Implement `Agent.setLocation()`
- [ ] Create `AgentBehaviors` system
- [ ] Implement Space Monster behavior
- [ ] Implement Pirate behavior
- [ ] Implement Adventurer behavior
- [ ] Implement Refugee behavior
- [ ] Implement Merchant behavior
- [ ] Implement agent spawning logic
- [ ] Implement agent movement
- [ ] Implement agent-planet interactions
- [ ] Implement agent-civ interactions
- [ ] Write comprehensive tests

### Testing Strategy
```dart
// Test agent creation
test('agent spawns with correct type', () { ... });
test('agent has location', () { ... });

// Test behaviors
test('space monster attacks populations', () { ... });
test('pirate raids civilizations', () { ... });
test('adventurer discovers artefacts', () { ... });
test('refugee seeks safe planets', () { ... });
test('merchant trades between civs', () { ... });

// Test movement
test('agent moves to new location', () { ... });
test('agent respects movement rules', () { ... });
```

### Success Criteria
- ✓ All Agent methods implemented
- ✓ All agent behaviors work correctly
- ✓ Agent interactions function properly
- ✓ All tests pass (>90% coverage)

---

## Stage 6: Animation System (Headless)

**Duration**: 4-5 hours  
**Dependencies**: Stage 2  
**Can Start**: After Stage 2  
**Parallel**: Can work alongside Stage 3, 4, 5

### Goals
- Implement animation system without rendering
- Sprite hierarchy
- Animation queue
- Camera system
- Prepare for Flutter integration

### Deliverables

#### Files to Create
```
lib/rendering/
├── stage.dart
├── sprite.dart
├── animations/
│   ├── animation.dart
│   ├── delay_animation.dart
│   ├── move_animation.dart
│   ├── tracking_animation.dart
│   ├── add_animation.dart
│   ├── remove_animation.dart
│   ├── change_animation.dart
│   ├── seq_animation.dart
│   └── sim_animation.dart
└── camera.dart
test/rendering/
├── stage_test.dart
└── animations/
    └── animation_test.dart
```

### Tasks
- [ ] Create `Sprite` class
- [ ] Create `Stage` class
- [ ] Create `Animation` interface
- [ ] Implement `DelayAnimation`
- [ ] Implement `MoveAnimation`
- [ ] Implement `TrackingAnimation`
- [ ] Implement `AddAnimation`
- [ ] Implement `RemoveAnimation`
- [ ] Implement `ChangeAnimation`
- [ ] Implement `SeqAnimation`
- [ ] Implement `SimAnimation`
- [ ] Implement camera system
- [ ] Implement sprite hierarchy
- [ ] Implement animation queue
- [ ] Write comprehensive tests

### Testing Strategy
```dart
// Test sprite hierarchy
test('sprite has parent-child relationships', () { ... });
test('sprite calculates global position', () { ... });

// Test animations
test('delay animation waits', () { ... });
test('move animation changes position', () { ... });
test('tracking animation follows sprite', () { ... });

// Test stage
test('stage manages sprites', () { ... });
test('stage processes animation queue', () { ... });
test('stage updates camera', () { ... });
```

### Success Criteria
- ✓ All animation classes implemented
- ✓ Sprite hierarchy works correctly
- ✓ Animation queue processes correctly
- ✓ Camera system functions
- ✓ All tests pass (>90% coverage)
- ✓ Ready for Flutter rendering integration

---

## Stage 7: Integration Systems

**Duration**: 6-8 hours  
**Dependencies**: Stage 3, 4, 5  
**Can Start**: After Stages 3, 4, 5 complete  
**Parallel**: Cannot be parallelized

### Goals
- Implement War system
- Implement Diplomacy system
- Implement Science system
- Integrate all systems

### Deliverables

#### Files to Create
```
lib/systems/
├── war_system.dart
├── diplomacy_system.dart
├── science_system.dart
└── integration_manager.dart
test/systems/
├── war_system_test.dart
├── diplomacy_system_test.dart
└── science_system_test.dart
```

### Tasks
- [ ] Create `WarSystem` class
- [ ] Implement war declaration logic
- [ ] Implement combat resolution
- [ ] Implement bombardment
- [ ] Implement invasion
- [ ] Implement population fate determination
- [ ] Create `DiplomacySystem` class
- [ ] Implement relationship management
- [ ] Implement peace treaties
- [ ] Implement alliances
- [ ] Create `ScienceSystem` class
- [ ] Implement science breakthroughs
- [ ] Implement technology advancement
- [ ] Implement artefact creation
- [ ] Implement transcendence
- [ ] Create integration tests
- [ ] Write comprehensive tests

### Testing Strategy
```dart
// Test war system
test('war declared between enemies', () { ... });
test('combat resolves correctly', () { ... });
test('bombardment increases pollution', () { ... });
test('invasion transfers ownership', () { ... });

// Test diplomacy
test('relationships tracked correctly', () { ... });
test('peace treaties end wars', () { ... });

// Test science
test('breakthroughs occur at threshold', () { ... });
test('technology advances', () { ... });
test('artefacts created', () { ... });

// Integration tests
test('war affects diplomacy', () { ... });
test('science affects war capability', () { ... });
```

### Success Criteria
- ✓ War system fully functional
- ✓ Diplomacy system fully functional
- ✓ Science system fully functional
- ✓ Systems integrate correctly
- ✓ All tests pass (>90% coverage)

---

## Stage 8: Core Engine (SpaceGen)

**Duration**: 5-6 hours  
**Dependencies**: All previous stages  
**Can Start**: After Stage 7  
**Parallel**: Cannot be parallelized

### Goals
- Implement SpaceGen core engine
- Integrate all systems
- Implement tick processing
- Implement game loop

### Deliverables

#### Files to Create
```
lib/core/
├── space_gen.dart
├── game_state.dart
└── tick_processor.dart
test/core/
├── space_gen_test.dart
└── integration_test.dart
```

### Tasks
- [ ] Create `SpaceGen` class
- [ ] Implement `init()` method
- [ ] Implement `tick()` method
- [ ] Implement 5-phase tick processing
- [ ] Implement `checkCivDoom()`
- [ ] Implement `interesting()` check
- [ ] Integrate Planet system
- [ ] Integrate Civilization system
- [ ] Integrate Agent system
- [ ] Integrate War system
- [ ] Integrate Diplomacy system
- [ ] Integrate Science system
- [ ] Implement event logging
- [ ] Implement game state management
- [ ] Write comprehensive integration tests

### Testing Strategy
```dart
// Test initialization
test('spacegen initializes correctly', () { ... });
test('planets created on init', () { ... });

// Test tick processing
test('tick processes all phases', () { ... });
test('tick updates game state', () { ... });

// Test doom check
test('civ doom detected correctly', () { ... });
test('doomed civs removed', () { ... });

// Integration tests
test('complete game simulation runs', () { ... });
test('deterministic with same seed', () { ... });
test('interesting worlds detected', () { ... });
```

### Success Criteria
- ✓ SpaceGen engine fully functional
- ✓ All systems integrated
- ✓ Tick processing works correctly
- ✓ Game loop stable
- ✓ All tests pass (>95% coverage)
- ✓ Can run headless simulation

---

## Stage 9: Flutter UI

**Duration**: 8-10 hours  
**Dependencies**: Stage 6, 8  
**Can Start**: After Stage 8  
**Parallel**: Cannot be parallelized

### Goals
- Create Flutter UI
- Integrate rendering
- Implement controls
- Implement displays

### Deliverables

#### Files to Create
```
lib/
├── main.dart
├── ui/
│   ├── screens/
│   │   ├── game_screen.dart
│   │   └── menu_screen.dart
│   ├── widgets/
│   │   ├── game_canvas.dart
│   │   ├── log_display.dart
│   │   ├── info_panel.dart
│   │   └── control_panel.dart
│   └── theme.dart
├── providers/
│   └── space_gen_provider.dart
└── rendering/
    ├── game_painter.dart
    └── sprite_renderer.dart
test/ui/
└── widget_test.dart
```

### Tasks
- [ ] Create Flutter app structure
- [ ] Create `SpaceGenProvider` for state management
- [ ] Create `GameScreen` widget
- [ ] Create `GameCanvas` with CustomPainter
- [ ] Implement `GamePainter` for rendering
- [ ] Create `LogDisplay` widget
- [ ] Create `InfoPanel` widget
- [ ] Create `ControlPanel` widget
- [ ] Implement sprite rendering
- [ ] Implement animation rendering
- [ ] Implement camera controls
- [ ] Implement game controls (play/pause/step)
- [ ] Implement planet selection
- [ ] Implement info displays
- [ ] Add theme and styling
- [ ] Write widget tests

### Testing Strategy
```dart
// Widget tests
testWidgets('game screen renders', (tester) async { ... });
testWidgets('canvas displays sprites', (tester) async { ... });
testWidgets('log displays messages', (tester) async { ... });
testWidgets('controls work', (tester) async { ... });

// Integration tests
testWidgets('complete game flow', (tester) async { ... });
```

### Success Criteria
- ✓ Flutter app runs
- ✓ Game renders correctly
- ✓ Controls work
- ✓ Displays show correct information
- ✓ Performance acceptable (60 FPS)
- ✓ Widget tests pass

---

## Stage 10: Polish & Optimization

**Duration**: 4-6 hours  
**Dependencies**: Stage 9  
**Can Start**: After Stage 9  
**Parallel**: Cannot be parallelized

### Goals
- Optimize performance
- Add polish features
- Improve UX
- Final testing

### Tasks
- [ ] Profile performance
- [ ] Optimize rendering
- [ ] Implement viewport culling
- [ ] Optimize animation processing
- [ ] Add loading screens
- [ ] Add transitions
- [ ] Improve error handling
- [ ] Add analytics/debugging tools
- [ ] Final integration testing
- [ ] Performance testing
- [ ] User acceptance testing
- [ ] Documentation updates

### Success Criteria
- ✓ Performance optimized (60 FPS)
- ✓ No memory leaks
- ✓ Smooth animations
- ✓ Good UX
- ✓ All tests pass
- ✓ Documentation complete

---

## Parallel Development Strategy

### Week 1
- **Day 1**: Stage 0 (Foundation)
- **Day 2**: Stage 1 (Enumerations)
- **Day 3**: Stage 2 (Basic Models)
- **Day 4-5**: Stage 3 (Planet System)

### Week 2
- **Day 1-2**: Stage 4 (Civilization System)
- **Day 3**: Stage 5 (Agent System)
- **Day 4-5**: Stage 6 (Animation System)

### Week 3
- **Day 1-3**: Stage 7 (Integration Systems)
- **Day 4-5**: Stage 8 (Core Engine)

### Week 4
- **Day 1-4**: Stage 9 (Flutter UI)
- **Day 5**: Stage 10 (Polish)

### Alternative: Multiple Developers

If you have multiple developers:

**Developer A**: Stages 0, 1, 2 → Stage 3 → Stage 7 → Stage 8
**Developer B**: Stage 4 → Stage 7 (assist) → Stage 9
**Developer C**: Stage 5 → Stage 6 → Stage 9 (assist)

---

## Testing Strategy

### Unit Tests
- Each stage includes unit tests
- Minimum 80% coverage per stage
- Tests written alongside implementation

### Integration Tests
- Stage 7 includes integration tests
- Stage 8 includes full system tests
- Stage 9 includes UI integration tests

### Regression Tests
- Run all previous stage tests after each new stage
- Ensure no breaking changes
- Maintain test suite

---

## Documentation Strategy

### Per-Stage Documentation
- Each stage updates `CONVERSION_STATUS.md`
- Each stage includes API documentation
- Each stage includes usage examples

### Wiki Updates
- Update wiki after each stage completion
- Document known issues
- Document workarounds
- Document next steps

---

## Risk Management

### Potential Issues

1. **Dependency Conflicts**
   - **Risk**: Later stages depend on earlier stages
   - **Mitigation**: Use stubs and interfaces
   - **Fallback**: Implement minimal version first

2. **Integration Problems**
   - **Risk**: Systems don't integrate smoothly
   - **Mitigation**: Integration tests at each stage
   - **Fallback**: Refactor interfaces

3. **Performance Issues**
   - **Risk**: Dart/Flutter slower than Java
   - **Mitigation**: Profile early and often
   - **Fallback**: Optimize critical paths

4. **Scope Creep**
   - **Risk**: Adding features during conversion
   - **Mitigation**: Strict adherence to plan
   - **Fallback**: Feature freeze until complete

---

## Success Metrics

### Per-Stage Metrics
- [ ] All tasks completed
- [ ] All tests passing
- [ ] Code coverage > 80%
- [ ] Documentation complete
- [ ] No critical bugs

### Overall Metrics
- [ ] All stages completed
- [ ] Full system functional
- [ ] Performance acceptable
- [ ] User acceptance passed
- [ ] Documentation complete

---

## Next Steps

1. **Review this plan** with team
2. **Set up Stage 0** (Foundation)
3. **Begin Stage 1** (Enumerations)
4. **Update status** after each stage
5. **Iterate and improve** as needed

---

*This staged conversion plan ensures a systematic, testable, and manageable approach to converting SpaceGen to Dart/Flutter.*

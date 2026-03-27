# SpaceGen UML Diagrams

## Complete System Class Diagram

```mermaid
classDiagram
    class SpaceGen {
        -Random random
        -List~String~ log
        -List~Planet~ planets
        -List~Civ~ civs
        -List~Agent~ agents
        -List~String~ historicalCivNames
        -List~String~ turnLog
        -int year
        -int age
        -bool hadCivs
        +init()
        +tick()
        +checkCivDoom(Civ) bool
        +pick~T~(List~T~) T
        +probability(int) bool
        +dice(int) int
        +logMessage(String)
    }
    
    class Planet {
        -String name
        -int x, y
        -int pollution
        -bool habitable
        -int evoPoints
        -int evoNeeded
        -List~PlanetSpecial~ specials
        -List~SpecialLifeform~ lifeforms
        -List~Population~ inhabitants
        -List~Artefact~ artefacts
        -List~Structure~ structures
        -List~Plague~ plagues
        -List~Stratum~ strata
        -Civ owner
        -PlanetSprite sprite
        +population() int
        +addPlague(Plague)
        +removePlague(Plague)
        +addArtefact(Artefact)
        +removeArtefact(Artefact)
        +addStructure(Structure)
        +removeStructure(Structure)
        +addLifeform(SpecialLifeform)
        +dePop(Population, int, Cataclysm, String, Plague)
        +deCiv(int, Cataclysm, String)
        +deLive(int, Cataclysm, String)
        +hasStructure(StructureType) bool
    }
    
    class Civ {
        -List~SentientType~ fullMembers
        -Government govt
        -Map~Civ,DiplomacyOutcome~ relations
        -int resources
        -int science
        -int military
        -int weapLevel
        -int techLevel
        -String name
        -int birthYear
        -int nextBreakthrough
        -int decrepitude
        -List~CivSprite~ sprites
        -SpaceGen sg
        +getColonies() List~Planet~
        +fullColonies() List~Planet~
        +reachables(SpaceGen) List~Planet~
        +hasArtefact(ArtefactType) bool
        +leastPopulousFullColony() Planet
        +closestColony(Planet) Planet
        +population() int
    }
    
    class Agent {
        -Planet location
        -AgentType type
        -int resources
        -int fleet
        -int birth
        -String name
        -SentientType st
        -Civ originator
        -int timer
        -Planet target
        -String color
        -String mType
        -Sprite sprite
        -SpaceGen sg
        +setLocation(Planet)
    }
    
    class Population {
        -SentientType type
        -int size
        -Planet planet
        -Sprite sprite
        +send(Planet)
        +eliminate()
        +update()
        +addUpdateImgs()
    }
    
    class SentientType {
        -SentientBase base
        -String prefix
        -String suffix
        -List~String~ traits
        +getName() String
        +getDesc() String
        +mutate(SpaceGen, Planet) SentientType
        +invent(SpaceGen, Civ, Planet, SentientBase) SentientType
    }
    
    class Artefact {
        -int created
        -Civ creator
        -ArtefactType type
        -String desc
        -SentientType st
        -int creatorTechLevel
        -String creatorName
        -Sprite sprite
        -SentientType containedST
        -Artefact containedArtefact
        -Agent containedAgent
        +toString() String
    }
    
    class Structure {
        -StructureType type
        -Civ builders
        -int buildTime
        -Sprite sprite
        +toString() String
    }
    
    class Plague {
        -String name
        -List~SentientType~ affects
        -int lethality
        -int transmissivity
        -int mutationRate
        -int curability
    }
    
    class Stratum {
        <<interface>>
        +time() int
    }
    
    class Fossil {
        -SentientType species
        -int time
        -Cataclysm cause
        +time() int
    }
    
    class Remnant {
        -Population population
        -int time
        -Cataclysm cause
        -String reason
        -Plague plague
        +time() int
    }
    
    class Ruin {
        -Structure structure
        -int time
        -Cataclysm cause
        -String reason
        +time() int
    }
    
    class LostArtefact {
        -String status
        -int time
        -Artefact artefact
        +time() int
    }
    
    class Stage {
        -bool doTrack
        -List~Sprite~ sprites
        -List~Animation~ animations
        -double camX, camY
        +animate(Animation)
        +animateAll(List~Animation~)
        +tick() bool
        +delay(int, Animation) Animation
        +tracking(Sprite, Animation) Animation
        +move(Sprite, double, double) Animation
        +add(Sprite, Sprite) Animation
        +remove(Sprite) Animation
    }
    
    class Sprite {
        -double x, y
        -Image img
        -List~Sprite~ children
        -Sprite parent
        -bool highlight
        -bool flash
        +globalX() double
        +globalY() double
    }
    
    class Animation {
        <<interface>>
        +tick(Stage) bool
    }
    
    class GameWorld {
        -SpaceGen sg
        -Stage stage
        -int sx, sy, cooldown
        -bool confirm
        -bool confirmNeeded
        -bool autorun
        +tick()
        +subTick() bool
    }
    
    SpaceGen "1" --> "*" Planet : manages
    SpaceGen "1" --> "*" Civ : manages
    SpaceGen "1" --> "*" Agent : manages
    Planet "1" --> "*" Population : contains
    Planet "1" --> "*" Artefact : contains
    Planet "1" --> "*" Structure : contains
    Planet "1" --> "*" Plague : contains
    Planet "1" --> "*" Stratum : contains
    Planet "*" --> "0..1" Civ : owned by
    Civ "1" --> "*" Planet : controls
    Agent "*" --> "1" Planet : located at
    Population "*" --> "1" Planet : lives on
    Population "*" --> "1" SentientType : is of type
    Artefact "*" --> "0..1" Civ : created by
    Structure "*" --> "1" Civ : built by
    Stratum <|-- Fossil : implements
    Stratum <|-- Remnant : implements
    Stratum <|-- Ruin : implements
    Stratum <|-- LostArtefact : implements
    GameWorld "1" --> "1" SpaceGen : contains
    GameWorld "1" --> "1" Stage : contains
    Stage "1" --> "*" Sprite : manages
    Stage "1" --> "*" Animation : manages
    Sprite "1" --> "*" Sprite : parent-child
```

---

## Enumeration Diagrams

### Government System

```mermaid
classDiagram
    class Government {
        <<enumeration>>
        DICTATORSHIP
        THEOCRACY
        FEUDAL_STATE
        REPUBLIC
        +String typeName
        +String title
        +int bombardProbability
        +List~SentientEncounterOutcome~ encounterOutcomes
        +List~CivAction~ behavior
    }
    
    class SentientEncounterOutcome {
        <<enumeration>>
        EXTERMINATE
        EXTERMINATE_FAIL
        IGNORE
        SUBJUGATE
        GIVE_FULL_MEMBERSHIP
    }
    
    class CivAction {
        <<enumeration>>
        EXPLORE_PLANET
        COLONISE_PLANET
        BUILD_SCIENCE_OUTPOST
        BUILD_MINING_BASE
        BUILD_MILITARY_BASE
        BUILD_WARSHIPS
        BUILD_CONSTRUCTION
        DO_RESEARCH
        +invoke(Civ, SpaceGen)
    }
    
    Government --> SentientEncounterOutcome : uses
    Government --> CivAction : uses
```

### Artefact System

```mermaid
classDiagram
    class ArtefactType {
        <<enumeration>>
        WRECK
        PIRATE_HOARD
        TIME_ICE
        ART
        MASTER_COMPUTER
        MIND_CONTROL_DEVICE
        VIRTUAL_REALITY_MATRIX
        PLANET_DESTROYER
        TELEPORT_GATE
        UNIVERSAL_ANTIDOTE
        MIND_READER
        STASIS_CAPSULE
        +getName() String
        +isDevice() bool
    }
    
    class Artefact {
        -ArtefactType type
        -Civ creator
        -int created
        -String desc
        -int creatorTechLevel
    }
    
    Artefact --> ArtefactType : has type
```

### Planet Features

```mermaid
classDiagram
    class PlanetSpecial {
        <<enumeration>>
        POISON_WORLD
        GEM_WORLD
        TITANIC_MOUNTAINS
        VAST_CANYONS
        DEEP_IMPENETRABLE_SEAS
        BEAUTIFUL_AURORAE
        GIGANTIC_CAVE_NETWORK
        TIDALLY_LOCKED_TO_STAR
        MUSICAL_CAVES
        ICE_PLANET
        PERIODICAL_DARKNESS
        HUGE_PLAINS
        +String announcement
        +String explanation
        +apply(Planet)
    }
    
    class SpecialLifeform {
        <<enumeration>>
        VAST_HERDS
        GIANT_TREES
        SINGING_CRYSTALS
        BIOLUMINESCENT_FUNGI
        TELEPATHIC_PLANTS
        +String name
        +String description
    }
    
    class Cataclysm {
        <<enumeration>>
        NOVA
        VOLCANIC_ERUPTIONS
        AXIAL_SHIFT
        METEORITE_IMPACT
        NANOFUNGAL_BLOOM
        PSIONIC_SHOCKWAVE
        +String name
        +String desc
    }
    
    class Planet {
        -List~PlanetSpecial~ specials
        -List~SpecialLifeform~ lifeforms
    }
    
    Planet --> PlanetSpecial : has
    Planet --> SpecialLifeform : has
    Planet ..> Cataclysm : affected by
```

### Agent System

```mermaid
classDiagram
    class AgentType {
        <<enumeration>>
        SPACE_MONSTER
        PIRATE
        ADVENTURER
        REFUGEE
        MERCHANT
        +behave(Agent, SpaceGen)
    }
    
    class Agent {
        -AgentType type
        -Planet location
        -String name
        -int resources
        -int fleet
    }
    
    Agent --> AgentType : has type
```

### Sentient Species System

```mermaid
classDiagram
    class SentientBase {
        <<enumeration>>
        HUMANOIDS
        ANTOIDS
        KOBOLDOIDS
        CATOIDS
        TROLLOIDS
        PARASITES
        ROBOTS
        +String name
        +List~CivAction~ behavior
        +StructureType specialStructure
    }
    
    class SentientType {
        -SentientBase base
        -String prefix
        -String suffix
        -List~String~ traits
        +getName() String
        +getDesc() String
    }
    
    class Population {
        -SentientType type
        -int size
    }
    
    SentientType --> SentientBase : based on
    Population --> SentientType : is of type
```

---

## Sequence Diagrams

### Game Initialization

```mermaid
sequenceDiagram
    participant Main
    participant GameWorld
    participant SpaceGen
    participant Planet
    participant Stage
    
    Main->>GameWorld: new GameWorld()
    GameWorld->>Stage: new Stage()
    Main->>GameWorld: tick()
    GameWorld->>SpaceGen: new SpaceGen(seed)
    GameWorld->>SpaceGen: init()
    SpaceGen->>SpaceGen: log("IN THE BEGINNING...")
    loop 6-30 times
        SpaceGen->>Planet: new Planet(random, this)
        Planet-->>SpaceGen: planet
        SpaceGen->>Stage: animate(add(planet.sprite))
    end
    SpaceGen->>Main: confirm()
```

### Civilization Tick

```mermaid
sequenceDiagram
    participant SpaceGen
    participant Civ
    participant Planet
    participant Population
    participant Science
    participant War
    
    SpaceGen->>SpaceGen: tick()
    loop for each civ
        SpaceGen->>Civ: checkCivDoom()
        Civ-->>SpaceGen: alive/dead
        
        alt civ alive
            loop for each colony
                Civ->>Planet: calculate resources
                Planet-->>Civ: resources
                Civ->>Planet: calculate science
                Planet-->>Civ: science
            end
            
            Civ->>Civ: execute behavior
            Civ->>Civ: update science
            
            alt science >= breakthrough
                Civ->>Science: advance(civ, sg)
                Science-->>Civ: result
            end
            
            Civ->>Civ: update decrepitude
            
            alt random event
                Civ->>Civ: execute event
            end
            
            SpaceGen->>War: doWar(civ, sg)
        end
    end
```

### Planet Evolution

```mermaid
sequenceDiagram
    participant SpaceGen
    participant Planet
    participant Population
    participant Civ
    
    SpaceGen->>Planet: tick evolution
    
    alt cataclysm (1/500)
        Planet->>Planet: deLive()
        Planet->>Planet: add fossils to strata
        Planet->>Planet: clear all life
    else pollution reduction (1/200)
        Planet->>Planet: pollution--
    else planet special (probability)
        Planet->>Planet: add special feature
    else evolution event
        alt not habitable
            Planet->>Planet: habitable = true
        else has inhabitants
            alt has owner
                Note over Planet: Already civilized
            else no owner
                Planet->>Population: pick starter
                Population->>Civ: new Civ()
                Civ->>Planet: setOwner(civ)
            end
        else no inhabitants
            alt sentient emergence
                Planet->>Population: new Population(sentient)
            else lifeform emergence
                Planet->>Planet: add special lifeform
            end
        end
    end
```

### War Resolution

```mermaid
sequenceDiagram
    participant War
    participant Attacker
    participant Defender
    participant Planet
    participant SpaceGen
    
    War->>Attacker: find enemies
    Attacker-->>War: enemy list
    
    alt has enemies
        War->>War: pick defender
        War->>War: calculate strength
        
        alt attacker has resources
            Attacker->>Attacker: resources -= 2
            War->>Attacker: find reachable targets
            
            alt has targets
                War->>War: pick target
                
                alt attacker stronger
                    alt bombardment
                        War->>Planet: increase pollution
                        War->>Planet: kill population
                    else invasion
                        loop for each population
                            War->>War: determine fate
                            alt exterminate
                                Planet->>Planet: dePop()
                            else subjugate
                                Planet->>Planet: update sprites
                            else give membership
                                Attacker->>Attacker: add to fullMembers
                            end
                        end
                        Planet->>Attacker: setOwner()
                    end
                    War->>Attacker: military--
                    War->>Defender: military -= 2
                else defender stronger
                    War->>Attacker: military -= 2
                    War->>Defender: military--
                end
                
                War->>SpaceGen: checkCivDoom(attacker)
                War->>SpaceGen: checkCivDoom(defender)
            else no targets
                Attacker->>Defender: make peace
            end
        end
    end
```

### Agent Behavior

```mermaid
sequenceDiagram
    participant SpaceGen
    participant Agent
    participant Planet
    participant Civ
    
    SpaceGen->>Agent: tick()
    
    alt Space Monster
        alt planet has population
            Agent->>Planet: attack
            Planet->>Planet: kill population
        else empty planet
            Agent->>Agent: move to random planet
        end
    else Pirate
        alt planet has owner
            Agent->>Civ: raid
            Civ->>Civ: lose resources
        end
        Agent->>Agent: seek wealthy target
    else Adventurer
        alt planet has strata
            Agent->>Planet: discover artefact
            Planet->>Planet: remove from strata
            Planet->>Planet: add to artefacts
        end
        Agent->>Agent: wander
    else Refugee
        Agent->>Agent: seek safe planet
    else Merchant
        Agent->>Agent: trade between civs
    end
```

---

## State Machine Diagrams

### Civilization Lifecycle

```mermaid
stateDiagram-v2
    [*] --> PreSentient: Life emerges
    PreSentient --> Sentient: Evolution
    Sentient --> Spacefaring: Achieve spaceflight
    
    Spacefaring --> Expanding: Colonize
    Expanding --> Mature: Multiple colonies
    Mature --> Declining: Age > 5
    
    Declining --> Collapsed: Dark age
    Declining --> Transcended: Transcendence
    
    state Declining {
        [*] --> Young: decrepitude < 5
        Young --> Middle: decrepitude < 17
        Middle --> Old: decrepitude < 25
        Old --> Ancient: decrepitude >= 25
    }
    
    Spacefaring --> Destroyed: War/Cataclysm
    Expanding --> Destroyed: War/Cataclysm
    Mature --> Destroyed: War/Cataclysm
    Declining --> Destroyed: War/Cataclysm
    
    Collapsed --> [*]
    Transcended --> [*]
    Destroyed --> [*]
```

### Planet Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Barren: Creation
    Barren --> Habitable: Life emerges
    
    state Habitable {
        [*] --> Primitive: Simple life
        Primitive --> Complex: Evolution
        Complex --> Sentient: Sentience emerges
        Sentient --> Civilized: Spaceflight achieved
        
        Civilized --> DarkAge: Collapse
        DarkAge --> Sentient: Recovery
        
        Civilized --> Transcended: Transcendence
    }
    
    Habitable --> Barren: Cataclysm
    Barren --> [*]: Erosion
```

### Population Dynamics

```mermaid
stateDiagram-v2
    [*] --> Growing: Birth
    Growing --> Stable: Population balanced
    Stable --> Growing: Good conditions
    Stable --> Declining: Pollution/Plague
    Declining --> Stable: Recovery
    Declining --> Extinct: Size = 0
    Growing --> Mutating: Mutation event
    Mutating --> Growing: New species
    Extinct --> [*]: Add to strata
```

---

## Component Interaction Diagram

```mermaid
graph TB
    subgraph "Presentation Layer"
        UI[UI Components]
        Canvas[Game Canvas]
        Log[Log Display]
    end
    
    subgraph "Game Loop"
        Thread[Game Thread]
        World[Game World]
        Controls[Game Controls]
    end
    
    subgraph "Core Logic"
        SG[SpaceGen]
        Planets[Planet Manager]
        Civs[Civilization Manager]
        Agents[Agent Manager]
    end
    
    subgraph "Animation System"
        Stage[Stage]
        Sprites[Sprite Hierarchy]
        Anims[Animations]
    end
    
    subgraph "Data Models"
        Planet[Planet]
        Civ[Civilization]
        Agent[Agent]
        Pop[Population]
    end
    
    UI --> Thread
    Thread --> World
    World --> SG
    World --> Stage
    
    SG --> Planets
    SG --> Civs
    SG --> Agents
    
    Planets --> Planet
    Civs --> Civ
    Agents --> Agent
    
    Planet --> Pop
    Planet --> Stage
    Civ --> Stage
    Agent --> Stage
    
    Stage --> Sprites
    Stage --> Anims
    
    Canvas --> Stage
    Log --> SG
    Controls --> World
```

---

## Data Flow Diagram

```mermaid
graph LR
    subgraph "Input"
        User[User Input]
        Time[Time/Tick]
    end
    
    subgraph "Processing"
        GW[Game World]
        SG[SpaceGen]
        
        subgraph "Tick Phases"
            P1[Planet Events]
            P2[Civ Actions]
            P3[Agent Behaviors]
            P4[Evolution]
            P5[Erosion]
        end
    end
    
    subgraph "State"
        Planets[Planets]
        Civs[Civilizations]
        Agents[Agents]
        Log[Event Log]
    end
    
    subgraph "Output"
        Stage[Animation Stage]
        Display[Visual Display]
        Text[Text Log]
    end
    
    User --> GW
    Time --> GW
    GW --> SG
    
    SG --> P1
    P1 --> P2
    P2 --> P3
    P3 --> P4
    P4 --> P5
    
    P1 --> Planets
    P2 --> Civs
    P3 --> Agents
    P1 --> Log
    P2 --> Log
    P3 --> Log
    
    Planets --> Stage
    Civs --> Stage
    Agents --> Stage
    Log --> Text
    
    Stage --> Display
```

---

## Architecture Layers

```mermaid
graph TD
    subgraph "Layer 1: Presentation"
        A1[JFrame/Window]
        A2[Canvas]
        A3[Input Handlers]
        A4[Display Renderer]
    end
    
    subgraph "Layer 2: Game Loop"
        B1[Game Thread]
        B2[Game World]
        B3[Game Controls]
    end
    
    subgraph "Layer 3: Animation"
        C1[Stage]
        C2[Sprite Manager]
        C3[Animation Queue]
        C4[Camera System]
    end
    
    subgraph "Layer 4: Core Logic"
        D1[SpaceGen Engine]
        D2[Event System]
        D3[Behavior System]
        D4[Random Generator]
    end
    
    subgraph "Layer 5: Domain Models"
        E1[Planet]
        E2[Civilization]
        E3[Agent]
        E4[Population]
        E5[Artefact]
        E6[Structure]
    end
    
    subgraph "Layer 6: Data Structures"
        F1[Strata/History]
        F2[Collections]
        F3[Enumerations]
    end
    
    A1 --> B1
    A2 --> B1
    A3 --> B3
    B1 --> B2
    B2 --> D1
    B2 --> C1
    B3 --> B2
    
    C1 --> C2
    C1 --> C3
    C1 --> C4
    C2 --> A4
    
    D1 --> D2
    D1 --> D3
    D1 --> D4
    D1 --> E1
    D1 --> E2
    D1 --> E3
    
    E1 --> E4
    E1 --> E5
    E1 --> E6
    E2 --> E4
    
    E1 --> F1
    E2 --> F2
    E3 --> F2
    
    style A1 fill:#e1f5ff
    style B1 fill:#fff4e1
    style C1 fill:#ffe1f5
    style D1 fill:#e1ffe1
    style E1 fill:#f5e1ff
    style F1 fill:#ffe1e1
```

---

## Package Structure

```mermaid
graph TD
    Root[com.zarkonnen.spacegen]
    
    Root --> Core[core]
    Root --> Models[models]
    Root --> UI[ui]
    Root --> Logic[logic]
    Root --> Enums[enums]
    Root --> Utils[utils]
    
    Core --> SpaceGen[SpaceGen.java]
    Core --> GameWorld[GameWorld.java]
    Core --> GameThread[GameThread.java]
    
    Models --> Planet[Planet.java]
    Models --> Civ[Civ.java]
    Models --> Agent[Agent.java]
    Models --> Population[Population.java]
    Models --> Artefact[Artefact.java]
    Models --> Structure[Structure.java]
    Models --> Stratum[Stratum.java]
    
    UI --> Stage[Stage.java]
    UI --> Sprite[Sprite.java]
    UI --> GameDisplay[GameDisplay.java]
    UI --> Input[Input.java]
    
    Logic --> CivAction[CivAction.java]
    Logic --> CivEvents[CivEvents.java]
    Logic --> War[War.java]
    Logic --> Science[Science.java]
    Logic --> Diplomacy[Diplomacy.java]
    
    Enums --> Government[Government.java]
    Enums --> AgentType[AgentType.java]
    Enums --> ArtefactType[ArtefactType.java]
    Enums --> Cataclysm[Cataclysm.java]
    Enums --> PlanetSpecial[PlanetSpecial.java]
    
    Utils --> Names[Names.java]
    Utils --> Imager[Imager.java]
    Utils --> MediaProvider[MediaProvider.java]
```

---

## Flutter Package Structure (Recommended)

```mermaid
graph TD
    Root[lib/]
    
    Root --> Main[main.dart]
    Root --> Models[models/]
    Root --> Game[game/]
    Root --> Rendering[rendering/]
    Root --> Logic[logic/]
    Root --> UI[ui/]
    Root --> Providers[providers/]
    Root --> Utils[utils/]
    
    Models --> MSpaceGen[space_gen.dart]
    Models --> MPlanet[planet.dart]
    Models --> MCiv[civ.dart]
    Models --> MAgent[agent.dart]
    Models --> MEnums[enums/]
    
    MEnums --> EGovt[government.dart]
    MEnums --> EAgent[agent_type.dart]
    MEnums --> EArt[artefact_type.dart]
    
    Game --> GWorld[game_world.dart]
    Game --> GController[game_controller.dart]
    Game --> GState[game_state.dart]
    
    Rendering --> RStage[stage.dart]
    Rendering --> RSprite[sprite.dart]
    Rendering --> RAnims[animations/]
    Rendering --> RPainter[game_painter.dart]
    Rendering --> RImager[imager.dart]
    
    RAnims --> ADelay[delay.dart]
    RAnims --> AMove[move.dart]
    RAnims --> ATrack[tracking.dart]
    
    Logic --> LActions[civ_actions.dart]
    Logic --> LEvents[civ_events.dart]
    Logic --> LWar[war.dart]
    Logic --> LScience[science.dart]
    
    UI --> UScreens[screens/]
    UI --> UWidgets[widgets/]
    UI --> UTheme[theme.dart]
    
    UScreens --> SGame[game_screen.dart]
    UScreens --> SMenu[menu_screen.dart]
    
    UWidgets --> WCanvas[game_canvas.dart]
    UWidgets --> WLog[log_display.dart]
    UWidgets --> WInfo[info_panel.dart]
    
    Providers --> PSpaceGen[space_gen_provider.dart]
    
    Utils --> UNames[names.dart]
    Utils --> URandom[random_utils.dart]
    Utils --> UConst[constants.dart]
```

---

## Summary

These UML diagrams provide:

1. **Complete class relationships** showing all major components
2. **Enumeration systems** for game mechanics
3. **Sequence diagrams** for key processes
4. **State machines** for entity lifecycles
5. **Component interactions** showing data flow
6. **Architecture layers** showing system organization
7. **Package structures** for both Java and Flutter

Use these diagrams as reference when:
- Understanding system architecture
- Planning the Flutter conversion
- Documenting the codebase
- Onboarding new developers
- Debugging complex interactions

import 'planet.dart';
import 'sentient_type.dart';
import 'civilization.dart';

enum AgentType {
  pirate,
  adventurer,
  shapeShifter,
  ultravores,
  spaceMonster,
  spaceProbe,
  rogueAi;

  String get displayName {
    switch (this) {
      case AgentType.pirate:
        return 'Pirate';
      case AgentType.adventurer:
        return 'Adventurer';
      case AgentType.shapeShifter:
        return 'Shape-Shifter';
      case AgentType.ultravores:
        return 'Ultravores';
      case AgentType.spaceMonster:
        return 'Space Monster';
      case AgentType.spaceProbe:
        return 'Space Probe';
      case AgentType.rogueAi:
        return 'Rogue AI';
    }
  }
}

class Agent {
  Planet? location;
  AgentType type;
  int resources;
  int fleet;
  int birth;
  String name;
  SentientType? sentientType;
  Civilization? originator;
  int timer;
  Planet? target;
  String? color;
  String? missionType;

  Agent({
    this.location,
    required this.type,
    this.resources = 0,
    this.fleet = 1,
    required this.birth,
    required this.name,
    this.sentientType,
    this.originator,
    this.timer = 0,
    this.target,
    this.color,
    this.missionType,
  });

  String describe() {
    switch (type) {
      case AgentType.pirate:
        final fleetStr = fleet < 2 ? '.' : ', commanding a fleet of $fleet ships.';
        return 'In orbit: The pirate $name, a ${sentientType?.name ?? 'unknown'}$fleetStr';
      case AgentType.adventurer:
        final fleetStr = fleet < 2 ? '.' : ', commanding a fleet of $fleet ships.';
        return 'In orbit: The adventurer $name, a member of the ${sentientType?.name ?? 'unknown'}, serving the ${originator?.name ?? 'unknown'}$fleetStr';
      case AgentType.shapeShifter:
        return 'A pack of shape-shifters hiding amongst the local population.';
      case AgentType.ultravores:
        return 'A pack of ultravores, incredibly dangerous predators.';
      case AgentType.spaceMonster:
        return 'In orbit: A $name threatening the planet.';
      case AgentType.spaceProbe:
        return 'In orbit: The insane space probe $name threatening the planet.';
      case AgentType.rogueAi:
        return 'In orbit: The rogue AI $name.';
    }
  }

  @override
  String toString() => name;
}

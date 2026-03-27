import 'civilization.dart';
import 'sentient_type.dart';
import 'agent.dart';

enum ArtefactType {
  monument,
  weapon,
  tool,
  art,
  literature,
  technology,
  wreck,
  container,
  beacon,
  database,
  seed,
  probe,
  relic,
  pirateTomb,
  pirateHoard,
  adventurerTomb,
  timeIce,
  stasisCapsule,
  mindArchive;

  String get displayName {
    switch (this) {
      case ArtefactType.monument:
        return 'Monument';
      case ArtefactType.weapon:
        return 'Weapon';
      case ArtefactType.tool:
        return 'Tool';
      case ArtefactType.art:
        return 'Art';
      case ArtefactType.literature:
        return 'Literature';
      case ArtefactType.technology:
        return 'Technology';
      case ArtefactType.wreck:
        return 'Wreck';
      case ArtefactType.container:
        return 'Container';
      case ArtefactType.beacon:
        return 'Beacon';
      case ArtefactType.database:
        return 'Database';
      case ArtefactType.seed:
        return 'Seed';
      case ArtefactType.probe:
        return 'Probe';
      case ArtefactType.relic:
        return 'Relic';
      case ArtefactType.pirateTomb:
        return 'Pirate Tomb';
      case ArtefactType.pirateHoard:
        return 'Pirate Hoard';
      case ArtefactType.adventurerTomb:
        return 'Adventurer Tomb';
      case ArtefactType.timeIce:
        return 'Time Ice';
      case ArtefactType.stasisCapsule:
        return 'Stasis Capsule';
      case ArtefactType.mindArchive:
        return 'Mind Archive';
    }
  }
}

class Artefact {
  final int created;
  final Civilization? creator;
  final ArtefactType type;
  final String description;
  final SentientType? sentientType;
  final int creatorTechLevel;
  final int specialValue;
  final String? creatorName;

  SentientType? containedSentientType;
  Artefact? containedArtefact;
  Agent? containedAgent;

  Artefact({
    required this.created,
    this.creator,
    required this.type,
    required this.description,
    this.sentientType,
    this.creatorTechLevel = 0,
    this.specialValue = 0,
    this.creatorName,
    this.containedSentientType,
    this.containedArtefact,
    this.containedAgent,
  });

  Artefact.withCreatorName({
    required this.created,
    required this.creatorName,
    required this.type,
    required this.description,
    this.specialValue = 0,
  })  : creator = null,
        sentientType = null,
        creatorTechLevel = 0,
        containedSentientType = null,
        containedArtefact = null,
        containedAgent = null;

  @override
  String toString() {
    if (creatorName != null) {
      return '$description created by $creatorName in $created';
    }
    if (creator == null) {
      return description;
    }
    if (type == ArtefactType.wreck) {
      return description;
    }
    return '$description created by the ${creator!.name} in $created';
  }
}

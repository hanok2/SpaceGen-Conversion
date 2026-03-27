import 'civilization.dart';
import 'planet.dart';
import 'structure.dart';
import '../enums/civ_action_type.dart';

enum SentientBase {
  humanoids,
  insects,
  reptiles,
  birds,
  aquatic,
  plants,
  fungi,
  robots,
  parasites,
  crystals,
  energy,
  ursoids;

  String get displayName {
    switch (this) {
      case SentientBase.humanoids:
        return 'Humanoids';
      case SentientBase.insects:
        return 'Insects';
      case SentientBase.reptiles:
        return 'Reptiles';
      case SentientBase.birds:
        return 'Birds';
      case SentientBase.aquatic:
        return 'Aquatic';
      case SentientBase.plants:
        return 'Plants';
      case SentientBase.fungi:
        return 'Fungi';
      case SentientBase.robots:
        return 'Robots';
      case SentientBase.parasites:
        return 'Parasites';
      case SentientBase.crystals:
        return 'Crystals';
      case SentientBase.energy:
        return 'Energy';
      case SentientBase.ursoids:
        return 'Ursoids';
    }
  }

  List<CivActionType> get behaviour {
    switch (this) {
      case SentientBase.humanoids:
        return [
          CivActionType.explorePlanet,
          CivActionType.explorePlanet,
          CivActionType.colonisePlanet,
          CivActionType.buildScienceOutpost,
          CivActionType.buildMilitaryBase,
          CivActionType.buildMiningBase,
          CivActionType.buildWarships,
        ];
      case SentientBase.insects:
        return [
          CivActionType.explorePlanet,
          CivActionType.colonisePlanet,
          CivActionType.buildMiningBase,
          CivActionType.buildMiningBase,
          CivActionType.buildMiningBase,
          CivActionType.doResearch,
          CivActionType.buildConstruction,
        ];
      case SentientBase.reptiles:
        return [
          CivActionType.explorePlanet,
          CivActionType.colonisePlanet,
          CivActionType.explorePlanet,
          CivActionType.explorePlanet,
          CivActionType.buildWarships,
          CivActionType.buildWarships,
        ];
      case SentientBase.birds:
        return [
          CivActionType.explorePlanet,
          CivActionType.explorePlanet,
          CivActionType.colonisePlanet,
          CivActionType.buildScienceOutpost,
          CivActionType.buildMilitaryBase,
          CivActionType.buildMiningBase,
          CivActionType.buildWarships,
        ];
      case SentientBase.aquatic:
        return [
          CivActionType.buildScienceOutpost,
          CivActionType.buildMilitaryBase,
          CivActionType.buildMilitaryBase,
          CivActionType.buildMiningBase,
          CivActionType.buildMiningBase,
          CivActionType.colonisePlanet,
        ];
      case SentientBase.plants:
        return [
          CivActionType.buildConstruction,
          CivActionType.buildConstruction,
          CivActionType.buildMiningBase,
          CivActionType.buildMiningBase,
          CivActionType.doResearch,
          CivActionType.colonisePlanet,
        ];
      case SentientBase.fungi:
        return [
          CivActionType.doResearch,
          CivActionType.buildConstruction,
          CivActionType.buildConstruction,
          CivActionType.buildMiningBase,
          CivActionType.colonisePlanet,
          CivActionType.explorePlanet,
        ];
      case SentientBase.robots:
        return [
          CivActionType.buildWarships,
          CivActionType.buildMiningBase,
          CivActionType.buildConstruction,
          CivActionType.buildConstruction,
          CivActionType.buildConstruction,
          CivActionType.buildConstruction,
        ];
      case SentientBase.parasites:
        return [
          CivActionType.explorePlanet,
          CivActionType.explorePlanet,
          CivActionType.explorePlanet,
          CivActionType.colonisePlanet,
          CivActionType.colonisePlanet,
          CivActionType.doResearch,
        ];
      case SentientBase.crystals:
        return [
          CivActionType.buildScienceOutpost,
          CivActionType.doResearch,
          CivActionType.buildConstruction,
          CivActionType.buildMiningBase,
          CivActionType.colonisePlanet,
          CivActionType.explorePlanet,
        ];
      case SentientBase.energy:
        return [
          CivActionType.explorePlanet,
          CivActionType.buildScienceOutpost,
          CivActionType.doResearch,
          CivActionType.colonisePlanet,
          CivActionType.buildWarships,
          CivActionType.buildConstruction,
        ];
      case SentientBase.ursoids:
        return [
          CivActionType.buildWarships,
          CivActionType.buildWarships,
          CivActionType.buildWarships,
          CivActionType.explorePlanet,
          CivActionType.colonisePlanet,
          CivActionType.buildMilitaryBase,
        ];
    }
  }
}

enum SentientPrefix {
  feathered,
  scaly,
  sixLegged,
  fourArmed,
  twoHeaded,
  slim,
  amorphous,
  flying,
  telepathic,
  immortal;

  String get displayName {
    switch (this) {
      case SentientPrefix.feathered:
        return 'Feathered';
      case SentientPrefix.scaly:
        return 'Scaly';
      case SentientPrefix.sixLegged:
        return 'Six-Legged';
      case SentientPrefix.fourArmed:
        return 'Four-Armed';
      case SentientPrefix.twoHeaded:
        return 'Two-Headed';
      case SentientPrefix.slim:
        return 'Slim';
      case SentientPrefix.amorphous:
        return 'Amorphous';
      case SentientPrefix.flying:
        return 'Flying';
      case SentientPrefix.telepathic:
        return 'Telepathic';
      case SentientPrefix.immortal:
        return 'Immortal';
    }
  }
}

enum SentientPostfix {
  s3,
  s5,
  eyes,
  tails;

  String get displayName {
    switch (this) {
      case SentientPostfix.s3:
        return 'S3';
      case SentientPostfix.s5:
        return 'S5';
      case SentientPostfix.eyes:
        return 'Eyes';
      case SentientPostfix.tails:
        return 'Tails';
    }
  }
}

class SentientType {
  final int birth;
  final Planet? evolvedLocation;
  final Civilization? creators;
  final SentientBase base;
  final List<StructureType> specialStructures;
  final List<SentientPrefix> prefixes;
  final String? color;
  final SentientPostfix? postfix;
  final bool cyborg;
  final String personality;
  final String goal;
  final String name;
  final String? specialOrigin;

  SentientType({
    required this.birth,
    this.evolvedLocation,
    this.creators,
    required this.base,
    List<StructureType>? specialStructures,
    List<SentientPrefix>? prefixes,
    this.color,
    this.postfix,
    this.cyborg = false,
    required this.personality,
    required this.goal,
    required this.name,
    this.specialOrigin,
  })  : specialStructures = specialStructures ?? [],
        prefixes = prefixes ?? [];

  static const List<String> personalities = [
    'cautious',
    'violent',
    'cowardly',
    'peaceful',
    'humorless',
    'hyperactive',
    'gregarious',
    'reclusive',
    'meditative',
    'fond of practical jokes',
    'modest',
    'thrill-seeking',
  ];

  static const List<String> goals = [
    'deeply religious',
    'value personal integrity above all else',
    'have a complex system of social castes',
    'strive to uphold their ideals of personal honour',
    'deeply rationalist',
    'unwilling to compromise',
    'always willing to listen',
    'have a deep need to conform',
    'believe in the survival of the fittest',
    'believe in the inherent superiority of their species',
    'believe that each individual must serve the community',
    'have a complex system of social rules',
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SentientType &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}

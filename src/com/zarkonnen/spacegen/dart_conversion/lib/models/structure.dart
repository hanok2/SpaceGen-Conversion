import 'civilization.dart';

enum StructureType {
  farm,
  mine,
  factory,
  laboratory,
  monument,
  fortress,
  spaceport,
  temple,
  library,
  hospital,
  university,
  reactor,
  shield,
  terraformer,
  ringworld,
  dysonSphere,
  matrioshkaBrain,
  starLifter,
  nicollDysonBeam,
  caplanThruster;

  String get displayName {
    switch (this) {
      case StructureType.farm:
        return 'Farm';
      case StructureType.mine:
        return 'Mine';
      case StructureType.factory:
        return 'Factory';
      case StructureType.laboratory:
        return 'Laboratory';
      case StructureType.monument:
        return 'Monument';
      case StructureType.fortress:
        return 'Fortress';
      case StructureType.spaceport:
        return 'Spaceport';
      case StructureType.temple:
        return 'Temple';
      case StructureType.library:
        return 'Library';
      case StructureType.hospital:
        return 'Hospital';
      case StructureType.university:
        return 'University';
      case StructureType.reactor:
        return 'Reactor';
      case StructureType.shield:
        return 'Shield';
      case StructureType.terraformer:
        return 'Terraformer';
      case StructureType.ringworld:
        return 'Ringworld';
      case StructureType.dysonSphere:
        return 'Dyson Sphere';
      case StructureType.matrioshkaBrain:
        return 'Matrioshka Brain';
      case StructureType.starLifter:
        return 'Star Lifter';
      case StructureType.nicollDysonBeam:
        return 'Nicoll-Dyson Beam';
      case StructureType.caplanThruster:
        return 'Caplan Thruster';
    }
  }
}

class Structure {
  final StructureType type;
  final Civilization builders;
  final int buildTime;

  Structure({
    required this.type,
    required this.builders,
    required this.buildTime,
  });

  @override
  String toString() {
    return '${type.displayName}, built by the ${builders.name} in $buildTime';
  }
}

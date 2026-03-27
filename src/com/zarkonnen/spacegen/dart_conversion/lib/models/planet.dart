import '../enums/planet_special.dart';
import '../enums/special_lifeform.dart';
import '../enums/cataclysm.dart';
import 'population.dart';
import 'artefact.dart';
import 'civilization.dart';
import 'structure.dart';
import 'plague.dart';
import 'strata/stratum.dart';
import 'strata/remnant.dart';
import 'strata/ruin.dart';
import 'strata/lost_artefact.dart';
import 'strata/fossil.dart';

class Planet {
  static const List<String> planetNames = [
    'Taranis',
    'Krantor',
    'Mycon',
    'Urbon',
    'Metatron',
    'Autorog',
    'Pastinakos',
    'Orra',
    'Hylon',
    'Wotan',
    'Erebus',
    'Regor',
    'Sativex',
    'Vim',
    'Freia',
    'Tabernak',
    'Helmettepol',
    'Lumen',
    'Atria',
    'Bal',
    'Orgus',
    'Hylus',
    'Jurvox',
    'Kalamis',
    'Ziggurat',
    'Xarlan',
    'Chroma',
    'Nid',
    'Mera',
  ];

  final String name;
  int pollution;
  bool habitable;
  int evolutionPoints;
  int evolutionNeeded;
  final List<PlanetSpecial> specials;
  final List<SpecialLifeform> lifeforms;
  final List<Population> inhabitants;
  final List<Artefact> artefacts;
  Civilization? owner;
  final List<Structure> structures;
  final List<Plague> plagues;
  final List<Stratum> strata;
  int x;
  int y;

  Planet({
    required this.name,
    this.pollution = 0,
    this.habitable = false,
    this.evolutionPoints = 0,
    this.evolutionNeeded = 15000,
    List<PlanetSpecial>? specials,
    List<SpecialLifeform>? lifeforms,
    List<Population>? inhabitants,
    List<Artefact>? artefacts,
    this.owner,
    List<Structure>? structures,
    List<Plague>? plagues,
    List<Stratum>? strata,
    this.x = 0,
    this.y = 0,
  })  : specials = specials ?? [],
        lifeforms = lifeforms ?? [],
        inhabitants = inhabitants ?? [],
        artefacts = artefacts ?? [],
        structures = structures ?? [],
        plagues = plagues ?? [],
        strata = strata ?? [];

  int get totalPopulation {
    return inhabitants.fold(0, (sum, pop) => sum + pop.size);
  }

  bool hasStructure(StructureType type) {
    return structures.any((s) => s.type == type);
  }

  bool get isOutpost {
    return hasStructure(StructureType.fortress) ||
        hasStructure(StructureType.laboratory) ||
        hasStructure(StructureType.mine);
  }

  void addPlague(Plague plague) {
    plagues.add(plague);
  }

  void removePlague(Plague plague) {
    plagues.remove(plague);
  }

  void clearPlagues() {
    plagues.clear();
  }

  void addArtefact(Artefact artefact) {
    artefacts.add(artefact);
  }

  void removeArtefact(Artefact artefact) {
    artefacts.remove(artefact);
  }

  void clearArtefacts() {
    artefacts.clear();
  }

  void addStructure(Structure structure) {
    structures.add(structure);
  }

  void removeStructure(Structure structure) {
    structures.remove(structure);
  }

  void clearStructures() {
    structures.clear();
  }

  void addLifeform(SpecialLifeform lifeform) {
    lifeforms.add(lifeform);
  }

  void removeLifeform(SpecialLifeform lifeform) {
    lifeforms.remove(lifeform);
  }

  void clearLifeforms() {
    lifeforms.clear();
  }

  void depopulate(Population pop, int time, Cataclysm? cataclysm, String? reason, Plague? plague) {
    strata.add(Remnant(
      remnant: pop,
      collapseTime: time,
      cataclysm: cataclysm,
      reason: reason,
      plague: plague,
    ));
    inhabitants.remove(pop);

    for (final p in List<Plague>.from(plagues)) {
      bool stillAffects = false;
      for (final pop2 in inhabitants) {
        if (p.affects.contains(pop2.type)) {
          stillAffects = true;
          break;
        }
      }
      if (!stillAffects) {
        removePlague(p);
      }
    }
  }

  void darkAge(int time) {
    for (final s in structures) {
      strata.add(Ruin(
        structure: s,
        ruinTime: time,
        reason: 'during the collapse of the ${owner?.name}',
      ));
    }
    clearStructures();

    for (final a in artefacts) {
      strata.add(LostArtefact(
        status: 'lost',
        lostTime: time,
        artefact: a,
      ));
    }
    clearArtefacts();

    owner = null;
  }

  void transcend(int time) {
    if (owner == null) return;

    for (final p in List<Population>.from(inhabitants)) {
      strata.add(Remnant.transcended(
        remnant: p,
        transcendenceTime: time,
      ));
      inhabitants.remove(p);
    }

    for (final s in structures) {
      strata.add(Ruin(
        structure: s,
        ruinTime: time,
        reason: 'after the transcendence of the ${owner?.name}',
      ));
    }
    clearStructures();

    for (final a in artefacts) {
      strata.add(LostArtefact(
        status: 'lost and buried when the ${owner?.name} transcended',
        lostTime: time,
        artefact: a,
      ));
    }
    clearArtefacts();
    clearPlagues();

    owner = null;
  }

  void decivilize(int time, Cataclysm? cataclysm, String? reason) {
    owner = null;

    for (final p in List<Population>.from(inhabitants)) {
      depopulate(p, time, cataclysm, reason, null);
    }

    for (final s in structures) {
      strata.add(Ruin(
        structure: s,
        ruinTime: time,
        cataclysm: cataclysm,
        reason: reason,
      ));
    }
    clearStructures();

    for (final a in artefacts) {
      strata.add(LostArtefact(
        status: 'buried',
        lostTime: time,
        artefact: a,
      ));
    }
    clearArtefacts();
  }

  void extinguishLife(int time, Cataclysm? cataclysm, String? reason) {
    decivilize(time, cataclysm, reason);
    evolutionPoints = 0;

    for (final slf in lifeforms) {
      strata.add(Fossil(
        fossil: slf,
        fossilisationTime: time,
        cataclysm: cataclysm,
      ));
    }

    clearPlagues();
    clearLifeforms();
    habitable = false;
  }

  @override
  String toString() => name;
}

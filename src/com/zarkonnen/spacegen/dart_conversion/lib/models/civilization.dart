import '../enums/government.dart';
import '../enums/diplomacy_outcome.dart';
import 'sentient_type.dart';
import 'planet.dart';

class Civilization {
  final List<SentientType> fullMembers;
  Government government;
  final Map<Civilization, DiplomacyOutcome> relations;
  int number;
  int resources;
  int science;
  int military;
  int weaponLevel;
  int techLevel;
  String name;
  int birthYear;
  int nextBreakthrough;
  int decrepitude;

  Civilization({
    List<SentientType>? fullMembers,
    required this.government,
    Map<Civilization, DiplomacyOutcome>? relations,
    this.number = 0,
    this.resources = 0,
    this.science = 0,
    this.military = 0,
    this.weaponLevel = 0,
    this.techLevel = 0,
    required this.name,
    required this.birthYear,
    this.nextBreakthrough = 6,
    this.decrepitude = 0,
  })  : fullMembers = fullMembers ?? [],
        relations = relations ?? {};

  DiplomacyOutcome getRelation(Civilization other) {
    return relations[other] ?? DiplomacyOutcome.peace;
  }

  void setRelation(Civilization other, DiplomacyOutcome outcome) {
    relations[other] = outcome;
  }

  List<Planet> colonies(List<Planet> allPlanets) {
    return allPlanets.where((p) => p.owner == this).toList();
  }

  List<Planet> fullColonies(List<Planet> allPlanets) {
    return allPlanets.where((p) => p.owner == this && p.totalPopulation > 0).toList();
  }

  Planet? largestColony(List<Planet> allPlanets) {
    Planet? largest;
    int maxPop = -1;
    for (final col in colonies(allPlanets)) {
      if (col.totalPopulation > maxPop) {
        largest = col;
        maxPop = col.totalPopulation;
      }
    }
    return largest;
  }

  Planet? leastPopulousFullColony(List<Planet> allPlanets) {
    Planet? smallest;
    int minPop = 999999;
    for (final col in fullColonies(allPlanets)) {
      if (col.totalPopulation < minPop) {
        smallest = col;
        minPop = col.totalPopulation;
      }
    }
    return smallest;
  }

  int totalPopulation(List<Planet> allPlanets) {
    return colonies(allPlanets).fold(0, (sum, p) => sum + p.totalPopulation);
  }

  void updateName(List<String> historicalNames) {
    number = 0;
    while (true) {
      number++;
      final n = _genName(number);
      if (historicalNames.contains(n)) continue;
      name = n;
      break;
    }
    historicalNames.add(name);
  }

  String _genName(int nth) {
    String n = '';
    if (nth > 1) n = _nthStr(nth) + ' ';
    n += '${government.title} of ';
    if (fullMembers.length == 1) {
      n += fullMembers[0].name;
    } else {
      final bases = fullMembers.map((m) => m.base).toSet().toList();
      for (int i = 0; i < bases.length; i++) {
        if (i > 0) {
          n += i == bases.length - 1 ? ' and ' : ', ';
        }
        n += bases[i].displayName;
      }
    }
    return n;
  }

  String _nthStr(int n) {
    switch (n) {
      case 2: return 'Second';
      case 3: return 'Third';
      case 4: return 'Fourth';
      case 5: return 'Fifth';
      default: return '${n}th';
    }
  }

  @override
  String toString() => name;
}

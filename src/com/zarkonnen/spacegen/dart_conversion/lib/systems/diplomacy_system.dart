import '../models/civilization.dart';
import '../models/sentient_type.dart';
import '../enums/diplomacy_outcome.dart';
import '../enums/government.dart';
import '../utils/random_utils.dart';

class DiplomacySystem {
  final RandomUtils random;

  DiplomacySystem(this.random);

  static final Map<Government, Map<Government, List<DiplomacyOutcome>>> _table = {
    Government.dictatorship: {
      Government.dictatorship: [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
      Government.theocracy:   [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
      Government.feudalState: [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
      Government.republic:    [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
    },
    Government.theocracy: {
      Government.theocracy:   [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace],
      Government.feudalState: [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
      Government.republic:    [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
    },
    Government.feudalState: {
      Government.feudalState: [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.union],
      Government.republic:    [DiplomacyOutcome.war, DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace],
    },
    Government.republic: {
      Government.republic: [DiplomacyOutcome.war, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.peace, DiplomacyOutcome.union],
    },
  };

  DiplomacyOutcome meet(Civilization a, Civilization b) {
    if (a.fullMembers.isNotEmpty && a.fullMembers[0].base == SentientBase.ursoids) {
      return DiplomacyOutcome.war;
    }
    if (b.fullMembers.isNotEmpty && b.fullMembers[0].base == SentientBase.ursoids) {
      return DiplomacyOutcome.war;
    }

    Civilization lower = a;
    Civilization higher = b;
    if (a.government.index > b.government.index) {
      lower = b;
      higher = a;
    }

    final row = _table[lower.government];
    if (row == null) return DiplomacyOutcome.peace;
    final outcomes = row[higher.government];
    if (outcomes == null) return DiplomacyOutcome.peace;

    DiplomacyOutcome outcome = random.pick(outcomes);
    return outcome;
  }

  void meetAndRecord(Civilization a, Civilization b) {
    final outcome = meet(a, b);
    a.setRelation(b, outcome);
    b.setRelation(a, outcome);
  }

  String outcomeDescription(DiplomacyOutcome outcome, DiplomacyOutcome previousStatus, String otherName) {
    switch (outcome) {
      case DiplomacyOutcome.war:
        switch (previousStatus) {
          case DiplomacyOutcome.war:   return 'Peace negotiations with the $otherName are unsuccessful and their war continues.';
          case DiplomacyOutcome.peace: return 'They declare war on the $otherName!';
          default: return '???';
        }
      case DiplomacyOutcome.peace:
        switch (previousStatus) {
          case DiplomacyOutcome.war:   return 'They sign a peace accord with the $otherName, ending their war.';
          case DiplomacyOutcome.peace: return 'They reaffirm their peaceful relations with the $otherName.';
          default: return '???';
        }
      case DiplomacyOutcome.union:
        switch (previousStatus) {
          case DiplomacyOutcome.war:   return 'In a historical moment, they put aside their differences with the $otherName, uniting the two empires.';
          case DiplomacyOutcome.peace: return 'In a historical moment, they agree to combine their civilization with the $otherName.';
          default: return '???';
        }
    }
  }

  void mergeCivs(Civilization absorber, Civilization absorbed, List<Civilization> allCivs, List<dynamic> allPlanets) {
    for (final member in absorbed.fullMembers) {
      if (!absorber.fullMembers.contains(member)) {
        absorber.fullMembers.add(member);
      }
    }
    absorber.resources += absorbed.resources;
    absorber.military += absorbed.military;
    for (final planet in allPlanets) {
      if (planet.owner == absorbed) {
        planet.owner = absorber;
      }
    }
    allCivs.remove(absorbed);
  }
}

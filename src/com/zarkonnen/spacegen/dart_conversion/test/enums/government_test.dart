import 'package:test/test.dart';
import 'package:spacegen/enums/government.dart';
import 'package:spacegen/enums/sentient_encounter_outcome.dart';

void main() {
  group('Government', () {
    test('has correct type names and titles', () {
      expect(Government.dictatorship.typeName, equals('Military Dictatorship'));
      expect(Government.dictatorship.title, equals('Empire'));
      expect(Government.dictatorship.bombardP, equals(2));
      
      expect(Government.theocracy.typeName, equals('Theocracy'));
      expect(Government.theocracy.title, equals('Church'));
      expect(Government.theocracy.bombardP, equals(4));
      
      expect(Government.feudalState.typeName, equals('Feudal State'));
      expect(Government.feudalState.title, equals('Kingdom'));
      expect(Government.feudalState.bombardP, equals(2));
      
      expect(Government.republic.typeName, equals('Republic'));
      expect(Government.republic.title, equals('Republic'));
      expect(Government.republic.bombardP, equals(1));
    });

    test('has correct encounter outcomes', () {
      expect(Government.dictatorship.encounterOutcomes.length, equals(14));
      expect(
        Government.dictatorship.encounterOutcomes.first,
        equals(SentientEncounterOutcome.exterminate),
      );
      
      expect(Government.theocracy.encounterOutcomes.length, equals(11));
      expect(Government.feudalState.encounterOutcomes.length, equals(11));
      expect(Government.republic.encounterOutcomes.length, equals(17));
      
      expect(
        Government.republic.encounterOutcomes.last,
        equals(SentientEncounterOutcome.giveFullMembership),
      );
    });

    test('has all expected values', () {
      expect(Government.values.length, equals(4));
    });
  });
}

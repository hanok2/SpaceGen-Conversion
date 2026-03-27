import 'package:test/test.dart';
import 'package:spacegen/enums/sentient_encounter_outcome.dart';

void main() {
  group('SentientEncounterOutcome', () {
    test('has correct descriptions', () {
      expect(
        SentientEncounterOutcome.subjugate.desc,
        equals('They subjugate the local \$a.'),
      );
      expect(
        SentientEncounterOutcome.giveFullMembership.desc,
        equals('They incorporate the local \$a into their civilization as equals.'),
      );
      expect(
        SentientEncounterOutcome.ignore.desc,
        equals('They ignore the local \$a.'),
      );
      expect(
        SentientEncounterOutcome.exterminate.desc,
        equals('They mount a campaign of extermination against the local \$a'),
      );
      expect(
        SentientEncounterOutcome.exterminateFail.desc,
        equals('They attempt to exterminate the local \$a'),
      );
    });

    test('has all expected values', () {
      expect(SentientEncounterOutcome.values.length, equals(5));
    });
  });
}

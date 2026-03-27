import 'package:test/test.dart';
import 'package:spacegen/enums/cataclysm.dart';

void main() {
  group('Cataclysm', () {
    test('has correct names and descriptions', () {
      expect(Cataclysm.nova.name, equals('nova'));
      expect(
        Cataclysm.nova.desc,
        equals('The star of \$name goes nova, scraping the planet clean of all life!'),
      );
      
      expect(Cataclysm.volcanicEruptions.name, equals('series of volcanic eruptions'));
      expect(Cataclysm.axialShift.name, equals('shift in the planet\'s orbital axis'));
      expect(Cataclysm.meteoriteImpact.name, equals('massive asteroid impact'));
      expect(Cataclysm.nanofungalBloom.name, equals('nanofungal bloom'));
      expect(Cataclysm.psionicShockwave.name, equals('psionic shockwave'));
    });

    test('has all expected values', () {
      expect(Cataclysm.values.length, equals(6));
    });
  });
}

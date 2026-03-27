import '../../enums/special_lifeform.dart';
import '../../enums/cataclysm.dart';
import 'stratum.dart';

class Fossil implements Stratum {
  final SpecialLifeform fossil;
  final int fossilisationTime;
  final Cataclysm? cataclysm;

  Fossil({
    required this.fossil,
    required this.fossilisationTime,
    this.cataclysm,
  });

  @override
  int get time => fossilisationTime;

  @override
  String toString() {
    final buffer = StringBuffer(
        'Fossils of ${fossil.name.toLowerCase()} that went extinct in $fossilisationTime');
    if (cataclysm != null) {
      buffer.write(' due to a ${cataclysm!.name}');
    }
    buffer.write('.');
    return buffer.toString();
  }
}

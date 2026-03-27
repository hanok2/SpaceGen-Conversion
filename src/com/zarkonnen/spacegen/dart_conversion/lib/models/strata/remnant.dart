import '../../enums/cataclysm.dart';
import '../population.dart';
import '../plague.dart';
import 'stratum.dart';

class Remnant implements Stratum {
  final Population remnant;
  final int collapseTime;
  final Cataclysm? cataclysm;
  final String? reason;
  final Plague? plague;
  final bool transcended;

  Remnant({
    required this.remnant,
    required this.collapseTime,
    this.cataclysm,
    this.reason,
    this.plague,
    this.transcended = false,
  });

  Remnant.transcended({
    required this.remnant,
    required int transcendenceTime,
  })  : collapseTime = transcendenceTime,
        cataclysm = null,
        reason = null,
        plague = null,
        transcended = true;

  @override
  int get time => collapseTime;

  @override
  String toString() {
    if (transcended) {
      return 'Remnants of the ${remnant.toUnenslavedString()} who transcended in $collapseTime.';
    }

    final buffer = StringBuffer('Remnants of the ${remnant.toUnenslavedString()} who died out in $collapseTime');
    if (cataclysm != null) {
      buffer.write(' due to a ${cataclysm!.name}');
    } else if (plague != null) {
      buffer.write(' due to a plague');
    } else if (reason != null) {
      buffer.write(' $reason');
    }
    buffer.write('.');
    return buffer.toString();
  }
}

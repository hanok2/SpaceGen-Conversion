import '../../enums/cataclysm.dart';
import '../structure.dart';
import 'stratum.dart';

class Ruin implements Stratum {
  final Structure structure;
  final int ruinTime;
  final Cataclysm? cataclysm;
  final String? reason;

  Ruin({
    required this.structure,
    required this.ruinTime,
    this.cataclysm,
    this.reason,
  });

  @override
  int get time => ruinTime;

  @override
  String toString() {
    final buffer =
        StringBuffer('Ruins of a ${structure.type.name} from $ruinTime');
    if (cataclysm != null) {
      buffer.write(' destroyed by a ${cataclysm!.name}');
    } else if (reason != null) {
      buffer.write(' $reason');
    }
    buffer.write('.');
    return buffer.toString();
  }
}

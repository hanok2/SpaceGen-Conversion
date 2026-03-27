import '../artefact.dart';
import 'stratum.dart';

class LostArtefact implements Stratum {
  final String status;
  final int lostTime;
  final Artefact artefact;

  LostArtefact({
    required this.status,
    required this.lostTime,
    required this.artefact,
  });

  @override
  int get time => lostTime;

  @override
  String toString() {
    if (artefact.type == ArtefactType.wreck) {
      return 'The $artefact.';
    }
    return 'A $artefact, $status in $lostTime.';
  }
}

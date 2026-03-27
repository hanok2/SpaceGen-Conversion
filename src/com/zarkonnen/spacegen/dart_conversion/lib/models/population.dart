import 'sentient_type.dart';
import 'planet.dart';

class Population {
  final SentientType type;
  int size;
  final Planet planet;

  Population({
    required this.type,
    required this.size,
    required this.planet,
  });

  void increase(int amount) {
    size += amount;
  }

  void decrease(int amount) {
    size -= amount;
    if (size < 0) size = 0;
  }

  bool get isEnslaved {
    final owner = planet.owner;
    if (owner == null) return false;
    return !owner.fullMembers.contains(type);
  }

  @override
  String toString() {
    final enslaved = isEnslaved ? 'enslaved ' : '';
    return '$size billion $enslaved${type.name}';
  }

  String toUnenslavedString() {
    return '$size billion ${type.name}';
  }
}

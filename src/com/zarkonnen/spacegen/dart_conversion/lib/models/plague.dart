import 'sentient_type.dart';
import '../utils/random_utils.dart';

const _plagueColors = ['Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Black', 'White', 'Grey'];
const _plagueNames = ['Rot', 'Death', 'Plague', 'Fever', 'Wasting', 'Pox'];

class Plague {
  final String name;
  final int lethality;
  final int mutationRate;
  final int transmissivity;
  final int curability;
  final String color;
  final List<SentientType> affects;

  Plague({
    required this.name,
    required this.lethality,
    required this.mutationRate,
    required this.transmissivity,
    required this.curability,
    required this.color,
    List<SentientType>? affects,
  }) : affects = affects ?? [];

  factory Plague.generate(RandomUtils random) {
    final color = random.pick(_plagueColors);
    return Plague(
      color: color,
      name: '$color ${random.pick(_plagueNames)}',
      lethality: random.d(9),
      mutationRate: random.d(3),
      transmissivity: random.d(3),
      curability: random.d(3),
    );
  }

  Plague.copy(Plague other)
      : name = other.name,
        lethality = other.lethality,
        mutationRate = other.mutationRate,
        transmissivity = other.transmissivity,
        curability = other.curability,
        color = other.color,
        affects = List.from(other.affects);

  String get description {
    if (affects.isEmpty) {
      return name;
    }

    final buffer = StringBuffer('$name, which affects ');
    for (int i = 0; i < affects.length; i++) {
      if (i > 0) {
        if (i == affects.length - 1) {
          buffer.write(' and ');
        } else {
          buffer.write(', ');
        }
      }
      buffer.write(affects[i].name);
    }
    return buffer.toString();
  }

  @override
  String toString() => description;
}

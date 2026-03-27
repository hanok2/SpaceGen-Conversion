import 'dart:math';

class RandomUtils {
  final Random _random;
  
  RandomUtils([int? seed]) : _random = seed != null ? Random(seed) : Random();
  
  bool coin() => _random.nextBool();
  
  bool p(int n) => d(n) == 0;
  
  bool atLeast(int requirement, int n) => requirement >= d(n);
  
  bool lessThan(int tooMuch, int n) => tooMuch <= d(n);
  
  int d(int n) => _random.nextInt(n);
  
  int dRolls(int rolls, int n) {
    int sum = 0;
    for (int roll = 0; roll < rolls; roll++) {
      sum += d(n);
    }
    return sum;
  }
  
  T pick<T>(List<T> items) {
    if (items.isEmpty) {
      throw ArgumentError('Cannot pick from empty list');
    }
    return items[_random.nextInt(items.length)];
  }
  
  int nextInt(int max) => _random.nextInt(max);
  
  bool nextBool() => _random.nextBool();
  
  void shuffle<T>(List<T> list) => list.shuffle(_random);

  double nextDouble() => _random.nextDouble();
}

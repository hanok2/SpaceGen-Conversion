import 'constants.dart';

class NameGenerator {
  static const List<String> planetNames = [
    'Taranis', 'Krantor', 'Mycon', 'Urbon', 'Metatron', 'Autorog', 'Pastinakos', 'Orra',
    'Hylon', 'Wotan', 'Erebus', 'Regor', 'Sativex', 'Vim', 'Freia', 'Tabernak', 'Helmettepol',
    'Lumen', 'Atria', 'Bal', 'Orgus', 'Hylus', 'Jurvox', 'Kalamis', 'Ziggurat', 'Xarlan',
    'Chroma', 'Nid', 'Mera'
  ];
  
  static const List<String> romanNumerals = [' I', ' II', ' III', ' IV', ' V', ' VI'];
  
  static String generatePlanetName(int seed) {
    final p = seed.abs();
    
    if (p % 2 == 0) {
      return planetNames[p % planetNames.length] + 
             romanNumerals[(p ~/ 77 + 3) % 6];
    }
    
    final chars = [
      String.fromCharCode('A'.codeUnitAt(0) + (p + 5) % 7),
      ['u', 'e', 'y', 'o', 'i'][(p + 2) % 5],
      String.fromCharCode('k'.codeUnitAt(0) + (p ~/ 3) % 4),
      ['u', 'e', 'i', 'o', 'a'][(p ~/ 2 + 1) % 5],
      String.fromCharCode('p'.codeUnitAt(0) + (p ~/ 2) % 9),
    ];
    
    return chars.join() + romanNumerals[(p ~/ 4 + 3) % 6];
  }
  
  static String generateCivName({
    required String governmentTitle,
    required List<String> memberNames,
    int nth = 1,
  }) {
    String name = '';
    
    if (nth > 1) {
      name = '${Constants.nth(nth)} ';
    }
    
    name += '$governmentTitle of ';
    
    if (memberNames.length == 1) {
      name += memberNames[0];
    } else {
      for (int i = 0; i < memberNames.length; i++) {
        if (i > 0) {
          if (i == memberNames.length - 1) {
            name += ' and ';
          } else {
            name += ', ';
          }
        }
        name += memberNames[i];
      }
    }
    
    return name;
  }
}

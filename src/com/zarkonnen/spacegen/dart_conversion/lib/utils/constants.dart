class Constants {
  static const int initialYear = 0;
  static const int maxYears = 10000;
  
  static const int baseEvoNeeded = 15000;
  static const int extendedEvoNeeded = 1000000;
  
  static const int gridSize = 7;
  
  static const List<String> nths = [
    'Zeroth', 'First', 'Second', 'Third', 'Fourth', 'Fifth', 'Sixth',
    'Seventh', 'Eighth', 'Ninth', 'Tenth', 'Eleventh', 'Twelfth', 
    'Thirteenth', 'Fourteenth'
  ];
  
  static const List<String> colors = [
    'Red', 'Green', 'Blue', 'Orange', 'Yellow', 'Black', 'White',
    'Purple', 'Grey'
  ];
  
  static String nth(int n) {
    if (n < nths.length) {
      return nths[n];
    }
    return '$n.';
  }
}

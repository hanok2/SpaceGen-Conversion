enum DiplomacyOutcome {
  peace,
  war,
  union;

  String get displayName {
    switch (this) {
      case DiplomacyOutcome.peace:
        return 'Peace';
      case DiplomacyOutcome.war:
        return 'War';
      case DiplomacyOutcome.union:
        return 'Union';
    }
  }
}

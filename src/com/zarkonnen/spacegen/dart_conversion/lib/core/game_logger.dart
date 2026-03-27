class GameLogger {
  final List<String> _log = [];
  final List<String> _turnLog = [];
  bool _yearAnnounced = false;
  bool _clearTurnLogOnNewEntry = false;
  int _currentYear = 0;

  List<String> get fullLog => List.unmodifiable(_log);
  List<String> get turnLog => List.unmodifiable(_turnLog);

  void setYear(int year) {
    _currentYear = year;
    _yearAnnounced = false;
  }

  void clearTurnLog() {
    _turnLog.clear();
    _clearTurnLogOnNewEntry = false;
  }

  void markClearTurnLogOnNextEntry() {
    _clearTurnLogOnNewEntry = true;
  }

  void log(String message, {Map<String, String>? replacements}) {
    if (_clearTurnLogOnNewEntry) {
      _turnLog.clear();
      _clearTurnLogOnNewEntry = false;
    }

    if (!_yearAnnounced) {
      _yearAnnounced = true;
      _logInternal('$_currentYear:');
    }

    String finalMessage = message;
    if (replacements != null) {
      replacements.forEach((key, value) {
        finalMessage = finalMessage.replaceAll(key, value);
      });
    }

    _logInternal(finalMessage);
  }

  void _logInternal(String message) {
    _log.add(message);
    _turnLog.add(message);
  }

  void clear() {
    _log.clear();
    _turnLog.clear();
    _yearAnnounced = false;
    _clearTurnLogOnNewEntry = false;
  }

  @override
  String toString() {
    return _log.join('\n');
  }
}

class LogService {
  static final List<String> _logs = [];

  static void log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    _logs.add("[$timestamp] $message");
    print("[$timestamp] $message");
  }

  static List<String> getLogs() => _logs.reversed.toList();

  static void clear() {
    _logs.clear();
  }
}

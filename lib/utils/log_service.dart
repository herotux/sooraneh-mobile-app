import 'package:flutter/material.dart';

class LogService {
  static final ValueNotifier<List<String>> logs = ValueNotifier([]);

  static void log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = "[$timestamp] $message";

    logs.value = [...logs.value, logMessage];
    print(logMessage);
  }

  static void clear() {
    logs.value = [];
  }

  static List<String> getLogs() => logs.value.reversed.toList();
}

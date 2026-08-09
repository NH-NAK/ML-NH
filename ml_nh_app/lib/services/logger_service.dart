import 'dart:async';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  final _logController = StreamController<String>.broadcast();
  final _progressController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<String> get logStream => _logController.stream;
  Stream<Map<String, dynamic>> get progressStream => _progressController.stream;

  void log(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final logLine = "[$timestamp] $message";
    print("OnyxLog: $message");
    _logController.add(logLine);
  }

  void updateProgress(double value, String status) {
    _progressController.add({
      'progress': value.clamp(0.0, 1.0),
      'percentage': (value.clamp(0.0, 1.0) * 100).toInt(),
      'status': status,
    });
  }

  void dispose() {
    _logController.close();
    _progressController.close();
  }
}

final logger = LoggerService();


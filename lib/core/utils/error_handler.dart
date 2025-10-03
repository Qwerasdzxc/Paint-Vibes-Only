import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Global error handling and logging system for the Paint Vibes app
/// Provides centralized error management, logging, and crash reporting
class ErrorHandler {
  static ErrorHandler? _instance;
  static ErrorHandler get instance => _instance ??= ErrorHandler._();

  ErrorHandler._();

  final List<ErrorEntry> _errorLog = [];
  File? _logFile;
  bool _initialized = false;

  /// Initialize the error handler
  Future<void> initialize() async {
    if (_initialized) return;

    await _setupLogFile();
    _setupFlutterErrorHandling();
    _setupZoneErrorHandling();

    _initialized = true;
  }

  /// Setup log file for persistent error storage
  Future<void> _setupLogFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${directory.path}/logs');
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      _logFile = File('${logsDir.path}/error_log.txt');
    } catch (e) {
      // If we can't create log file, continue without file logging
      debugPrint('Failed to setup log file: $e');
    }
  }

  /// Setup Flutter framework error handling
  void _setupFlutterErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      // Log the error
      logError('Flutter Error', details.exception, details.stack, {
        'context': details.context?.toString(),
        'library': details.library,
        'informationCollector': details.informationCollector?.call().join('\n'),
      });

      // In debug mode, also show the error
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };
  }

  /// Setup zone error handling for async errors
  void _setupZoneErrorHandling() {
    // This would typically be set up in main() with runZonedGuarded
    // The actual implementation would be in main.dart
  }

  /// Log an error with full context
  void logError(
    String message,
    dynamic error, [
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? library,
    String? informationCollector,
  ]) {
    final errorEntry = ErrorEntry(
      message: message,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      context: context ?? {},
      library: library,
      informationCollector: informationCollector,
      severity: ErrorSeverity.error,
    );

    _addErrorEntry(errorEntry);
  }

  /// Log a warning
  void logWarning(String message, [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    final errorEntry = ErrorEntry(
      message: message,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      context: context ?? {},
      severity: ErrorSeverity.warning,
    );

    _addErrorEntry(errorEntry);
  }

  /// Log info message
  void logInfo(String message, [Map<String, dynamic>? context]) {
    final errorEntry = ErrorEntry(
      message: message,
      timestamp: DateTime.now(),
      context: context ?? {},
      severity: ErrorSeverity.info,
    );

    _addErrorEntry(errorEntry);
  }

  /// Log debug message (only in debug mode)
  void logDebug(String message, [Map<String, dynamic>? context]) {
    if (kDebugMode) {
      final errorEntry = ErrorEntry(
        message: message,
        timestamp: DateTime.now(),
        context: context ?? {},
        severity: ErrorSeverity.debug,
      );

      _addErrorEntry(errorEntry);
    }
  }

  /// Add error entry to log
  void _addErrorEntry(ErrorEntry entry) {
    _errorLog.add(entry);

    // Keep only last 1000 entries in memory
    if (_errorLog.length > 1000) {
      _errorLog.removeAt(0);
    }

    // Print to console in development
    if (kDebugMode) {
      _printToConsole(entry);
    }

    // Write to file if available
    _writeToFile(entry);
  }

  /// Print error entry to console
  void _printToConsole(ErrorEntry entry) {
    final severity = entry.severity.name.toUpperCase();

    developer.log(
      '[$severity] ${entry.message}',
      time: entry.timestamp,
      error: entry.error,
      stackTrace: entry.stackTrace,
      name: 'PaintVibes',
    );

    if (entry.context.isNotEmpty) {
      debugPrint('Context: ${entry.context}');
    }
  }

  /// Write error entry to log file
  void _writeToFile(ErrorEntry entry) {
    if (_logFile == null) return;

    try {
      final logLine = entry.toLogString();
      _logFile!.writeAsStringSync('$logLine\n', mode: FileMode.append);
    } catch (e) {
      // If we can't write to file, just continue
      debugPrint('Failed to write to log file: $e');
    }
  }

  /// Handle caught exceptions with context
  void handleException(
    dynamic exception,
    StackTrace stackTrace, {
    String? message,
    Map<String, dynamic>? context,
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    final errorMessage = message ?? 'Unhandled exception: $exception';

    final errorEntry = ErrorEntry(
      message: errorMessage,
      error: exception,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      context: context ?? {},
      severity: severity,
    );

    _addErrorEntry(errorEntry);
  }

  /// Show error dialog to user
  static void showErrorDialog(BuildContext context, String title, String message, {VoidCallback? onRetry}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.red[700],
        action: onAction != null && actionLabel != null
            ? SnackBarAction(label: actionLabel, onPressed: onAction, textColor: Colors.white)
            : null,
      ),
    );
  }

  /// Get all error entries
  List<ErrorEntry> get errorLog => List.unmodifiable(_errorLog);

  /// Get errors by severity
  List<ErrorEntry> getErrorsBySeverity(ErrorSeverity severity) {
    return _errorLog.where((entry) => entry.severity == severity).toList();
  }

  /// Get recent errors (last 24 hours)
  List<ErrorEntry> getRecentErrors() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _errorLog.where((entry) => entry.timestamp.isAfter(yesterday)).toList();
  }

  /// Clear error log
  void clearLog() {
    _errorLog.clear();
  }

  /// Export error log as string
  String exportLog() {
    final buffer = StringBuffer();
    buffer.writeln('Paint Vibes Error Log');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Total Entries: ${_errorLog.length}');
    buffer.writeln('${'=' * 50}');

    for (final entry in _errorLog) {
      buffer.writeln(entry.toLogString());
      buffer.writeln('-' * 30);
    }

    return buffer.toString();
  }

  /// Get error statistics
  Map<String, int> getErrorStatistics() {
    final stats = <String, int>{};

    for (final severity in ErrorSeverity.values) {
      stats[severity.name] = _errorLog.where((e) => e.severity == severity).length;
    }

    return stats;
  }
}

/// Error severity levels
enum ErrorSeverity { debug, info, warning, error, fatal }

/// Error entry containing all error information
class ErrorEntry {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final Map<String, dynamic> context;
  final String? library;
  final String? informationCollector;
  final ErrorSeverity severity;

  ErrorEntry({
    required this.message,
    this.error,
    this.stackTrace,
    required this.timestamp,
    required this.context,
    this.library,
    this.informationCollector,
    required this.severity,
  });

  /// Convert error entry to log string format
  String toLogString() {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('${timestamp.toIso8601String()} [${severity.name.toUpperCase()}] $message');

    // Error details
    if (error != null) {
      buffer.writeln('Error: $error');
    }

    // Stack trace
    if (stackTrace != null) {
      buffer.writeln('Stack Trace:');
      buffer.writeln(stackTrace.toString());
    }

    // Library
    if (library != null) {
      buffer.writeln('Library: $library');
    }

    // Context
    if (context.isNotEmpty) {
      buffer.writeln('Context:');
      context.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }

    // Information collector
    if (informationCollector != null) {
      buffer.writeln('Additional Information:');
      buffer.writeln(informationCollector);
    }

    return buffer.toString();
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'error': error?.toString(),
      'stackTrace': stackTrace?.toString(),
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'library': library,
      'informationCollector': informationCollector,
      'severity': severity.name,
    };
  }
}

/// Error handler utilities
class ErrorHandlerUtils {
  /// Wrap async operations with error handling
  static Future<T?> safeAsync<T>(
    Future<T> operation, {
    String? context,
    T? fallback,
    bool showUserError = false,
    BuildContext? buildContext,
  }) async {
    try {
      return await operation;
    } catch (error, stackTrace) {
      ErrorHandler.instance.handleException(
        error,
        stackTrace,
        message: context != null ? 'Error in $context' : null,
        context: {'operation': context ?? 'unknown'},
      );

      if (showUserError && buildContext != null) {
        ErrorHandler.showErrorSnackBar(buildContext, 'An error occurred. Please try again.');
      }

      return fallback;
    }
  }

  /// Wrap synchronous operations with error handling
  static T? safe<T>(
    T Function() operation, {
    String? context,
    T? fallback,
    bool showUserError = false,
    BuildContext? buildContext,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      ErrorHandler.instance.handleException(
        error,
        stackTrace,
        message: context != null ? 'Error in $context' : null,
        context: {'operation': context ?? 'unknown'},
      );

      if (showUserError && buildContext != null) {
        ErrorHandler.showErrorSnackBar(buildContext, 'An error occurred. Please try again.');
      }

      return fallback;
    }
  }
}

/// Extension for adding error handling to any object
extension ErrorHandling on Object {
  /// Execute function with error handling
  T? safeExecute<T>(T Function() function, {String? context, T? fallback}) {
    return ErrorHandlerUtils.safe(function, context: context ?? runtimeType.toString(), fallback: fallback);
  }

  /// Execute async function with error handling
  Future<T?> safeExecuteAsync<T>(Future<T> Function() function, {String? context, T? fallback}) {
    return ErrorHandlerUtils.safeAsync(function(), context: context ?? runtimeType.toString(), fallback: fallback);
  }
}

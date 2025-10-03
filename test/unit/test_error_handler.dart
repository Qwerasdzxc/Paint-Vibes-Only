import 'package:flutter_test/flutter_test.dart';
import 'package:painter/core/utils/error_handler.dart';

void main() {
  group('ErrorHandler Tests', () {
    late ErrorHandler errorHandler;

    setUp(() {
      errorHandler = ErrorHandler.instance;
      errorHandler.clearLog();
    });

    test('should be a singleton', () {
      final instance1 = ErrorHandler.instance;
      final instance2 = ErrorHandler.instance;

      expect(identical(instance1, instance2), true);
    });

    test('should log error messages', () {
      const message = 'Test error message';
      const error = 'Test error';
      final stackTrace = StackTrace.current;

      errorHandler.logError(message, error, stackTrace);

      final errorLog = errorHandler.errorLog;
      expect(errorLog.length, 1);
      expect(errorLog.first.message, message);
      expect(errorLog.first.error, error);
      expect(errorLog.first.stackTrace, stackTrace);
      expect(errorLog.first.severity, ErrorSeverity.error);
    });

    test('should log warnings', () {
      const message = 'Test warning';
      const error = 'Warning error';

      errorHandler.logWarning(message, error);

      final errorLog = errorHandler.errorLog;
      expect(errorLog.length, 1);
      expect(errorLog.first.message, message);
      expect(errorLog.first.error, error);
      expect(errorLog.first.severity, ErrorSeverity.warning);
    });

    test('should log info messages', () {
      const message = 'Test info message';
      final context = {'user': 'test_user'};

      errorHandler.logInfo(message, context);

      final errorLog = errorHandler.errorLog;
      expect(errorLog.length, 1);
      expect(errorLog.first.message, message);
      expect(errorLog.first.context, context);
      expect(errorLog.first.severity, ErrorSeverity.info);
    });

    test('should handle exceptions', () {
      final exception = Exception('Test exception');
      final stackTrace = StackTrace.current;
      const message = 'Custom exception message';
      final context = {'action': 'test'};

      errorHandler.handleException(
        exception,
        stackTrace,
        message: message,
        context: context,
        severity: ErrorSeverity.fatal,
      );

      final errorLog = errorHandler.errorLog;
      expect(errorLog.length, 1);
      expect(errorLog.first.message, message);
      expect(errorLog.first.error, exception);
      expect(errorLog.first.stackTrace, stackTrace);
      expect(errorLog.first.context, context);
      expect(errorLog.first.severity, ErrorSeverity.fatal);
    });

    test('should filter errors by severity', () {
      errorHandler.logError('Error 1', 'error');
      errorHandler.logWarning('Warning 1');
      errorHandler.logInfo('Info 1');
      errorHandler.logError('Error 2', 'error2');

      final errors = errorHandler.getErrorsBySeverity(ErrorSeverity.error);
      final warnings = errorHandler.getErrorsBySeverity(ErrorSeverity.warning);
      final infos = errorHandler.getErrorsBySeverity(ErrorSeverity.info);

      expect(errors.length, 2);
      expect(warnings.length, 1);
      expect(infos.length, 1);
      expect(errors.first.message, 'Error 1');
      expect(warnings.first.message, 'Warning 1');
      expect(infos.first.message, 'Info 1');
    });

    test('should get recent errors', () {
      // Add recent error
      errorHandler.logError('Recent error', 'recent');

      // Get recent errors
      final recentErrors = errorHandler.getRecentErrors();

      // All errors we added via logError will be recent
      expect(recentErrors.length, 1);
      expect(recentErrors.first.message, 'Recent error');
    });

    test('should clear error log', () {
      errorHandler.logError('Error 1', 'error1');
      errorHandler.logWarning('Warning 1');
      errorHandler.logInfo('Info 1');

      expect(errorHandler.errorLog.length, 3);

      errorHandler.clearLog();

      expect(errorHandler.errorLog.length, 0);
    });

    test('should export error log', () {
      errorHandler.logError('Test error', 'error');
      errorHandler.logWarning('Test warning');

      final exportedLog = errorHandler.exportLog();

      expect(exportedLog.contains('Paint Vibes Error Log'), true);
      expect(exportedLog.contains('Test error'), true);
      expect(exportedLog.contains('Test warning'), true);
      expect(exportedLog.contains('Total Entries: 2'), true);
    });

    test('should generate error statistics', () {
      errorHandler.logError('Error 1', 'error1');
      errorHandler.logError('Error 2', 'error2');
      errorHandler.logWarning('Warning 1');
      errorHandler.logInfo('Info 1');

      final stats = errorHandler.getErrorStatistics();

      expect(stats['error'], 2);
      expect(stats['warning'], 1);
      expect(stats['info'], 1);
      expect(stats['debug'], 0);
      expect(stats['fatal'], 0);
    });

    test('should limit error log size', () {
      // Add 1050 errors to test the limit
      for (int i = 0; i < 1050; i++) {
        errorHandler.logError('Error $i', 'error$i');
      }

      // Should keep only last 1000 entries
      expect(errorHandler.errorLog.length, 1000);

      // First error should be "Error 50" (since first 50 were removed)
      expect(errorHandler.errorLog.first.message, 'Error 50');

      // Last error should be "Error 1049"
      expect(errorHandler.errorLog.last.message, 'Error 1049');
    });
  });

  group('ErrorEntry Tests', () {
    test('should create error entry correctly', () {
      final timestamp = DateTime.now();
      const message = 'Test error entry';
      const error = 'Test error object';
      final stackTrace = StackTrace.current;
      final context = {'key': 'value'};

      final entry = ErrorEntry(
        message: message,
        error: error,
        stackTrace: stackTrace,
        timestamp: timestamp,
        context: context,
        library: 'test_library',
        informationCollector: 'Additional info',
        severity: ErrorSeverity.error,
      );

      expect(entry.message, message);
      expect(entry.error, error);
      expect(entry.stackTrace, stackTrace);
      expect(entry.timestamp, timestamp);
      expect(entry.context, context);
      expect(entry.library, 'test_library');
      expect(entry.informationCollector, 'Additional info');
      expect(entry.severity, ErrorSeverity.error);
    });

    test('should convert to log string format', () {
      final entry = ErrorEntry(
        message: 'Test log string',
        error: 'Test error',
        stackTrace: StackTrace.current,
        timestamp: DateTime(2023, 6, 15, 10, 30, 0),
        context: {'action': 'test', 'user': 'testUser'},
        library: 'test_lib',
        informationCollector: 'Extra info',
        severity: ErrorSeverity.warning,
      );

      final logString = entry.toLogString();

      expect(logString.contains('2023-06-15T10:30:00.000'), true);
      expect(logString.contains('[WARNING]'), true);
      expect(logString.contains('Test log string'), true);
      expect(logString.contains('Error: Test error'), true);
      expect(logString.contains('Library: test_lib'), true);
      expect(logString.contains('action: test'), true);
      expect(logString.contains('user: testUser'), true);
      expect(logString.contains('Extra info'), true);
    });

    test('should convert to JSON', () {
      final timestamp = DateTime(2023, 6, 15, 10, 30, 0);
      final entry = ErrorEntry(
        message: 'Test JSON',
        error: 'JSON error',
        stackTrace: StackTrace.current,
        timestamp: timestamp,
        context: {'test': 'json'},
        library: 'json_lib',
        informationCollector: 'JSON info',
        severity: ErrorSeverity.info,
      );

      final json = entry.toJson();

      expect(json['message'], 'Test JSON');
      expect(json['error'], 'JSON error');
      expect(json['timestamp'], '2023-06-15T10:30:00.000');
      expect(json['context'], {'test': 'json'});
      expect(json['library'], 'json_lib');
      expect(json['informationCollector'], 'JSON info');
      expect(json['severity'], 'info');
    });
  });

  group('ErrorHandlerUtils Tests', () {
    test('should handle async operations safely', () async {
      // Test successful operation
      final result = await ErrorHandlerUtils.safeAsync<String>(Future.value('success'), context: 'test operation');

      expect(result, 'success');

      // Test failing operation with fallback
      final fallbackResult = await ErrorHandlerUtils.safeAsync<String>(
        Future.error('test error'),
        context: 'failing operation',
        fallback: 'fallback value',
      );

      expect(fallbackResult, 'fallback value');

      // Check that error was logged
      final errorHandler = ErrorHandler.instance;
      final errors = errorHandler.getErrorsBySeverity(ErrorSeverity.error);
      expect(errors.isNotEmpty, true);
      expect(errors.last.message, 'Error in failing operation');
    });

    test('should handle synchronous operations safely', () {
      // Test successful operation
      final result = ErrorHandlerUtils.safe<int>(() => 42, context: 'sync operation');

      expect(result, 42);

      // Test failing operation with fallback
      final fallbackResult = ErrorHandlerUtils.safe<int>(
        () => throw Exception('sync error'),
        context: 'failing sync operation',
        fallback: 100,
      );

      expect(fallbackResult, 100);

      // Check that error was logged
      final errorHandler = ErrorHandler.instance;
      final errors = errorHandler.getErrorsBySeverity(ErrorSeverity.error);
      expect(errors.isNotEmpty, true);
    });
  });

  group('ErrorHandling Extension Tests', () {
    test('should provide safe execution methods', () {
      final testObject = 'test';

      // Test successful execution
      final result = testObject.safeExecute<int>(() => 123, context: 'extension test');

      expect(result, 123);

      // Test failing execution with fallback
      final fallbackResult = testObject.safeExecute<int>(
        () => throw Exception('extension error'),
        context: 'extension failure',
        fallback: 999,
      );

      expect(fallbackResult, 999);
    });

    test('should provide safe async execution methods', () async {
      final testObject = 'async test';

      // Test successful async execution
      final result = await testObject.safeExecuteAsync<String>(
        () => Future.value('async success'),
        context: 'async extension test',
      );

      expect(result, 'async success');

      // Test failing async execution with fallback
      final fallbackResult = await testObject.safeExecuteAsync<String>(
        () => Future.error('async error'),
        context: 'async extension failure',
        fallback: 'async fallback',
      );

      expect(fallbackResult, 'async fallback');
    });
  });

  group('Error Severity Tests', () {
    test('should have all severity levels', () {
      expect(ErrorSeverity.values.length, 5);
      expect(ErrorSeverity.values.contains(ErrorSeverity.debug), true);
      expect(ErrorSeverity.values.contains(ErrorSeverity.info), true);
      expect(ErrorSeverity.values.contains(ErrorSeverity.warning), true);
      expect(ErrorSeverity.values.contains(ErrorSeverity.error), true);
      expect(ErrorSeverity.values.contains(ErrorSeverity.fatal), true);
    });

    test('should have correct string names', () {
      expect(ErrorSeverity.debug.name, 'debug');
      expect(ErrorSeverity.info.name, 'info');
      expect(ErrorSeverity.warning.name, 'warning');
      expect(ErrorSeverity.error.name, 'error');
      expect(ErrorSeverity.fatal.name, 'fatal');
    });
  });
}

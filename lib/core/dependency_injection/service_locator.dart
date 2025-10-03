import 'package:painter/core/storage/file_storage_manager.dart';
import 'package:painter/features/drawing/services/drawing_service.dart';
import 'package:painter/features/drawing/services/color_service.dart';
import 'package:painter/core/services/artwork_service.dart';
import 'package:painter/core/services/coloring_service.dart';
import 'package:painter/core/services/file_service.dart';
import 'package:painter/core/services/settings_service.dart';
import 'package:painter/core/services/event_service.dart';
import 'package:painter/features/drawing/services/i_drawing_service.dart';
import 'package:painter/features/drawing/services/i_color_service.dart';
import 'package:painter/features/gallery/services/i_artwork_service.dart';
import 'package:painter/features/coloring/services/i_coloring_service.dart';
import 'package:painter/core/storage/i_file_service.dart';
import 'package:painter/core/services/i_settings_service.dart';
import 'package:painter/core/services/i_event_service.dart';

/// Simple service locator for dependency injection
/// Manages service registration and resolution without external dependencies
class ServiceLocator {
  static final Map<Type, Object> _services = {};
  static bool _isInitialized = false;

  /// Initialize all services and register dependencies
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Core services
    await _registerStorageServices();
    await _registerCoreServices();
    await _registerFeatureServices();

    _isInitialized = true;
  }

  /// Register storage-related services
  static Future<void> _registerStorageServices() async {
    // File storage manager - singleton
    final fileStorageManager = FileStorageManager();
    await fileStorageManager.initialize();
    _services[FileStorageManager] = fileStorageManager;

    // File service - singleton
    _services[IFileService] = FileService();
  }

  /// Register core application services
  static Future<void> _registerCoreServices() async {
    // Settings service - singleton
    _services[ISettingsService] = SettingsService();

    // Event service - singleton
    _services[IEventService] = EventService();

    // Artwork service - singleton
    _services[IArtworkService] = ArtworkService();

    // Coloring service - singleton
    _services[IColoringService] = ColoringService();
  }

  /// Register feature-specific services
  static Future<void> _registerFeatureServices() async {
    // Drawing service - singleton
    _services[IDrawingService] = DrawingService();

    // Color service - singleton
    _services[IColorService] = ColorService();
  }

  /// Get service instance by type
  static T get<T extends Object>() {
    if (!_isInitialized) {
      throw Exception('ServiceLocator not initialized. Call initialize() first.');
    }

    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T not registered.');
    }

    return service as T;
  }

  /// Register a service manually
  static void register<T extends Object>(T service) {
    _services[T] = service;
  }

  /// Check if a service is registered
  static bool isRegistered<T extends Object>() {
    return _services.containsKey(T);
  }

  /// Reset all services (for testing)
  static Future<void> reset() async {
    _services.clear();
    _isInitialized = false;
  }

  /// Dispose of all services
  static Future<void> dispose() async {
    // Dispose services that need cleanup
    // Note: EventService dispose method would be called here if it had one

    _services.clear();
    _isInitialized = false;
  }
}

/// Service locator extensions for easy access
extension ServiceLocatorExtensions on Object {
  /// Get service from service locator
  T getService<T extends Object>() => ServiceLocator.get<T>();
}

/// Service locator helper methods
class Services {
  /// Get file storage manager
  static FileStorageManager get storage => ServiceLocator.get<FileStorageManager>();

  /// Get file service
  static IFileService get file => ServiceLocator.get<IFileService>();

  /// Get settings service
  static ISettingsService get settings => ServiceLocator.get<ISettingsService>();

  /// Get event service
  static IEventService get events => ServiceLocator.get<IEventService>();

  /// Get artwork service
  static IArtworkService get artwork => ServiceLocator.get<IArtworkService>();

  /// Get coloring service
  static IColoringService get coloring => ServiceLocator.get<IColoringService>();

  /// Get drawing service
  static IDrawingService get drawing => ServiceLocator.get<IDrawingService>();

  /// Get color service
  static IColorService get color => ServiceLocator.get<IColorService>();
}

/// Service configuration class for customizing service behavior
class ServiceConfiguration {
  final bool enableLogging;
  final bool enableCaching;
  final Duration cacheTimeout;
  final int maxCacheSize;

  const ServiceConfiguration({
    this.enableLogging = true,
    this.enableCaching = true,
    this.cacheTimeout = const Duration(minutes: 30),
    this.maxCacheSize = 100,
  });

  static const ServiceConfiguration development = ServiceConfiguration(
    enableLogging: true,
    enableCaching: false, // Disable caching for development
  );

  static const ServiceConfiguration production = ServiceConfiguration(
    enableLogging: false,
    enableCaching: true,
    cacheTimeout: Duration(hours: 1),
    maxCacheSize: 200,
  );

  static const ServiceConfiguration testing = ServiceConfiguration(enableLogging: false, enableCaching: false);
}

/// Dependency injection helper for widgets
class DependencyProvider {
  /// Initialize services for the app
  static Future<void> initializeApp({ServiceConfiguration? configuration}) async {
    try {
      await ServiceLocator.initialize();

      // Configure services based on configuration
      if (configuration != null) {
        await _configureServices(configuration);
      }
    } catch (e) {
      // Handle initialization errors
      throw Exception('Failed to initialize services: $e');
    }
  }

  /// Configure services with provided configuration
  static Future<void> _configureServices(ServiceConfiguration config) async {
    // Configuration would be applied here if services supported it
    // For now, this is a placeholder for future configuration needs
  }

  /// Clean up services when app is disposed
  static Future<void> disposeApp() async {
    await ServiceLocator.dispose();
  }
}

/// Service mock registry for testing
class ServiceMockRegistry {
  static final Map<Type, Object> _mocks = {};

  /// Register a mock service
  static void registerMock<T extends Object>(T mock) {
    _mocks[T] = mock;
  }

  /// Clear all mocks
  static void clearMocks() {
    _mocks.clear();
  }

  /// Check if mock is registered
  static bool hasMock<T extends Object>() {
    return _mocks.containsKey(T);
  }

  /// Get mock service
  static T getMock<T extends Object>() {
    final mock = _mocks[T];
    if (mock == null) {
      throw Exception('Mock not registered for type $T');
    }
    return mock as T;
  }

  /// Initialize service locator with mocks for testing
  static Future<void> initializeWithMocks() async {
    await ServiceLocator.reset();

    // Register mocks instead of real services
    for (final entry in _mocks.entries) {
      ServiceLocator.register(entry.value);
    }
  }
}

/// Service health check utility
class ServiceHealthCheck {
  /// Check if all critical services are available and healthy
  static Future<Map<String, bool>> checkServicesHealth() async {
    final results = <String, bool>{};

    try {
      // Check storage service
      ServiceLocator.get<FileStorageManager>();
      results['FileStorageManager'] = true;

      // Check file service
      ServiceLocator.get<IFileService>();
      results['FileService'] = true;

      // Check settings service
      ServiceLocator.get<ISettingsService>();
      results['SettingsService'] = true;

      // Check event service
      ServiceLocator.get<IEventService>();
      results['EventService'] = true;

      // Check artwork service
      ServiceLocator.get<IArtworkService>();
      results['ArtworkService'] = true;

      // Check drawing service
      ServiceLocator.get<IDrawingService>();
      results['DrawingService'] = true;

      // Check color service
      ServiceLocator.get<IColorService>();
      results['ColorService'] = true;

      // Check coloring service
      ServiceLocator.get<IColoringService>();
      results['ColoringService'] = true;
    } catch (e) {
      // Mark failed services as unhealthy
      results['ServiceLocator'] = false;
    }

    return results;
  }

  /// Get a summary of service health
  static Future<String> getHealthSummary() async {
    final health = await checkServicesHealth();
    final healthy = health.values.where((v) => v).length;
    final total = health.length;

    return '$healthy/$total services healthy';
  }
}

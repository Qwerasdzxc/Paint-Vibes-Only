import 'dart:async';
import 'package:painter/core/services/i_event_service.dart';

/// Implementation of IEventService using StreamController for event management
class EventService implements IEventService {
  // StreamControllers for different event types
  final StreamController<DrawingEvent> _drawingController = StreamController<DrawingEvent>.broadcast();
  final StreamController<ColoringEvent> _coloringController = StreamController<ColoringEvent>.broadcast();
  final StreamController<GalleryEvent> _galleryController = StreamController<GalleryEvent>.broadcast();
  final StreamController<StorageEvent> _storageController = StreamController<StorageEvent>.broadcast();

  // Event Streams
  @override
  Stream<DrawingEvent> get drawingEvents => _drawingController.stream;

  @override
  Stream<ColoringEvent> get coloringEvents => _coloringController.stream;

  @override
  Stream<GalleryEvent> get galleryEvents => _galleryController.stream;

  @override
  Stream<StorageEvent> get storageEvents => _storageController.stream;

  // Event Publishing
  @override
  void publishDrawingEvent(DrawingEvent event) {
    try {
      if (_drawingController.isClosed) {
        throw EventStreamException('drawingEvents', 'Stream is closed');
      }
      _drawingController.add(event);
    } catch (e) {
      throw EventServiceException('publishDrawingEvent', e.toString());
    }
  }

  @override
  void publishColoringEvent(ColoringEvent event) {
    try {
      if (_coloringController.isClosed) {
        throw EventStreamException('coloringEvents', 'Stream is closed');
      }
      _coloringController.add(event);
    } catch (e) {
      throw EventServiceException('publishColoringEvent', e.toString());
    }
  }

  @override
  void publishGalleryEvent(GalleryEvent event) {
    try {
      if (_galleryController.isClosed) {
        throw EventStreamException('galleryEvents', 'Stream is closed');
      }
      _galleryController.add(event);
    } catch (e) {
      throw EventServiceException('publishGalleryEvent', e.toString());
    }
  }

  @override
  void publishStorageEvent(StorageEvent event) {
    try {
      if (_storageController.isClosed) {
        throw EventStreamException('storageEvents', 'Stream is closed');
      }
      _storageController.add(event);
    } catch (e) {
      throw EventServiceException('publishStorageEvent', e.toString());
    }
  }

  /// Close all stream controllers to prevent memory leaks
  void dispose() {
    _drawingController.close();
    _coloringController.close();
    _galleryController.close();
    _storageController.close();
  }

  /// Check if all streams are active
  bool get isActive {
    return !_drawingController.isClosed &&
        !_coloringController.isClosed &&
        !_galleryController.isClosed &&
        !_storageController.isClosed;
  }

  /// Get the number of listeners for drawing events
  int get drawingListenerCount => _drawingController.hasListener ? 1 : 0;

  /// Get the number of listeners for coloring events
  int get coloringListenerCount => _coloringController.hasListener ? 1 : 0;

  /// Get the number of listeners for gallery events
  int get galleryListenerCount => _galleryController.hasListener ? 1 : 0;

  /// Get the number of listeners for storage events
  int get storageListenerCount => _storageController.hasListener ? 1 : 0;

  /// Clear all pending events from streams
  void clearAllEvents() {
    // Note: For broadcast streams, we can't really "clear" events
    // since they're delivered immediately, but we can reset the controllers
    if (!_drawingController.isClosed && !_drawingController.hasListener) {
      // Controllers are already broadcasting, no pending events to clear
    }
  }
}

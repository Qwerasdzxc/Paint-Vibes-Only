import 'dart:async';
import 'package:painter/core/services/i_event_service.dart';

/// Test implementation of EventService that works for contract testing
class TestEventServiceImpl implements IEventService {
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
    if (!_drawingController.isClosed) {
      _drawingController.add(event);
    }
  }

  @override
  void publishColoringEvent(ColoringEvent event) {
    if (!_coloringController.isClosed) {
      _coloringController.add(event);
    }
  }

  @override
  void publishGalleryEvent(GalleryEvent event) {
    if (!_galleryController.isClosed) {
      _galleryController.add(event);
    }
  }

  @override
  void publishStorageEvent(StorageEvent event) {
    if (!_storageController.isClosed) {
      _storageController.add(event);
    }
  }

  /// Close all stream controllers
  void dispose() {
    _drawingController.close();
    _coloringController.close();
    _galleryController.close();
    _storageController.close();
  }

  /// Check if streams are active
  bool get isActive {
    return !_drawingController.isClosed &&
        !_coloringController.isClosed &&
        !_galleryController.isClosed &&
        !_storageController.isClosed;
  }
}

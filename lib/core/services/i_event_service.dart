import 'dart:async';

/// Interface for application-wide event management
abstract class IEventService {
  // Event Streams
  Stream<DrawingEvent> get drawingEvents;
  Stream<ColoringEvent> get coloringEvents;
  Stream<GalleryEvent> get galleryEvents;
  Stream<StorageEvent> get storageEvents;

  // Event Publishing
  void publishDrawingEvent(DrawingEvent event);
  void publishColoringEvent(ColoringEvent event);
  void publishGalleryEvent(GalleryEvent event);
  void publishStorageEvent(StorageEvent event);
}

// Event Base Classes
abstract class AppEvent {
  final DateTime timestamp;
  final String eventId;
  AppEvent(this.eventId) : timestamp = DateTime.now();
}

class DrawingEvent extends AppEvent {
  final String canvasId;
  final DrawingEventType type;
  final dynamic data;
  DrawingEvent(String eventId, this.canvasId, this.type, this.data) : super(eventId);
}

enum DrawingEventType {
  strokeAdded,
  strokeRemoved,
  canvasCleared,
  toolChanged,
  colorChanged,
  undoPerformed,
  redoPerformed,
}

class ColoringEvent extends AppEvent {
  final String progressId;
  final ColoringEventType type;
  final dynamic data;
  ColoringEvent(String eventId, this.progressId, this.type, this.data) : super(eventId);
}

enum ColoringEventType { pageStarted, progressSaved, pageCompleted, regionColored }

class GalleryEvent extends AppEvent {
  final String? artworkId;
  final GalleryEventType type;
  final dynamic data;
  GalleryEvent(String eventId, this.artworkId, this.type, this.data) : super(eventId);
}

enum GalleryEventType { artworkCreated, artworkUpdated, artworkDeleted, artworkShared, galleryRefreshed }

class StorageEvent extends AppEvent {
  final StorageEventType type;
  final String details;
  StorageEvent(String eventId, this.type, this.details) : super(eventId);
}

enum StorageEventType { lowStorage, backupCreated, cleanupCompleted, storageError }

/// Custom exceptions for event service operations
class EventServiceException implements Exception {
  final String operation;
  final String details;
  EventServiceException(this.operation, this.details);
  String toString() => 'Event service error during $operation: $details';
}

class EventStreamException implements Exception {
  final String streamName;
  final String reason;
  EventStreamException(this.streamName, this.reason);
  String toString() => 'Event stream error for $streamName: $reason';
}

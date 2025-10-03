import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:painter/core/services/i_event_service.dart';
import 'test_event_service_impl.dart';

/// Contract test for IEventService interface
/// These tests define the behavior contract for event management
void main() {
  group('IEventService Contract Tests', () {
    late IEventService eventService;

    setUp(() {
      // Using test implementation for contract validation
      eventService = TestEventServiceImpl();
    });

    tearDown(() {
      // Clean up
      if (eventService is TestEventServiceImpl) {
        (eventService as TestEventServiceImpl).dispose();
      }
    });

    test('should provide drawing events stream', () {
      expect(eventService.drawingEvents, isA<Stream<DrawingEvent>>());
    });

    test('should provide coloring events stream', () {
      expect(eventService.coloringEvents, isA<Stream<ColoringEvent>>());
    });

    test('should provide gallery events stream', () {
      expect(eventService.galleryEvents, isA<Stream<GalleryEvent>>());
    });

    test('should provide storage events stream', () {
      expect(eventService.storageEvents, isA<Stream<StorageEvent>>());
    });

    test('should publish and receive drawing event', () async {
      final event = DrawingEvent('event-123', 'canvas-123', DrawingEventType.strokeAdded, {
        'brushSize': 5.0,
        'color': '#FF0000',
      });

      // Set up stream listener
      final completer = Completer<DrawingEvent>();
      final subscription = eventService.drawingEvents.listen(completer.complete);

      // Publish event
      eventService.publishDrawingEvent(event);

      // Wait for event
      final receivedEvent = await completer.future;
      expect(receivedEvent.eventId, equals('event-123'));
      expect(receivedEvent.canvasId, equals('canvas-123'));
      expect(receivedEvent.type, equals(DrawingEventType.strokeAdded));

      await subscription.cancel();
    });

    test('should publish and receive coloring event', () async {
      final event = ColoringEvent('event-124', 'progress-123', ColoringEventType.regionColored, {
        'regionId': 'region-1',
        'color': '#00FF00',
      });

      // Set up stream listener
      final completer = Completer<ColoringEvent>();
      final subscription = eventService.coloringEvents.listen(completer.complete);

      // Publish event
      eventService.publishColoringEvent(event);

      // Wait for event
      final receivedEvent = await completer.future;
      expect(receivedEvent.eventId, equals('event-124'));
      expect(receivedEvent.progressId, equals('progress-123'));
      expect(receivedEvent.type, equals(ColoringEventType.regionColored));

      await subscription.cancel();
    });

    test('should publish and receive gallery event', () async {
      final event = GalleryEvent('event-125', 'artwork-123', GalleryEventType.artworkCreated, {'title': 'My Drawing'});

      // Set up stream listener
      final completer = Completer<GalleryEvent>();
      final subscription = eventService.galleryEvents.listen(completer.complete);

      // Publish event
      eventService.publishGalleryEvent(event);

      // Wait for event
      final receivedEvent = await completer.future;
      expect(receivedEvent.eventId, equals('event-125'));
      expect(receivedEvent.artworkId, equals('artwork-123'));
      expect(receivedEvent.type, equals(GalleryEventType.artworkCreated));

      await subscription.cancel();
    });

    test('should publish and receive storage event', () async {
      final event = StorageEvent(
        'event-126',
        StorageEventType.backupCreated,
        'Backup created at /storage/backups/backup.zip',
      );

      // Set up stream listener
      final completer = Completer<StorageEvent>();
      final subscription = eventService.storageEvents.listen(completer.complete);

      // Publish event
      eventService.publishStorageEvent(event);

      // Wait for event
      final receivedEvent = await completer.future;
      expect(receivedEvent.eventId, equals('event-126'));
      expect(receivedEvent.type, equals(StorageEventType.backupCreated));
      expect(receivedEvent.details, equals('Backup created at /storage/backups/backup.zip'));

      await subscription.cancel();
    });
  });
}

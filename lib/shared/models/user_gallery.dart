import 'package:painter/features/gallery/services/i_artwork_service.dart';
import 'package:painter/core/services/i_settings_service.dart';

/// Represents user's personalized gallery configuration and collections
class UserGallery {
  final String userId;
  final String displayName;
  final GalleryViewMode defaultViewMode;
  final GallerySortOrder defaultSortOrder;
  final bool showRecentFirst;
  final int itemsPerPage;
  final List<CustomCollection> customCollections;
  final List<String> pinnedArtworkIds;
  final List<String> hiddenArtworkIds;
  final Map<String, String> artworkNotes;
  final DateTime lastAccessed;
  final GallerySettings settings;

  UserGallery({
    required this.userId,
    required this.displayName,
    required this.defaultViewMode,
    required this.defaultSortOrder,
    required this.showRecentFirst,
    required this.itemsPerPage,
    required this.customCollections,
    required this.pinnedArtworkIds,
    required this.hiddenArtworkIds,
    required this.artworkNotes,
    required this.lastAccessed,
    required this.settings,
  });

  /// Create a copy of this user gallery with modified properties
  UserGallery copyWith({
    String? userId,
    String? displayName,
    GalleryViewMode? defaultViewMode,
    GallerySortOrder? defaultSortOrder,
    bool? showRecentFirst,
    int? itemsPerPage,
    List<CustomCollection>? customCollections,
    List<String>? pinnedArtworkIds,
    List<String>? hiddenArtworkIds,
    Map<String, String>? artworkNotes,
    DateTime? lastAccessed,
    GallerySettings? settings,
  }) {
    return UserGallery(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      defaultViewMode: defaultViewMode ?? this.defaultViewMode,
      defaultSortOrder: defaultSortOrder ?? this.defaultSortOrder,
      showRecentFirst: showRecentFirst ?? this.showRecentFirst,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      customCollections: customCollections ?? List.from(this.customCollections),
      pinnedArtworkIds: pinnedArtworkIds ?? List.from(this.pinnedArtworkIds),
      hiddenArtworkIds: hiddenArtworkIds ?? List.from(this.hiddenArtworkIds),
      artworkNotes: artworkNotes ?? Map.from(this.artworkNotes),
      lastAccessed: lastAccessed ?? this.lastAccessed,
      settings: settings ?? this.settings,
    );
  }

  /// Convert user gallery to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'defaultViewMode': defaultViewMode.toString().split('.').last,
      'defaultSortOrder': defaultSortOrder.toString().split('.').last,
      'showRecentFirst': showRecentFirst,
      'itemsPerPage': itemsPerPage,
      'customCollections': customCollections.map((c) => c.toJson()).toList(),
      'pinnedArtworkIds': pinnedArtworkIds,
      'hiddenArtworkIds': hiddenArtworkIds,
      'artworkNotes': artworkNotes,
      'lastAccessed': lastAccessed.toIso8601String(),
      'settings': settings.toJson(),
    };
  }

  /// Create user gallery from JSON
  factory UserGallery.fromJson(Map<String, dynamic> json) {
    return UserGallery(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      defaultViewMode: GalleryViewMode.values.firstWhere(
        (mode) => mode.toString().split('.').last == json['defaultViewMode'],
        orElse: () => GalleryViewMode.grid,
      ),
      defaultSortOrder: GallerySortOrder.values.firstWhere(
        (order) => order.toString().split('.').last == json['defaultSortOrder'],
        orElse: () => GallerySortOrder.dateCreated,
      ),
      showRecentFirst: json['showRecentFirst'] as bool,
      itemsPerPage: json['itemsPerPage'] as int,
      customCollections: (json['customCollections'] as List)
          .map((c) => CustomCollection.fromJson(c as Map<String, dynamic>))
          .toList(),
      pinnedArtworkIds: List<String>.from(json['pinnedArtworkIds'] as List),
      hiddenArtworkIds: List<String>.from(json['hiddenArtworkIds'] as List),
      artworkNotes: Map<String, String>.from(json['artworkNotes'] as Map),
      lastAccessed: DateTime.parse(json['lastAccessed'] as String),
      settings: GallerySettings.fromJson(json['settings'] as Map<String, dynamic>),
    );
  }

  /// Create a default user gallery for new users
  factory UserGallery.createDefault(String userId, String displayName) {
    return UserGallery(
      userId: userId,
      displayName: displayName,
      defaultViewMode: GalleryViewMode.grid,
      defaultSortOrder: GallerySortOrder.dateCreated,
      showRecentFirst: true,
      itemsPerPage: 20,
      customCollections: [
        CustomCollection.createDefault('Favorites'),
        CustomCollection.createDefault('Work in Progress'),
      ],
      pinnedArtworkIds: [],
      hiddenArtworkIds: [],
      artworkNotes: {},
      lastAccessed: DateTime.now(),
      settings: GallerySettings.createDefault(),
    );
  }

  /// Validation rules
  bool get isValid {
    return userId.isNotEmpty &&
        displayName.isNotEmpty &&
        displayName.length <= 50 &&
        itemsPerPage > 0 &&
        itemsPerPage <= 100 &&
        customCollections.every((c) => c.isValid);
  }

  /// Get collection by id
  CustomCollection? getCollection(String collectionId) {
    try {
      return customCollections.firstWhere((c) => c.id == collectionId);
    } catch (_) {
      return null;
    }
  }

  /// Add artwork to collection
  UserGallery addArtworkToCollection(String artworkId, String collectionId) {
    final collections = List<CustomCollection>.from(customCollections);
    final collectionIndex = collections.indexWhere((c) => c.id == collectionId);

    if (collectionIndex >= 0) {
      collections[collectionIndex] = collections[collectionIndex].addArtwork(artworkId);
    }

    return copyWith(customCollections: collections);
  }

  /// Remove artwork from collection
  UserGallery removeArtworkFromCollection(String artworkId, String collectionId) {
    final collections = List<CustomCollection>.from(customCollections);
    final collectionIndex = collections.indexWhere((c) => c.id == collectionId);

    if (collectionIndex >= 0) {
      collections[collectionIndex] = collections[collectionIndex].removeArtwork(artworkId);
    }

    return copyWith(customCollections: collections);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserGallery && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'UserGallery{userId: $userId, displayName: $displayName, collections: ${customCollections.length}}';
  }
}

/// Represents a custom collection of artworks
class CustomCollection {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String color;
  final List<String> artworkIds;
  final DateTime createdAt;
  final DateTime lastModified;
  final bool isDefault;
  final Map<String, dynamic> customProperties;

  CustomCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.color,
    required this.artworkIds,
    required this.createdAt,
    required this.lastModified,
    required this.isDefault,
    required this.customProperties,
  });

  /// Create a copy of this collection with modified properties
  CustomCollection copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    String? color,
    List<String>? artworkIds,
    DateTime? createdAt,
    DateTime? lastModified,
    bool? isDefault,
    Map<String, dynamic>? customProperties,
  }) {
    return CustomCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      artworkIds: artworkIds ?? List.from(this.artworkIds),
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      isDefault: isDefault ?? this.isDefault,
      customProperties: customProperties ?? Map.from(this.customProperties),
    );
  }

  /// Convert custom collection to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'color': color,
      'artworkIds': artworkIds,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'isDefault': isDefault,
      'customProperties': customProperties,
    };
  }

  /// Create custom collection from JSON
  factory CustomCollection.fromJson(Map<String, dynamic> json) {
    return CustomCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      color: json['color'] as String,
      artworkIds: List<String>.from(json['artworkIds'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
      isDefault: json['isDefault'] as bool,
      customProperties: Map<String, dynamic>.from(json['customProperties'] as Map),
    );
  }

  /// Create a default collection
  factory CustomCollection.createDefault(String name) {
    final now = DateTime.now();
    return CustomCollection(
      id: 'collection_${now.millisecondsSinceEpoch}',
      name: name,
      description: 'Default $name collection',
      iconName: name == 'Favorites' ? 'favorite' : 'folder',
      color: name == 'Favorites' ? '#FF5722' : '#2196F3',
      artworkIds: [],
      createdAt: now,
      lastModified: now,
      isDefault: true,
      customProperties: {},
    );
  }

  /// Add artwork to collection
  CustomCollection addArtwork(String artworkId) {
    if (artworkIds.contains(artworkId)) return this;

    final newArtworkIds = List<String>.from(artworkIds)..add(artworkId);
    return copyWith(artworkIds: newArtworkIds, lastModified: DateTime.now());
  }

  /// Remove artwork from collection
  CustomCollection removeArtwork(String artworkId) {
    final newArtworkIds = List<String>.from(artworkIds)..remove(artworkId);
    return copyWith(artworkIds: newArtworkIds, lastModified: DateTime.now());
  }

  /// Validation rules
  bool get isValid {
    return id.isNotEmpty && name.isNotEmpty && name.length <= 50 && color.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomCollection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CustomCollection{id: $id, name: $name, artworks: ${artworkIds.length}}';
  }
}

/// Gallery-specific settings for user preferences
class GallerySettings {
  final bool showThumbnails;
  final bool enableSearch;
  final bool showArtworkStats;
  final bool enableTagFiltering;
  final int thumbnailSize;
  final bool autoRefresh;
  final Duration autoRefreshInterval;
  final bool showGridLines;
  final bool enableDragAndDrop;
  final Map<String, bool> columnVisibility;

  GallerySettings({
    required this.showThumbnails,
    required this.enableSearch,
    required this.showArtworkStats,
    required this.enableTagFiltering,
    required this.thumbnailSize,
    required this.autoRefresh,
    required this.autoRefreshInterval,
    required this.showGridLines,
    required this.enableDragAndDrop,
    required this.columnVisibility,
  });

  /// Create a copy of gallery settings with modified properties
  GallerySettings copyWith({
    bool? showThumbnails,
    bool? enableSearch,
    bool? showArtworkStats,
    bool? enableTagFiltering,
    int? thumbnailSize,
    bool? autoRefresh,
    Duration? autoRefreshInterval,
    bool? showGridLines,
    bool? enableDragAndDrop,
    Map<String, bool>? columnVisibility,
  }) {
    return GallerySettings(
      showThumbnails: showThumbnails ?? this.showThumbnails,
      enableSearch: enableSearch ?? this.enableSearch,
      showArtworkStats: showArtworkStats ?? this.showArtworkStats,
      enableTagFiltering: enableTagFiltering ?? this.enableTagFiltering,
      thumbnailSize: thumbnailSize ?? this.thumbnailSize,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      autoRefreshInterval: autoRefreshInterval ?? this.autoRefreshInterval,
      showGridLines: showGridLines ?? this.showGridLines,
      enableDragAndDrop: enableDragAndDrop ?? this.enableDragAndDrop,
      columnVisibility: columnVisibility ?? Map.from(this.columnVisibility),
    );
  }

  /// Convert gallery settings to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'showThumbnails': showThumbnails,
      'enableSearch': enableSearch,
      'showArtworkStats': showArtworkStats,
      'enableTagFiltering': enableTagFiltering,
      'thumbnailSize': thumbnailSize,
      'autoRefresh': autoRefresh,
      'autoRefreshIntervalSeconds': autoRefreshInterval.inSeconds,
      'showGridLines': showGridLines,
      'enableDragAndDrop': enableDragAndDrop,
      'columnVisibility': columnVisibility,
    };
  }

  /// Create gallery settings from JSON
  factory GallerySettings.fromJson(Map<String, dynamic> json) {
    return GallerySettings(
      showThumbnails: json['showThumbnails'] as bool,
      enableSearch: json['enableSearch'] as bool,
      showArtworkStats: json['showArtworkStats'] as bool,
      enableTagFiltering: json['enableTagFiltering'] as bool,
      thumbnailSize: json['thumbnailSize'] as int,
      autoRefresh: json['autoRefresh'] as bool,
      autoRefreshInterval: Duration(seconds: json['autoRefreshIntervalSeconds'] as int),
      showGridLines: json['showGridLines'] as bool,
      enableDragAndDrop: json['enableDragAndDrop'] as bool,
      columnVisibility: Map<String, bool>.from(json['columnVisibility'] as Map),
    );
  }

  /// Create default gallery settings
  factory GallerySettings.createDefault() {
    return GallerySettings(
      showThumbnails: true,
      enableSearch: true,
      showArtworkStats: true,
      enableTagFiltering: true,
      thumbnailSize: 150,
      autoRefresh: false,
      autoRefreshInterval: const Duration(minutes: 5),
      showGridLines: false,
      enableDragAndDrop: true,
      columnVisibility: {'title': true, 'dateCreated': true, 'dateModified': true, 'strokeCount': false, 'tags': true},
    );
  }

  /// Validation rules
  bool get isValid {
    return thumbnailSize >= 50 && thumbnailSize <= 500 && autoRefreshInterval.inSeconds >= 30;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GallerySettings &&
        other.showThumbnails == showThumbnails &&
        other.enableSearch == enableSearch &&
        other.thumbnailSize == thumbnailSize;
  }

  @override
  int get hashCode => Object.hash(showThumbnails, enableSearch, thumbnailSize);

  @override
  String toString() {
    return 'GallerySettings{thumbnails: $showThumbnails, search: $enableSearch}';
  }
}

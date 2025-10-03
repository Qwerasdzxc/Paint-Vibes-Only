/// Represents user's progress on individual coloring pages
class ColoringProgress {
  final String id;
  final String coloringPageId;
  final String userId;
  final String progressImagePath;
  final String canvasDataPath;
  final double completionPercent;
  final DateTime startedAt;
  final DateTime lastWorkedOn;
  final bool isCompleted;
  final Duration totalTimeSpent;

  ColoringProgress({
    required this.id,
    required this.coloringPageId,
    required this.userId,
    required this.progressImagePath,
    required this.canvasDataPath,
    required this.completionPercent,
    required this.startedAt,
    required this.lastWorkedOn,
    required this.isCompleted,
    required this.totalTimeSpent,
  });

  /// Create a copy of this progress with modified properties
  ColoringProgress copyWith({
    String? id,
    String? coloringPageId,
    String? userId,
    String? progressImagePath,
    String? canvasDataPath,
    double? completionPercent,
    DateTime? startedAt,
    DateTime? lastWorkedOn,
    bool? isCompleted,
    Duration? totalTimeSpent,
  }) {
    return ColoringProgress(
      id: id ?? this.id,
      coloringPageId: coloringPageId ?? this.coloringPageId,
      userId: userId ?? this.userId,
      progressImagePath: progressImagePath ?? this.progressImagePath,
      canvasDataPath: canvasDataPath ?? this.canvasDataPath,
      completionPercent: completionPercent ?? this.completionPercent,
      startedAt: startedAt ?? this.startedAt,
      lastWorkedOn: lastWorkedOn ?? this.lastWorkedOn,
      isCompleted: isCompleted ?? this.isCompleted,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
    );
  }

  /// Update progress with new work session
  ColoringProgress updateProgress({
    required double newCompletionPercent,
    required Duration additionalTime,
    bool? markAsCompleted,
  }) {
    return copyWith(
      completionPercent: newCompletionPercent,
      lastWorkedOn: DateTime.now(),
      isCompleted: markAsCompleted ?? (newCompletionPercent >= 1.0),
      totalTimeSpent: totalTimeSpent + additionalTime,
    );
  }

  /// Mark progress as completed
  ColoringProgress markCompleted() {
    return copyWith(completionPercent: 1.0, isCompleted: true, lastWorkedOn: DateTime.now());
  }

  /// Convert progress to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coloringPageId': coloringPageId,
      'userId': userId,
      'progressImagePath': progressImagePath,
      'canvasDataPath': canvasDataPath,
      'completionPercent': completionPercent,
      'startedAt': startedAt.toIso8601String(),
      'lastWorkedOn': lastWorkedOn.toIso8601String(),
      'isCompleted': isCompleted,
      'totalTimeSpent': totalTimeSpent.inMilliseconds,
    };
  }

  /// Create progress from JSON
  factory ColoringProgress.fromJson(Map<String, dynamic> json) {
    return ColoringProgress(
      id: json['id'] as String,
      coloringPageId: json['coloringPageId'] as String,
      userId: json['userId'] as String,
      progressImagePath: json['progressImagePath'] as String,
      canvasDataPath: json['canvasDataPath'] as String,
      completionPercent: (json['completionPercent'] as num).toDouble(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      lastWorkedOn: DateTime.parse(json['lastWorkedOn'] as String),
      isCompleted: json['isCompleted'] as bool,
      totalTimeSpent: Duration(milliseconds: json['totalTimeSpent'] as int),
    );
  }

  /// Create new progress for a coloring page
  factory ColoringProgress.start({
    required String id,
    required String coloringPageId,
    required String userId,
    required String progressImagePath,
    required String canvasDataPath,
  }) {
    final now = DateTime.now();
    return ColoringProgress(
      id: id,
      coloringPageId: coloringPageId,
      userId: userId,
      progressImagePath: progressImagePath,
      canvasDataPath: canvasDataPath,
      completionPercent: 0.0,
      startedAt: now,
      lastWorkedOn: now,
      isCompleted: false,
      totalTimeSpent: Duration.zero,
    );
  }

  /// Validation rules
  bool get isValid {
    return completionPercent >= 0.0 &&
        completionPercent <= 1.0 &&
        progressImagePath.isNotEmpty &&
        canvasDataPath.isNotEmpty &&
        startedAt.isBefore(lastWorkedOn.add(const Duration(seconds: 1))) &&
        totalTimeSpent.inMilliseconds >= 0;
  }

  /// Get completion percentage as integer (0-100)
  int get completionPercentage => (completionPercent * 100).round();

  /// Get formatted time spent
  String get formattedTimeSpent {
    final hours = totalTimeSpent.inHours;
    final minutes = totalTimeSpent.inMinutes.remainder(60);
    final seconds = totalTimeSpent.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColoringProgress && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ColoringProgress{id: $id, pageId: $coloringPageId, completion: ${completionPercentage}%, isCompleted: $isCompleted}';
  }
}

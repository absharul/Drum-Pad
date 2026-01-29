/// Model representing a saved recording
class Recording {
  final String id;
  final String path;
  final String name;
  final Duration duration;
  final DateTime createdAt;

  Recording({
    required this.id,
    required this.path,
    required this.name,
    required this.duration,
    required this.createdAt,
  });

  /// Create from JSON map
  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(
      id: json['id'] as String,
      path: json['path'] as String,
      name: json['name'] as String,
      duration: Duration(milliseconds: json['durationMs'] as int),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'name': name,
      'durationMs': duration.inMilliseconds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Format duration as mm:ss
  String get formattedDuration {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Format date as readable string
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Create a copy with updated name
  Recording copyWith({String? name}) {
    return Recording(
      id: id,
      path: path,
      name: name ?? this.name,
      duration: duration,
      createdAt: createdAt,
    );
  }
}

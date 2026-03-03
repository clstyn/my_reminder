/// Reminder Model - Represents a daily reminder
/// Like defining the shape of reminder data in your app
class ReminderModel {
  final int? id;
  final int userId;
  final String title;
  final String? description;
  final DateTime time; // Time of day to remind
  final bool isActive;
  final DateTime createdAt;

  ReminderModel({
    this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.time,
    this.isActive = true,
    required this.createdAt,
  });

  /// Creates Reminder from database row
  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      time: DateTime.parse(map['time'] as String),
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Converts Reminder to database format
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'time': time.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with modifications (like spread operator in JS)
  ReminderModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    DateTime? time,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ReminderModel(id: $id, userId: $userId, title: $title, time: $time)';
  }
}

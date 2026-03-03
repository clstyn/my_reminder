/// Completion Model - Tracks whether a reminder was completed on a specific day
/// Like tracking checkboxes for each day
class CompletionModel {
  final int? id;
  final int reminderId;
  final DateTime date; // Which day (date only, no time)
  final bool completed;

  CompletionModel({
    this.id,
    required this.reminderId,
    required this.date,
    required this.completed,
  });

  /// Creates Completion from database row
  factory CompletionModel.fromMap(Map<String, dynamic> map) {
    return CompletionModel(
      id: map['id'] as int?,
      reminderId: map['reminder_id'] as int,
      date: DateTime.parse(map['completion_date'] as String),
      completed: (map['completed'] as int) == 1,
    );
  }

  /// Converts Completion to database format
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'reminder_id': reminderId,
      'completion_date': _dateOnly(date),
      'completed': completed ? 1 : 0,
    };
  }

  /// Helper to get date without time (like "2026-03-02")
  /// Similar to date.toISOString().split('T')[0] in JS
  String _dateOnly(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Copy with modifications
  CompletionModel copyWith({
    int? id,
    int? reminderId,
    DateTime? date,
    bool? completed,
  }) {
    return CompletionModel(
      id: id ?? this.id,
      reminderId: reminderId ?? this.reminderId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
    );
  }

  @override
  String toString() {
    return 'CompletionModel(id: $id, reminderId: $reminderId, date: ${_dateOnly(date)}, completed: $completed)';
  }
}

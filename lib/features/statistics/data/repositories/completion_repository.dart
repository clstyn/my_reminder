import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/database_constants.dart';
import '../models/completion_model.dart';

/// CompletionRepository - Tracks daily completion of reminders
/// Like tracking checkbox state for each day in your calendar
class CompletionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get completion status for a reminder on a specific date
  /// Like: fetch(`/api/reminders/${id}/completions?date=2026-03-02`)
  Future<CompletionModel?> getCompletion(int reminderId, DateTime date) async {
    final dateStr = _dateOnly(date);
    final maps = await _dbHelper.query(
      DatabaseConstants.completionsTable,
      where:
          '${DatabaseConstants.completionReminderId} = ? AND ${DatabaseConstants.completionDate} = ?',
      whereArgs: [reminderId, dateStr],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return CompletionModel.fromMap(maps.first);
  }

  /// Get all completions for a reminder
  /// Like: fetch(`/api/reminders/${id}/completions`)
  Future<List<CompletionModel>> getCompletionsByReminderId(
    int reminderId,
  ) async {
    final maps = await _dbHelper.query(
      DatabaseConstants.completionsTable,
      where: '${DatabaseConstants.completionReminderId} = ?',
      whereArgs: [reminderId],
      orderBy: '${DatabaseConstants.completionDate} DESC',
    );
    return maps.map((map) => CompletionModel.fromMap(map)).toList();
  }

  /// Get completions for a date range (for calendar view)
  /// Like: fetch(`/api/completions?from=2026-03-01&to=2026-03-31`)
  Future<List<CompletionModel>> getCompletionsByDateRange(
    int reminderId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final maps = await _dbHelper.query(
      DatabaseConstants.completionsTable,
      where:
          '${DatabaseConstants.completionReminderId} = ? '
          'AND ${DatabaseConstants.completionDate} >= ? '
          'AND ${DatabaseConstants.completionDate} <= ?',
      whereArgs: [reminderId, _dateOnly(startDate), _dateOnly(endDate)],
      orderBy: '${DatabaseConstants.completionDate} ASC',
    );
    return maps.map((map) => CompletionModel.fromMap(map)).toList();
  }

  /// Mark a reminder as completed for a specific date
  /// Like: setCompleted(reminderId, date, true) → checks the box
  Future<CompletionModel> markCompletion(
    int reminderId,
    DateTime date,
    bool completed,
  ) async {
    // Check if completion already exists
    final existing = await getCompletion(reminderId, date);

    if (existing != null) {
      // Update existing completion
      await _dbHelper.update(
        DatabaseConstants.completionsTable,
        {DatabaseConstants.completionCompleted: completed ? 1 : 0},
        where: '${DatabaseConstants.completionId} = ?',
        whereArgs: [existing.id],
      );
      return existing.copyWith(completed: completed);
    } else {
      // Create new completion
      final completion = CompletionModel(
        reminderId: reminderId,
        date: date,
        completed: completed,
      );
      final id = await _dbHelper.insert(
        DatabaseConstants.completionsTable,
        completion.toMap(),
      );
      return completion.copyWith(id: id);
    }
  }

  /// Toggle completion status (check/uncheck)
  /// Like: toggleCheckbox(reminderId, date)
  Future<CompletionModel> toggleCompletion(
    int reminderId,
    DateTime date,
  ) async {
    final existing = await getCompletion(reminderId, date);
    final newStatus = existing?.completed == true ? false : true;
    return await markCompletion(reminderId, date, newStatus);
  }

  /// Get completion percentage for a reminder (for charts)
  /// Like: getCompletionRate(reminderId, days) → returns 75.5
  Future<double> getCompletionPercentage(int reminderId, int days) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days - 1));

    final completions = await getCompletionsByDateRange(
      reminderId,
      startDate,
      endDate,
    );

    if (completions.isEmpty) return 0.0;

    final completedCount = completions.where((c) => c.completed).length;
    return (completedCount / days) * 100;
  }

  /// Get completion streak (consecutive days completed)
  /// Like: getCurrentStreak(reminderId) → returns 5 (5 days in a row!)
  Future<int> getCurrentStreak(int reminderId) async {
    final completions = await getCompletionsByReminderId(reminderId);

    if (completions.isEmpty) return 0;

    int streak = 0;
    final today = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final completion = completions.firstWhere(
        (c) => _isSameDate(c.date, checkDate),
        orElse: () => CompletionModel(
          reminderId: reminderId,
          date: checkDate,
          completed: false,
        ),
      );

      if (completion.completed) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get total completed count for a reminder
  /// Like: getTotalCompleted(reminderId) → returns 42
  Future<int> getTotalCompletedCount(int reminderId) async {
    final result = await _dbHelper.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.completionsTable} '
      'WHERE ${DatabaseConstants.completionReminderId} = ? '
      'AND ${DatabaseConstants.completionCompleted} = ?',
      [reminderId, 1],
    );
    return result.first['count'] as int;
  }

  /// Delete all completions for a reminder
  /// Happens automatically via CASCADE when reminder is deleted
  /// But useful if you want to reset history
  Future<int> deleteCompletionsByReminderId(int reminderId) async {
    return await _dbHelper.delete(
      DatabaseConstants.completionsTable,
      where: '${DatabaseConstants.completionReminderId} = ?',
      whereArgs: [reminderId],
    );
  }

  // Helper methods

  /// Get date-only string (no time)
  String _dateOnly(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Check if two dates are the same day
  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

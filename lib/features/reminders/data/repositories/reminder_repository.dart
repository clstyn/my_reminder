import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/database_constants.dart';
import '../models/reminder_model.dart';

/// ReminderRepository - Handles all reminder data operations
/// Like your useReminders() hook or reminderService in React
class ReminderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get all reminders for a user
  /// Like: fetch(`/api/users/${userId}/reminders`)
  Future<List<ReminderModel>> getRemindersByUserId(int userId) async {
    final maps = await _dbHelper.query(
      DatabaseConstants.remindersTable,
      where: '${DatabaseConstants.reminderUserId} = ?',
      whereArgs: [userId],
      orderBy: '${DatabaseConstants.reminderTime} ASC',
    );
    return maps.map((map) => ReminderModel.fromMap(map)).toList();
  }

  /// Get only active reminders for a user
  /// Like: fetch(`/api/users/${userId}/reminders?active=true`)
  Future<List<ReminderModel>> getActiveRemindersByUserId(int userId) async {
    final maps = await _dbHelper.query(
      DatabaseConstants.remindersTable,
      where:
          '${DatabaseConstants.reminderUserId} = ? AND ${DatabaseConstants.reminderIsActive} = ?',
      whereArgs: [userId, 1],
      orderBy: '${DatabaseConstants.reminderTime} ASC',
    );
    return maps.map((map) => ReminderModel.fromMap(map)).toList();
  }

  /// Get a single reminder by ID
  /// Like: fetch(`/api/reminders/${id}`)
  Future<ReminderModel?> getReminderById(int id) async {
    final maps = await _dbHelper.query(
      DatabaseConstants.remindersTable,
      where: '${DatabaseConstants.reminderId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return ReminderModel.fromMap(maps.first);
  }

  /// Create a new reminder
  /// Like: fetch('/api/reminders', { method: 'POST', body: reminderData })
  Future<ReminderModel> createReminder(ReminderModel reminder) async {
    final id = await _dbHelper.insert(
      DatabaseConstants.remindersTable,
      reminder.toMap(),
    );
    return reminder.copyWith(id: id);
  }

  /// Update an existing reminder
  /// Like: fetch(`/api/reminders/${id}`, { method: 'PUT', body: reminderData })
  Future<int> updateReminder(ReminderModel reminder) async {
    return await _dbHelper.update(
      DatabaseConstants.remindersTable,
      reminder.toMap(),
      where: '${DatabaseConstants.reminderId} = ?',
      whereArgs: [reminder.id],
    );
  }

  /// Delete a reminder
  /// Like: fetch(`/api/reminders/${id}`, { method: 'DELETE' })
  Future<int> deleteReminder(int id) async {
    return await _dbHelper.delete(
      DatabaseConstants.remindersTable,
      where: '${DatabaseConstants.reminderId} = ?',
      whereArgs: [id],
    );
  }

  /// Toggle reminder active status (soft delete)
  /// Like: toggleReminder(id) → switches on/off
  Future<int> toggleReminderStatus(int id, bool isActive) async {
    return await _dbHelper.update(
      DatabaseConstants.remindersTable,
      {DatabaseConstants.reminderIsActive: isActive ? 1 : 0},
      where: '${DatabaseConstants.reminderId} = ?',
      whereArgs: [id],
    );
  }

  /// Get reminders that should notify at a specific time
  /// Useful for scheduling notifications
  /// Like: fetch('/api/reminders?time=09:00')
  Future<List<ReminderModel>> getRemindersByTime(DateTime time) async {
    final maps = await _dbHelper.query(
      DatabaseConstants.remindersTable,
      where:
          '${DatabaseConstants.reminderTime} = ? AND ${DatabaseConstants.reminderIsActive} = ?',
      whereArgs: [time.toIso8601String(), 1],
    );
    return maps.map((map) => ReminderModel.fromMap(map)).toList();
  }

  /// Get count of active reminders for a user
  /// Like: fetch(`/api/users/${userId}/reminders/count`)
  Future<int> getActiveReminderCount(int userId) async {
    final result = await _dbHelper.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.remindersTable} '
      'WHERE ${DatabaseConstants.reminderUserId} = ? '
      'AND ${DatabaseConstants.reminderIsActive} = ?',
      [userId, 1],
    );
    return result.first['count'] as int;
  }
}

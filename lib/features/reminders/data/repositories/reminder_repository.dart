import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/services/notification_service.dart';
import '../models/reminder_model.dart';

/// ReminderRepository - Handles all reminder data operations
/// Like your useReminders() hook or reminderService in React
class ReminderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final NotificationService _notificationService = NotificationService();

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
    final createdReminder = reminder.copyWith(id: id);

    // Schedule notification for the newly created reminder
    if (createdReminder.isActive && createdReminder.id != null) {
      await _notificationService.scheduleDailyReminderNotification(
        id: createdReminder.id!,
        title: createdReminder.title,
        description: createdReminder.description,
        reminderTime: createdReminder.time,
      );
    }

    return createdReminder;
  }

  /// Update an existing reminder
  /// Like: fetch(`/api/reminders/${id}`, { method: 'PUT', body: reminderData })
  Future<int> updateReminder(ReminderModel reminder) async {
    final result = await _dbHelper.update(
      DatabaseConstants.remindersTable,
      reminder.toMap(),
      where: '${DatabaseConstants.reminderId} = ?',
      whereArgs: [reminder.id],
    );

    // Reschedule notification if reminder is active
    if (reminder.id != null) {
      // Cancel existing notification
      await _notificationService.cancelNotification(reminder.id!);

      // Schedule new notification with updated time
      if (reminder.isActive) {
        await _notificationService.scheduleDailyReminderNotification(
          id: reminder.id!,
          title: reminder.title,
          description: reminder.description,
          reminderTime: reminder.time,
        );
      }
    }

    return result;
  }

  /// Delete a reminder
  /// Like: fetch(`/api/reminders/${id}`, { method: 'DELETE' })
  Future<int> deleteReminder(int id) async {
    // Cancel associated notification
    await _notificationService.cancelNotification(id);

    return await _dbHelper.delete(
      DatabaseConstants.remindersTable,
      where: '${DatabaseConstants.reminderId} = ?',
      whereArgs: [id],
    );
  }

  /// Toggle reminder active status (soft delete)
  /// Like: toggleReminder(id) → switches on/off
  Future<int> toggleReminderStatus(int id, bool isActive) async {
    final result = await _dbHelper.update(
      DatabaseConstants.remindersTable,
      {DatabaseConstants.reminderIsActive: isActive ? 1 : 0},
      where: '${DatabaseConstants.reminderId} = ?',
      whereArgs: [id],
    );

    // Handle notification scheduling based on active status
    if (isActive) {
      // Reminder is being activated - schedule notification
      final reminder = await getReminderById(id);
      if (reminder != null) {
        await _notificationService.scheduleDailyReminderNotification(
          id: reminder.id!,
          title: reminder.title,
          description: reminder.description,
          reminderTime: reminder.time,
        );
      }
    } else {
      // Reminder is being deactivated - cancel notification
      await _notificationService.cancelNotification(id);
    }

    return result;
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

  /// Reschedule all active reminders
  /// Call this on app startup to ensure notifications are scheduled
  /// This is useful after app updates or when reminders might have been cleared
  Future<void> rescheduleAllReminders() async {
    // Cancel all existing notifications first
    await _notificationService.cancelAll();

    // Get all active reminders
    final maps = await _dbHelper.query(
      DatabaseConstants.remindersTable,
      where: '${DatabaseConstants.reminderIsActive} = ?',
      whereArgs: [1],
    );

    final reminders = maps.map((map) => ReminderModel.fromMap(map)).toList();

    // Schedule notifications for each active reminder
    for (final reminder in reminders) {
      if (reminder.id != null) {
        await _notificationService.scheduleDailyReminderNotification(
          id: reminder.id!,
          title: reminder.title,
          description: reminder.description,
          reminderTime: reminder.time,
        );
      }
    }
  }
}

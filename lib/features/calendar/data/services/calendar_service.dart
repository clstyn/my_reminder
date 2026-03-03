import '../../../reminders/data/repositories/reminder_repository.dart';
import '../../../statistics/data/repositories/completion_repository.dart';
import '../../../reminders/data/models/reminder_model.dart';
import '../../../statistics/data/models/completion_model.dart';

/// Daily Completion Stats
class DailyCompletionStats {
  final DateTime date;
  final int totalReminders;
  final int completedReminders;
  final double completionPercentage;
  final List<ReminderWithCompletion> reminders;

  DailyCompletionStats({
    required this.date,
    required this.totalReminders,
    required this.completedReminders,
    required this.completionPercentage,
    required this.reminders,
  });

  bool get isEmpty => totalReminders == 0;
}

/// Reminder with its completion status
class ReminderWithCompletion {
  final ReminderModel reminder;
  final bool isCompleted;

  ReminderWithCompletion({required this.reminder, required this.isCompleted});
}

/// Calendar Service - Handles calendar-specific data operations
class CalendarService {
  final ReminderRepository _reminderRepository = ReminderRepository();
  final CompletionRepository _completionRepository = CompletionRepository();

  /// Get completion stats for a specific day
  Future<DailyCompletionStats> getDailyStats(int userId, DateTime date) async {
    // Get all active reminders for the user
    final reminders = await _reminderRepository.getActiveRemindersByUserId(
      userId,
    );

    if (reminders.isEmpty) {
      return DailyCompletionStats(
        date: date,
        totalReminders: 0,
        completedReminders: 0,
        completionPercentage: 0,
        reminders: [],
      );
    }

    // Get completion status for each reminder on this date
    final remindersWithCompletion = <ReminderWithCompletion>[];
    int completedCount = 0;

    for (final reminder in reminders) {
      final completion = await _completionRepository.getCompletion(
        reminder.id!,
        date,
      );
      final isCompleted = completion?.completed ?? false;

      if (isCompleted) completedCount++;

      remindersWithCompletion.add(
        ReminderWithCompletion(reminder: reminder, isCompleted: isCompleted),
      );
    }

    final percentage = (completedCount / reminders.length) * 100;

    return DailyCompletionStats(
      date: date,
      totalReminders: reminders.length,
      completedReminders: completedCount,
      completionPercentage: percentage,
      reminders: remindersWithCompletion,
    );
  }

  /// Get completion stats for a month (all days)
  Future<Map<DateTime, DailyCompletionStats>> getMonthlyStats(
    int userId,
    DateTime month,
  ) async {
    final daysInMonth = _getDaysInMonth(month);
    final stats = <DateTime, DailyCompletionStats>{};

    // Get all active reminders once
    final reminders = await _reminderRepository.getActiveRemindersByUserId(
      userId,
    );

    if (reminders.isEmpty) {
      return stats;
    }

    // Get completions for the entire month for all reminders
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month, daysInMonth);

    // Fetch all completions for the month for each reminder
    final allCompletions = <int, List<CompletionModel>>{};
    for (final reminder in reminders) {
      final completions = await _completionRepository.getCompletionsByDateRange(
        reminder.id!,
        startDate,
        endDate,
      );
      allCompletions[reminder.id!] = completions;
    }

    // Calculate stats for each day
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final remindersWithCompletion = <ReminderWithCompletion>[];
      int completedCount = 0;

      for (final reminder in reminders) {
        final completions = allCompletions[reminder.id!] ?? [];
        final completion = completions.firstWhere(
          (c) => _isSameDay(c.date, date),
          orElse: () => CompletionModel(
            reminderId: reminder.id!,
            date: date,
            completed: false,
          ),
        );

        final isCompleted = completion.completed;
        if (isCompleted) completedCount++;

        remindersWithCompletion.add(
          ReminderWithCompletion(reminder: reminder, isCompleted: isCompleted),
        );
      }

      final percentage = (completedCount / reminders.length) * 100;

      stats[date] = DailyCompletionStats(
        date: date,
        totalReminders: reminders.length,
        completedReminders: completedCount,
        completionPercentage: percentage,
        reminders: remindersWithCompletion,
      );
    }

    return stats;
  }

  /// Get number of days in a month
  int _getDaysInMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    final lastDayOfMonth = nextMonth.subtract(const Duration(days: 1));
    return lastDayOfMonth.day;
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class DatabaseConstants {
  static const String databaseName = 'my_reminder.db';
  static const int databaseVersion = 1;

  // Tables
  static const String usersTable = 'users';
  static const String remindersTable = 'reminders';
  static const String completionsTable = 'completions';

  // Users table columns
  static const String userId = 'id';
  static const String userName = 'name';
  static const String userPassword = 'password';
  static const String userEmail = 'email';
  static const String userCreatedAt = 'created_at';
  static const String userIsActive = 'is_active';

  // Reminders table columns
  static const String reminderId = 'id';
  static const String reminderUserId = 'user_id';
  static const String reminderTitle = 'title';
  static const String reminderDescription = 'description';
  static const String reminderTime = 'time';
  static const String reminderIsActive = 'is_active';
  static const String reminderCreatedAt = 'created_at';

  // Completions table columns
  static const String completionId = 'id';
  static const String completionReminderId = 'reminder_id';
  static const String completionDate = 'completion_date';
  static const String completionCompleted = 'completed';
}

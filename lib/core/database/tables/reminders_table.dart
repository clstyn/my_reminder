import '../../constants/database_constants.dart';

class RemindersTable {
  static const String createTable =
      '''
    CREATE TABLE ${DatabaseConstants.remindersTable} (
      ${DatabaseConstants.reminderId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstants.reminderUserId} INTEGER NOT NULL,
      ${DatabaseConstants.reminderTitle} TEXT NOT NULL,
      ${DatabaseConstants.reminderDescription} TEXT,
      ${DatabaseConstants.reminderTime} TEXT NOT NULL,
      ${DatabaseConstants.reminderIsActive} INTEGER NOT NULL DEFAULT 1,
      ${DatabaseConstants.reminderCreatedAt} TEXT NOT NULL,
      FOREIGN KEY (${DatabaseConstants.reminderUserId}) 
        REFERENCES ${DatabaseConstants.usersTable}(${DatabaseConstants.userId})
        ON DELETE CASCADE
    )
  ''';
}

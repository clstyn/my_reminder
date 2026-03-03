import '../../constants/database_constants.dart';

class CompletionsTable {
  static const String createTable =
      '''
    CREATE TABLE ${DatabaseConstants.completionsTable} (
      ${DatabaseConstants.completionId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstants.completionReminderId} INTEGER NOT NULL,
      ${DatabaseConstants.completionDate} TEXT NOT NULL,
      ${DatabaseConstants.completionCompleted} INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (${DatabaseConstants.completionReminderId}) 
        REFERENCES ${DatabaseConstants.remindersTable}(${DatabaseConstants.reminderId})
        ON DELETE CASCADE,
      UNIQUE(${DatabaseConstants.completionReminderId}, ${DatabaseConstants.completionDate})
    )
  ''';
}

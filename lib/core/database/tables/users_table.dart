import '../../constants/database_constants.dart';

class UsersTable {
  static const String createTable =
      '''
    CREATE TABLE ${DatabaseConstants.usersTable} (
      ${DatabaseConstants.userId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConstants.userName} TEXT NOT NULL UNIQUE,
      ${DatabaseConstants.userPassword} TEXT NOT NULL,
      ${DatabaseConstants.userEmail} TEXT,
      ${DatabaseConstants.userCreatedAt} TEXT NOT NULL,
      ${DatabaseConstants.userIsActive} INTEGER NOT NULL DEFAULT 1
    )
  ''';
}

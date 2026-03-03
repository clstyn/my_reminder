import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/database_constants.dart';
import 'tables/users_table.dart';
import 'tables/reminders_table.dart';
import 'tables/completions_table.dart';

/// DatabaseHelper is a singleton class that manages SQLite database operations
/// It handles database creation, migrations, and provides access to the database instance
class DatabaseHelper {
  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  /// Gets the database instance, creates it if it doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database
  Future<Database> _initDatabase() async {
    // Get the default database path
    String path = join(
      await getDatabasesPath(),
      DatabaseConstants.databaseName,
    );

    // Open the database, creating it if it doesn't exist
    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Called when the database needs to be configured (before onCreate/onUpgrade)
  /// Enables foreign key constraints
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Called when the database is created for the first time
  Future<void> _onCreate(Database db, int version) async {
    // Create all tables
    await db.execute(UsersTable.createTable);
    await db.execute(RemindersTable.createTable);
    await db.execute(CompletionsTable.createTable);

    // No default user - users must register/login
  }

  /// Called when the database needs to be upgraded
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE ...');
    // }
  }

  /// Closes the database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Deletes the database (useful for testing or reset)
  Future<void> deleteDatabase() async {
    String path = join(
      await getDatabasesPath(),
      DatabaseConstants.databaseName,
    );
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // Helper methods for common database operations

  /// Generic insert method
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row);
  }

  /// Generic query method
  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  /// Generic update method
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  /// Generic delete method
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Execute raw SQL query
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Execute raw SQL command
  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawInsert(sql, arguments);
  }
}

import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../models/user_model.dart';

/// UserRepository - Handles all user data operations
/// Think of this like a custom hook or API service in React:
/// - getAllUsers() → like useUsers() or fetch('/api/users')
/// - createUser() → like createUser(data) API call
///
/// The UI doesn't know about database, just calls these methods
class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get all users
  /// Like: const users = await fetch('/api/users').then(r => r.json())
  Future<List<UserModel>> getAllUsers() async {
    final maps = await _dbHelper.query(
      DatabaseConstants.usersTable,
      orderBy: '${DatabaseConstants.userCreatedAt} DESC',
    );
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  /// Get active users only
  /// Like: fetch('/api/users?active=true')
  Future<List<UserModel>> getActiveUsers() async {
    final maps = await _dbHelper.query(
      DatabaseConstants.usersTable,
      where: '${DatabaseConstants.userIsActive} = ?',
      whereArgs: [1],
      orderBy: '${DatabaseConstants.userCreatedAt} DESC',
    );
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  /// Get user by ID
  /// Like: fetch('/api/users/1')
  Future<UserModel?> getUserById(int id) async {
    final maps = await _dbHelper.query(
      DatabaseConstants.usersTable,
      where: '${DatabaseConstants.userId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  /// Get the currently active user (for account switching)
  /// Like: fetch('/api/users/current')
  Future<UserModel?> getCurrentUser() async {
    final maps = await _dbHelper.query(
      DatabaseConstants.usersTable,
      where: '${DatabaseConstants.userIsActive} = ?',
      whereArgs: [1],
      orderBy: '${DatabaseConstants.userCreatedAt} DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  /// Create a new user
  /// Like: fetch('/api/users', { method: 'POST', body: userData })
  Future<UserModel> createUser(UserModel user) async {
    final id = await _dbHelper.insert(
      DatabaseConstants.usersTable,
      user.toMap(),
    );
    return user.copyWith(id: id);
  }

  /// Update existing user
  /// Like: fetch('/api/users/1', { method: 'PUT', body: userData })
  Future<int> updateUser(UserModel user) async {
    return await _dbHelper.update(
      DatabaseConstants.usersTable,
      user.toMap(),
      where: '${DatabaseConstants.userId} = ?',
      whereArgs: [user.id],
    );
  }

  /// Delete a user (and all their reminders via CASCADE)
  /// Like: fetch('/api/users/1', { method: 'DELETE' })
  Future<int> deleteUser(int id) async {
    return await _dbHelper.delete(
      DatabaseConstants.usersTable,
      where: '${DatabaseConstants.userId} = ?',
      whereArgs: [id],
    );
  }

  /// Switch to a different user (set all others inactive)
  /// Like: setCurrentUser(userId) in your context/state
  Future<void> switchToUser(int userId) async {
    final db = await _dbHelper.database;

    // Use transaction to ensure both updates succeed or both fail
    await db.transaction((txn) async {
      // Set all users to inactive
      await txn.update(DatabaseConstants.usersTable, {
        DatabaseConstants.userIsActive: 0,
      });

      // Set selected user to active
      await txn.update(
        DatabaseConstants.usersTable,
        {DatabaseConstants.userIsActive: 1},
        where: '${DatabaseConstants.userId} = ?',
        whereArgs: [userId],
      );
    });
  }

  /// Check if a user exists by email
  /// Like: checkEmailExists(email) → returns boolean
  Future<bool> userExistsByEmail(String email) async {
    final maps = await _dbHelper.query(
      DatabaseConstants.usersTable,
      where: '${DatabaseConstants.userEmail} = ?',
      whereArgs: [email],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  // ==================== AUTHENTICATION METHODS ====================

  /// Check if username exists
  /// Like: checkUsernameAvailable(username) → returns boolean
  Future<bool> usernameExists(String username) async {
    final maps = await _dbHelper.query(
      DatabaseConstants.usersTable,
      where: '${DatabaseConstants.userName} = ?',
      whereArgs: [username],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  /// Register a new user
  /// Like: registerUser({ username, password, email })
  /// Returns the created user or null if username already exists
  Future<UserModel?> register({
    required String username,
    required String password,
    String? email,
  }) async {
    // Check if username already exists
    if (await usernameExists(username)) {
      return null; // Username taken
    }

    // Hash the password
    final hashedPassword = AuthService.hashPassword(password);

    // Create user
    final user = UserModel(
      name: username,
      password: hashedPassword,
      email: email,
      createdAt: DateTime.now(),
      isActive: true,
    );

    final id = await _dbHelper.insert(
      DatabaseConstants.usersTable,
      user.toMap(),
    );

    return user.copyWith(id: id);
  }

  /// Login user
  /// Like: loginUser({ username, password })
  /// Returns user if credentials valid, null otherwise
  Future<UserModel?> login({
    required String username,
    required String password,
  }) async {
    final maps = await _dbHelper.query(
      DatabaseConstants.usersTable,
      where: '${DatabaseConstants.userName} = ?',
      whereArgs: [username],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null; // User not found
    }

    final user = UserModel.fromMap(maps.first);

    // Verify password
    if (!AuthService.verifyPassword(password, user.password)) {
      return null; // Wrong password
    }

    // Set this user as active
    await switchToUser(user.id!);

    return user;
  }

  /// Get user by username
  /// Like: fetch('/api/users?username=john')
  Future<UserModel?> getUserByUsername(String username) async {
    final maps = await _dbHelper.query(
      DatabaseConstants.usersTable,
      where: '${DatabaseConstants.userName} = ?',
      whereArgs: [username],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }
}

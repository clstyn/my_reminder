import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// AuthService - Manages user session and password hashing
/// Like: localStorage in React + password utilities
///
/// No tokens needed! Just tracks "who is logged in" locally
class AuthService {
  // SharedPreferences keys
  static const String _keyCurrentUserId = 'current_user_id';
  static const String _keyIsLoggedIn = 'is_logged_in';

  /// Hash password using SHA256
  /// Like: bcrypt.hash(password) in Node.js
  /// For a personal app, SHA256 is sufficient
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Verify password against hash
  /// Like: bcrypt.compare(password, hash)
  static bool verifyPassword(String password, String hashedPassword) {
    return hashPassword(password) == hashedPassword;
  }

  /// Save logged-in user to local storage
  /// Like: localStorage.setItem('userId', id) in React
  Future<void> saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentUserId, userId);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  /// Get current logged-in user ID
  /// Like: localStorage.getItem('userId')
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentUserId);
  }

  /// Check if user is logged in
  /// Like: const isLoggedIn = !!localStorage.getItem('userId')
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Logout user
  /// Like: localStorage.clear() or logout function
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUserId);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  /// Clear all session data (for testing/debugging)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

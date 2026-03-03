import '../database/database_helper.dart';
import '../constants/database_constants.dart';
import '../../features/reminders/data/repositories/reminder_repository.dart';
import '../../features/statistics/data/repositories/completion_repository.dart';
import '../../features/reminders/data/models/reminder_model.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Seed Data Helper - Populates database with dummy data for testing
class SeedDataHelper {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ReminderRepository _reminderRepository = ReminderRepository();
  final CompletionRepository _completionRepository = CompletionRepository();

  /// Seed the database with dummy data
  /// Call this after a user registers/logs in for testing purposes
  Future<void> seedData(int userId) async {
    // Check if user already has reminders (don't seed twice)
    final existingReminders = await _reminderRepository.getRemindersByUserId(
      userId,
    );
    if (existingReminders.isNotEmpty) {
      print('User already has reminders, skipping seed data');
      return;
    }

    print('Seeding database with dummy data for user $userId...');

    // Create some sample reminders
    final reminders = await _createSampleReminders(userId);

    // Create completion history for the past 14 days
    await _createCompletionHistory(reminders);

    print('Seed data created successfully!');
  }

  /// Create sample reminders
  Future<List<ReminderModel>> _createSampleReminders(int userId) async {
    final now = DateTime.now();

    final reminderData = [
      {
        'title': 'Morning Exercise',
        'description': '30 minutes of workout',
        'time': DateTime(now.year, now.month, now.day, 6, 0),
      },
      {
        'title': 'Drink Water',
        'description': '8 glasses throughout the day',
        'time': DateTime(now.year, now.month, now.day, 8, 0),
      },
      {
        'title': 'Read Book',
        'description': 'Read for 20 minutes',
        'time': DateTime(now.year, now.month, now.day, 20, 0),
      },
      {
        'title': 'Meditation',
        'description': '10 minutes mindfulness',
        'time': DateTime(now.year, now.month, now.day, 7, 0),
      },
      {
        'title': 'Plan Tomorrow',
        'description': 'Review and plan next day',
        'time': DateTime(now.year, now.month, now.day, 21, 0),
      },
    ];

    final reminders = <ReminderModel>[];
    for (final data in reminderData) {
      final reminder = ReminderModel(
        userId: userId,
        title: data['title'] as String,
        description: data['description'] as String,
        time: data['time'] as DateTime,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 15)),
      );
      final created = await _reminderRepository.createReminder(reminder);
      reminders.add(created);
    }

    return reminders;
  }

  /// Create completion history for past days with varying completion rates
  Future<void> _createCompletionHistory(List<ReminderModel> reminders) async {
    final today = DateTime.now();

    // Create completions for the past 14 days
    for (int daysAgo = 1; daysAgo <= 14; daysAgo++) {
      final date = DateTime(today.year, today.month, today.day - daysAgo);

      // Vary completion rates to show different colored dots
      double completionRate;
      if (daysAgo <= 3) {
        completionRate = 1.0; // 100% - last 3 days perfect
      } else if (daysAgo <= 6) {
        completionRate = 0.9; // 80-99% - yellow
      } else if (daysAgo <= 10) {
        completionRate = 0.65; // 50-80% - orange
      } else {
        completionRate = 0.4; // Below 50% - red
      }

      // Mark reminders as completed based on completion rate
      for (int i = 0; i < reminders.length; i++) {
        final shouldComplete = (i / reminders.length) < completionRate;
        await _completionRepository.markCompletion(
          reminders[i].id!,
          date,
          shouldComplete,
        );
      }
    }
  }

  /// Seed a test user if needed (for development/testing)
  Future<int?> seedTestUser() async {
    final db = await _dbHelper.database;

    // Check if test user exists
    final existing = await db.query(
      DatabaseConstants.usersTable,
      where: '${DatabaseConstants.userName} = ?',
      whereArgs: ['testuser'],
    );

    if (existing.isNotEmpty) {
      print('Test user already exists');
      return existing.first[DatabaseConstants.userId] as int;
    }

    // Create test user: username=testuser, password=password123
    final hashedPassword = sha256
        .convert(utf8.encode('password123'))
        .toString();

    final userId = await db.insert(DatabaseConstants.usersTable, {
      DatabaseConstants.userName: 'testuser',
      DatabaseConstants.userEmail: 'test@example.com',
      DatabaseConstants.userPassword: hashedPassword,
      DatabaseConstants.userCreatedAt: DateTime.now().toIso8601String(),
    });

    print('Test user created with ID: $userId');
    return userId;
  }

  /// Seed test user with all data
  Future<void> seedTestUserWithData() async {
    final userId = await seedTestUser();
    if (userId != null) {
      await seedData(userId);
    }
  }
}

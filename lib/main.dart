import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'core/seed/seed_data_helper.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Seed test user data for development
  // Comment this out in production
  await _seedTestData();

  await NotificationService().init();

  runApp(const MyApp());
}

/// Seed test data for development purposes
Future<void> _seedTestData() async {
  try {
    final seedHelper = SeedDataHelper();
    await seedHelper.seedTestUserWithData();
  } catch (e) {
    print('Error seeding test data: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Reminder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

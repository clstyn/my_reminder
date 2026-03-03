import 'package:flutter/material.dart';
import '../widgets/month_year_picker_widget.dart';
import '../widgets/calendar_grid_widget.dart';
import '../widgets/day_detail_box_widget.dart';
import '../../data/services/calendar_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/presentation/screens/login_screen.dart';

/// Calendar Screen - Displays calendar view of reminders
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay;

  final _calendarService = CalendarService();
  final _authService = AuthService();

  int? _currentUserId;
  bool _isLoading = true;
  Map<DateTime, double> _completionPercentages = {};
  DailyCompletionStats? _selectedDayStats;

  @override
  void initState() {
    super.initState();
    _loadUserAndData();
  }

  /// Load current user and calendar data
  Future<void> _loadUserAndData() async {
    setState(() => _isLoading = true);

    try {
      // Get current user ID from session
      final userId = await _authService.getCurrentUserId();

      if (userId == null) {
        // Not logged in, redirect to login
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }

      _currentUserId = userId;

      // Load monthly stats
      await _loadMonthlyStats();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading calendar: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Load completion stats for the current month
  Future<void> _loadMonthlyStats() async {
    if (_currentUserId == null) return;

    final stats = await _calendarService.getMonthlyStats(
      _currentUserId!,
      _selectedMonth,
    );

    if (mounted) {
      setState(() {
        _completionPercentages = stats.map(
          (date, stat) => MapEntry(date, stat.completionPercentage),
        );
      });
    }
  }

  /// Load detailed stats for a specific day
  Future<void> _loadDayStats(DateTime date) async {
    if (_currentUserId == null) return;

    final stats = await _calendarService.getDailyStats(_currentUserId!, date);

    if (mounted) {
      setState(() {
        _selectedDayStats = stats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Month-Year Picker
                MonthYearPicker(
                  selectedDate: _selectedMonth,
                  onDateChanged: (newDate) {
                    setState(() {
                      _selectedMonth = newDate;
                      _selectedDay = null;
                      _selectedDayStats = null;
                    });
                    _loadMonthlyStats();
                  },
                ),

                const Divider(height: 1),

                // Calendar Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CalendarGrid(
                      selectedDate: _selectedMonth,
                      selectedDay: _selectedDay,
                      completionPercentages: _completionPercentages,
                      onDaySelected: (date) {
                        setState(() {
                          _selectedDay = date;
                        });
                        _loadDayStats(date);
                      },
                    ),
                  ),
                ),

                // Day detail box
                if (_selectedDayStats != null)
                  DayDetailBox(stats: _selectedDayStats!),
              ],
            ),
    );
  }
}

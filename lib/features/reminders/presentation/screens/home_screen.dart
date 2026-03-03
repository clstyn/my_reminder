import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/models/reminder_model.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../../statistics/data/repositories/completion_repository.dart';
import '../../../statistics/data/presentation/widget/completion_percentage_bar.dart';
import 'widgets/reminder_list_item.dart';
import 'widgets/add_edit_reminder_modal.dart';
import '../../../auth/presentation/screens/login_screen.dart';

/// Home Screen - Displays user's reminders
/// Like your main dashboard in React apps
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _reminderRepository = ReminderRepository();
  final _completionRepository = CompletionRepository();
  final _authService = AuthService();

  List<ReminderModel> _reminders = [];
  bool _isLoading = true;
  int? _currentUserId;
  int _completedToday = 0;
  int _totalReminders = 0;
  Set<int> _completedReminderIds = {};

  @override
  void initState() {
    super.initState();
    _loadUserAndReminders();
  }

  /// Load current user and their reminders
  /// Like: useEffect(() => { fetchReminders() }, [])
  Future<void> _loadUserAndReminders() async {
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

      // Load reminders
      await _loadReminders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading reminders: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Load reminders for current user (including inactive ones)
  Future<void> _loadReminders() async {
    if (_currentUserId == null) return;

    // Get ALL reminders (both active and inactive)
    final reminders = await _reminderRepository.getRemindersByUserId(
      _currentUserId!,
    );
    setState(() {
      _reminders = reminders;
    });

    // Load completion stats after loading reminders
    await _loadCompletionStats();
  }

  /// Show add/edit reminder modal
  /// Like: openModal() in React
  Future<void> _showAddEditModal({ReminderModel? reminder}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AddEditReminderModal(userId: _currentUserId!, reminder: reminder),
    );

    // Reload reminders if changes were made
    if (result == true) {
      _loadReminders();
    }
  }

  /// Delete reminder with confirmation
  Future<void> _deleteReminder(ReminderModel reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _reminderRepository.deleteReminder(reminder.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Reminder deleted')));
        _loadReminders();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting reminder: $e')));
      }
    }
  }

  /// Toggle reminder active status
  Future<void> _toggleReminder(ReminderModel reminder) async {
    try {
      await _reminderRepository.toggleReminderStatus(
        reminder.id!,
        !reminder.isActive,
      );
      _loadReminders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error toggling reminder: $e')));
    }
  }

  /// Logout user
  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _loadCompletionStats() async {
    // Get today's date
    final today = DateTime.now();

    // For each reminder, check if completed today
    int completed = 0;
    Set<int> completedIds = {};

    for (var reminder in _reminders) {
      final completion = await _completionRepository.getCompletion(
        reminder.id!,
        today,
      );
      if (completion?.completed == true) {
        completed++;
        completedIds.add(reminder.id!);
      }
    }

    setState(() {
      _completedToday = completed;
      _totalReminders = _reminders.where((r) => r.isActive).length;
      _completedReminderIds = completedIds;
    });
  }

  /// Toggle completion for today
  Future<void> _toggleCompletion(ReminderModel reminder) async {
    try {
      await _completionRepository.toggleCompletion(
        reminder.id!,
        DateTime.now(),
      );
      // Reload stats to update UI
      await _loadCompletionStats();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating completion: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Show completion percentage bar
                if (_totalReminders > 0)
                  CompletionPercentageBar(
                    completedCount: _completedToday,
                    totalCount: _totalReminders,
                  ),
                // Reminder list
                Expanded(child: _buildReminderList()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditModal(),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Empty state when no reminders
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No reminders yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first reminder',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Build list of reminders
  Widget _buildReminderList() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadReminders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          return ReminderListItem(
            reminder: reminder,
            onTap: () => _showAddEditModal(reminder: reminder),
            onDelete: () => _deleteReminder(reminder),
            onToggle: () => _toggleReminder(reminder),
            onComplete: () => _toggleCompletion(reminder),
            isCompletedToday: _completedReminderIds.contains(reminder.id),
          );
        },
      ),
    );
  }
}

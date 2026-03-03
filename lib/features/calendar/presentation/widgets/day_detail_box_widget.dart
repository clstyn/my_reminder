import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../calendar/data/services/calendar_service.dart';

/// Day Detail Box Widget
/// Shows completion stats and task list for a selected day
class DayDetailBox extends StatelessWidget {
  final DailyCompletionStats stats;

  const DayDetailBox({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with date
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(stats.date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${stats.completedReminders}/${stats.totalReminders}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Completion bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Completion Rate',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${stats.completionPercentage.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getCompletionColor(stats.completionPercentage),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: stats.completionPercentage / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getCompletionColor(stats.completionPercentage),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Task list
          Expanded(
            child: stats.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No reminders for this day',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: stats.reminders.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final reminderWithCompletion = stats.reminders[index];
                      return _buildTaskItem(context, reminderWithCompletion);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Build individual task item
  Widget _buildTaskItem(
    BuildContext context,
    ReminderWithCompletion reminderWithCompletion,
  ) {
    final reminder = reminderWithCompletion.reminder;
    final isCompleted = reminderWithCompletion.isCompleted;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Checkbox (read-only)
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(width: 12),

          // Task info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? Colors.grey.shade600 : Colors.black87,
                  ),
                ),
                if (reminder.description != null &&
                    reminder.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    reminder.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Time
          Text(
            DateFormat.jm().format(reminder.time),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  /// Get color based on completion percentage
  Color _getCompletionColor(double percentage) {
    if (percentage >= 100) {
      return Colors.green;
    } else if (percentage >= 80) {
      return Colors.yellow.shade700;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

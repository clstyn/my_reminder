import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/reminder_model.dart';

/// Reminder List Item - Individual reminder card
/// Like a list item component in React
class ReminderListItem extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback onComplete;
  final bool isCompletedToday;

  const ReminderListItem({
    super.key,
    required this.reminder,
    required this.onTap,
    required this.onDelete,
    required this.onToggle,
    required this.onComplete,
    required this.isCompletedToday,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final timeString = timeFormat.format(reminder.time);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: isCompletedToday,
          onChanged: reminder.isActive ? (_) => onComplete() : null,
          shape: const CircleBorder(),
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: reminder.isActive ? null : TextDecoration.lineThrough,
            color: reminder.isActive ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reminder.description != null &&
                reminder.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                reminder.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: reminder.isActive ? Colors.grey[700] : Colors.grey,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  timeString,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onTap();
                break;
              case 'toggle':
                onToggle();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    reminder.isActive ? Icons.toggle_on : Icons.toggle_off,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(reminder.isActive ? 'Deactivate' : 'Activate'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

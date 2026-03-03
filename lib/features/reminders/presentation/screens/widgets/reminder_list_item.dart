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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: reminder.isActive ? Colors.white : Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedScale(
                  scale: isCompletedToday ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Checkbox(
                    value: isCompletedToday,
                    onChanged: reminder.isActive ? (_) => onComplete() : null,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          decoration: reminder.isActive
                              ? null
                              : TextDecoration.lineThrough,
                          color: reminder.isActive
                              ? Colors.black87
                              : Colors.grey,
                        ),
                      ),

                      if (reminder.description != null &&
                          reminder.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          reminder.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: reminder.isActive
                                ? Colors.grey.shade700
                                : Colors.grey,
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  timeString,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            reminder.isActive
                                ? Icons.toggle_on
                                : Icons.toggle_off,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

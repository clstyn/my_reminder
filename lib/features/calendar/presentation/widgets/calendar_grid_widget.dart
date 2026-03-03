import 'package:flutter/material.dart';

/// Calendar Grid Widget
/// Displays a grid of days for the selected month
class CalendarGrid extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime? selectedDay;
  final Function(DateTime)? onDaySelected;
  final Map<DateTime, double>?
  completionPercentages; // Completion % for each day

  const CalendarGrid({
    super.key,
    required this.selectedDate,
    this.selectedDay,
    this.onDaySelected,
    this.completionPercentages,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Day names header
        _buildDayNamesHeader(context),
        const SizedBox(height: 8),

        // Calendar grid
        _buildCalendarGrid(context),
      ],
    );
  }

  /// Build day names header (Sun, Mon, Tue, etc.)
  Widget _buildDayNamesHeader(BuildContext context) {
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      children: dayNames.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build the calendar grid with days
  Widget _buildCalendarGrid(BuildContext context) {
    final daysInMonth = _getDaysInMonth(selectedDate);
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    // Calculate total cells needed (including empty cells before month starts)
    final totalCells = startingWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Row(
          children: List.generate(7, (colIndex) {
            final cellIndex = rowIndex * 7 + colIndex;
            final dayNumber = cellIndex - startingWeekday + 1;

            // Empty cell before month starts or after month ends
            if (cellIndex < startingWeekday || dayNumber > daysInMonth) {
              return Expanded(child: Container());
            }

            final currentDate = DateTime(
              selectedDate.year,
              selectedDate.month,
              dayNumber,
            );

            return Expanded(
              child: _buildDayCell(context, currentDate, dayNumber),
            );
          }),
        );
      }),
    );
  }

  /// Build individual day cell
  Widget _buildDayCell(BuildContext context, DateTime date, int dayNumber) {
    final isToday = _isToday(date);
    final isSelected = selectedDay != null && _isSameDay(date, selectedDay!);
    final isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    final isFutureDate = _isFutureOrToday(date); // Include today as disabled

    // Get completion percentage for this day
    final completionPercentage = completionPercentages?[date];

    return GestureDetector(
      onTap: isFutureDate || onDaySelected == null
          ? null
          : () => onDaySelected!(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isFutureDate
              ? Colors
                    .grey
                    .shade100 // Greyed out for future dates
              : isSelected
              ? Theme.of(context).primaryColor
              : isToday
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : null,
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              // Day number
              Center(
                child: Text(
                  dayNumber.toString(),
                  style: TextStyle(
                    color: isFutureDate
                        ? Colors
                              .grey
                              .shade400 // Lighter for disabled dates
                        : isSelected
                        ? Colors.white
                        : isWeekend
                        ? Colors.grey.shade600
                        : Colors.black87,
                    fontWeight: isToday || isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),

              // Completion indicator dot (only for past dates)
              if (!isFutureDate &&
                  completionPercentage != null &&
                  completionPercentage > 0)
                Positioned(
                  bottom: 4,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _getCompletionColor(completionPercentage),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get color based on completion percentage
  Color _getCompletionColor(double percentage) {
    if (percentage >= 100) {
      return Colors.green; // 100%
    } else if (percentage >= 80) {
      return Colors.yellow.shade700; // 80-99%
    } else if (percentage >= 50) {
      return Colors.orange; // 50-80%
    } else {
      return Colors.red; // Below 50%
    }
  }

  /// Get number of days in the month
  int _getDaysInMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    final lastDayOfMonth = nextMonth.subtract(const Duration(days: 1));
    return lastDayOfMonth.day;
  }

  /// Check if date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is today or in the future
  bool _isFutureOrToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isAtSameMomentAs(today) || checkDate.isAfter(today);
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

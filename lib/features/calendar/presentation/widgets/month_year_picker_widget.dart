import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Month-Year Picker Widget
/// Displays the current month/year and allows selection
class MonthYearPicker extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const MonthYearPicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(selectedDate.year, selectedDate.month + 1);
    final canGoNext =
        nextMonth.isBefore(currentMonth) ||
        nextMonth.isAtSameMomentAs(currentMonth);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Month-Year display (tappable)
          InkWell(
            onTap: () => _showMonthYearPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(selectedDate),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_drop_down, size: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show month and year picker dialog
  Future<void> _showMonthYearPicker(BuildContext context) async {
    final initialYear = selectedDate.year;
    final initialMonth = selectedDate.month;

    await showDialog(
      context: context,
      builder: (context) => _MonthYearPickerDialog(
        initialYear: initialYear,
        initialMonth: initialMonth,
        onConfirm: (year, month) {
          onDateChanged(DateTime(year, month));
        },
      ),
    );
  }
}

/// Month-Year Picker Dialog
class _MonthYearPickerDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final Function(int year, int month) onConfirm;

  const _MonthYearPickerDialog({
    required this.initialYear,
    required this.initialMonth,
    required this.onConfirm,
  });

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    _selectedMonth = widget.initialMonth;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final canIncreaseYear = _selectedYear < currentYear;

    return AlertDialog(
      title: const Text('Select Month and Year'),
      content: SizedBox(
        width: 300,
        height: 300,
        child: Column(
          children: [
            // Year selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() => _selectedYear--);
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  _selectedYear.toString(),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: canIncreaseYear
                      ? () {
                          setState(() => _selectedYear++);
                        }
                      : null,
                  icon: Icon(
                    Icons.chevron_right,
                    color: canIncreaseYear ? null : Colors.grey.shade300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Month grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected =
                      month == _selectedMonth &&
                      _selectedYear == widget.initialYear;
                  final monthName = DateFormat.MMM().format(
                    DateTime(2000, month),
                  );

                  // Disable future months
                  final isFuture =
                      _selectedYear == currentYear && month > currentMonth;

                  return InkWell(
                    onTap: isFuture
                        ? null
                        : () {
                            setState(() => _selectedMonth = month);
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isFuture
                            ? Colors.grey.shade100
                            : isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        monthName,
                        style: TextStyle(
                          color: isFuture
                              ? Colors.grey.shade400
                              : isSelected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(_selectedYear, _selectedMonth);
            Navigator.pop(context);
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

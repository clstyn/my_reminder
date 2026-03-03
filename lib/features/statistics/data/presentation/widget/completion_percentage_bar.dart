import 'package:flutter/material.dart';

class CompletionPercentageBar extends StatelessWidget {
  final int completedCount;
  final int totalCount;

  const CompletionPercentageBar({
    super.key,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final double completionPercentage = totalCount == 0
        ? 0
        : completedCount / totalCount;
    final int percentageDisplay = (completionPercentage * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        children: [
          // Text labels: "3/5" on left, "60%" on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedCount/$totalCount',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$percentageDisplay%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completionPercentage,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}

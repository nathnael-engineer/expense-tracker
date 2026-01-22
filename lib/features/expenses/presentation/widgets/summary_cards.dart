import 'package:flutter/material.dart';
import 'package:expense_tracker/features/expenses/domain/entities/summary_result.dart';

class SummaryCards extends StatelessWidget {
  final SummaryResult summary;

  const SummaryCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _card("Today", summary.totalToday, Colors.orange),
        _card("This Week", summary.totalThisWeek, Colors.blue),
        _card("This Month", summary.totalThisMonth, Colors.green),
      ],
    );
  }

  Widget _card(String title, double value, Color color) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                "\$${value.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

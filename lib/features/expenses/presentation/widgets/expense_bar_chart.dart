import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/expenses/domain/entities/summary_result.dart';

class ExpenseBarChart extends StatelessWidget {
  final SummaryResult summary;

  const ExpenseBarChart({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final values = [
      summary.totalToday,
      summary.totalThisWeek,
      summary.totalThisMonth,
    ];

    final maxY = max(1.0, values.reduce(max)) * 1.35;

    return AspectRatio(
      aspectRatio: 1.6,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 24, 22),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, progress, _) {
              return BarChart(
                BarChartData(
                  minY: 0,
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.3),
                      dashArray: [5, 5],
                    ),
                  ),
                  titlesData: _titles(maxY),
                  barGroups: values.asMap().entries.map((entry) {
                    final index = entry.key;
                    final value = entry.value * progress;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: value,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  FlTitlesData _titles(double maxY) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 44,
          interval: maxY / 4,
          getTitlesWidget: (value, _) {
            if (value == 0) return const Text('0');
            return Text(
              value >= 1000
                  ? '${(value / 1000).toStringAsFixed(1)}K'
                  : value.toInt().toString(),
              style: const TextStyle(fontSize: 11),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (value, _) {
            switch (value.toInt()) {
              case 0:
                return const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Today'),
                );
              case 1:
                return const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Week'),
                );
              case 2:
                return const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Month'),
                );
              default:
                return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}

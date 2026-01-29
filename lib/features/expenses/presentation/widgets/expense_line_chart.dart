import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/expenses/domain/entities/summary_result.dart';

class ExpenseLineChart extends StatelessWidget {
  final SummaryResult summary;

  const ExpenseLineChart({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final values = [
      summary.totalToday,
      summary.totalThisWeek,
      summary.totalThisMonth,
    ];

    final maxY = max(1.0, values.reduce(max)) * 1.35;

    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 24, 22),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, progress, _) {
              return LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 2,
                  minY: 0,
                  maxY: maxY,
                  clipData: const FlClipData.all(),
                  lineTouchData: LineTouchData(enabled: true),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.3),
                      dashArray: [5, 5],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: _titles(maxY),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, values[0] * progress),
                        FlSpot(1, values[1] * progress),
                        FlSpot(2, values[2] * progress),
                      ],
                      isCurved: true,
                      barWidth: 3,
                      color: Theme.of(context).colorScheme.primary,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
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
          interval: 1,
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

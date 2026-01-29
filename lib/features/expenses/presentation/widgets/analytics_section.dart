import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expenses/application/providers/expense_providers.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/expense_line_chart.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/expense_bar_chart.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/analytics_skeleton.dart';

class AnalyticsSection extends ConsumerWidget {
  const AnalyticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseNotifierProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _buildContent(state),
    );
  }

  Widget _buildContent(state) {
    if (state.isLoadingSummary && state.summary == null) {
      return const AnalyticsSkeleton(key: ValueKey('skeleton'));
    }

    if (state.summary == null) {
      return const SizedBox.shrink(key: ValueKey('empty'));
    }

    final summary = state.summary!;

    return Column(
      key: const ValueKey('charts'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Analytics",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        ExpenseLineChart(summary: summary),
        const SizedBox(height: 24),

        ExpenseBarChart(summary: summary),
      ],
    );
  }
}

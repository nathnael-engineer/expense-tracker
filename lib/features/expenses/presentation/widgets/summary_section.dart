import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expenses/application/providers/expense_providers.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/summary_cards.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/summary_skeleton.dart';

class SummarySection extends ConsumerWidget {
  const SummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseNotifierProvider);

    debugPrint(
      'SUMMARY → loading=${state.isLoadingSummary}, '
      'summary=${state.summary}, '
      'error=${state.errorMessage}',
    );

    // ⏳ Loading
    if (state.isLoadingSummary && state.summary == null) {
      return const SummarySkeleton();
    }

    // ❌ Error / Offline fallback
    if (state.errorMessage != null && state.summary == null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Unable to load summary.\nCheck your connection.",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.read(expenseNotifierProvider.notifier).loadSummary();
                },
              ),
            ],
          ),
        ),
      );
    }

    // 📭 No summary yet
    if (state.summary == null) {
      return const SizedBox.shrink();
    }

    // ✅ Success
    return SummaryCards(summary: state.summary!);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expenses/application/providers/expense_providers.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/expense_tile.dart';
import 'package:go_router/go_router.dart';
import '../widgets/analytics_section.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Expenses Dashboard")),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(expenseNotifierProvider.notifier).loadExpenses(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const AnalyticsSection(),
                  const SizedBox(height: 24),

                  ...state.expenses.map(
                    (expense) => ExpenseTile(
                      expense: expense,
                      onTap: () {
                        context.pushNamed('view-expense', extra: expense);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

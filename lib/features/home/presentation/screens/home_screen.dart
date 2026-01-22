import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_tracker/features/auth/application/providers/auth_providers.dart';
import 'package:expense_tracker/features/auth/application/state/auth_state.dart';
import 'package:expense_tracker/features/expenses/application/providers/expense_providers.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/expense_tile.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/summary_section.dart';

import 'package:expense_tracker/core/utils/string_extensions.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Load expenses and summary when screen opens
    ref.read(expenseNotifierProvider.notifier).loadExpenses();
    ref.read(expenseNotifierProvider.notifier).loadSummary();
  }

  void _logout() async {
    await ref.read(authNotifierProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final expenseState = ref.watch(expenseNotifierProvider);
    final user = authState.user;

    final userName = user?.name?.trim().isNotEmpty == true
        ? user!.name!
        : user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : user?.email.split('@').first ?? 'User';

    final filteredExpenses = expenseState.expenses.where((expense) {
      return expense.title.toLowerCase().contains(_query) ||
          expense.amount.toString().contains(_query);
    }).toList();

    final expenses = _query.isEmpty ? expenseState.expenses : filteredExpenses;

    // Navigate to login if user is logged out
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.user == null && prev?.user != null) {
        context.go('/login');
      }

      // Show error messages
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    ref.listen(expenseNotifierProvider, (prev, next) {
      // Only show error after deletion finished
      final wasDeleting = prev?.isDeletingExpense == true;
      final isDoneDeleting = wasDeleting && next.isDeletingExpense == false;

      if (isDoneDeleting &&
          next.errorMessage != null &&
          next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Success snackbar
      if (isDoneDeleting &&
          (next.errorMessage == null || next.errorMessage!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense deleted'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.brown.shade700,
        toolbarHeight: 48,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
          IconButton(
            onPressed: () => context.goNamed('dashboard'),
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Dashboard',
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(expenseNotifierProvider.notifier).loadExpenses();
          await ref.read(expenseNotifierProvider.notifier).loadSummary();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // User Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi, ${userName.capitalize()} 👋",
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Your Financial Snapshot",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.account_circle, size: 40),
                ],
              ),
              const SizedBox(height: 20),

              // Search Bar
              TextField(
                controller: _searchCtrl,
                onChanged: (value) {
                  setState(() {
                    _query = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search expenses",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Summary Section
              const SummarySection(),
              const SizedBox(height: 20),

              // Expenses List
              Expanded(
                child: expenses.isEmpty
                    ? Center(
                        child: Text(
                          _query.isEmpty
                              ? "No expenses yet"
                              : "No matching expenses",
                        ),
                      )
                    : ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return Dismissible(
                            key: ValueKey(expense.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete Expense'),
                                  content: const Text(
                                    'Are you sure you want to delete this expense?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                ref
                                    .read(expenseNotifierProvider.notifier)
                                    .clearError();

                                ref
                                    .read(expenseNotifierProvider.notifier)
                                    .deleteExpense(expense.id);
                              });
                            },

                            child: ExpenseTile(
                              expense: expense,
                              onTap: () {
                                context.pushNamed(
                                  'edit-expense',
                                  extra: expense,
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('add-expense'),
        backgroundColor: Colors.brown.shade700,
        child: const Icon(Icons.add),
      ),
    );
  }
}

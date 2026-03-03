import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import Notifier + State
import 'package:expense_tracker/features/expenses/application/notifiers/expense_notifier.dart';
import 'package:expense_tracker/features/expenses/application/state/expense_state.dart';

final expenseNotifierProvider = NotifierProvider<ExpenseNotifier, ExpenseState>(
  () => ExpenseNotifier(),
);

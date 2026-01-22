import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/providers/providers.dart';
import 'package:expense_tracker/core/usecases/usecase.dart';
import 'package:expense_tracker/features/expenses/application/state/expense_state.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';

import 'package:expense_tracker/features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/update_expense_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/delete_expense_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/get_expenses_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/get_summary_usecase.dart';

class ExpenseNotifier extends Notifier<ExpenseState> {
  late final AddExpenseUseCase _addExpense;
  late final UpdateExpenseUseCase _updateExpense;
  late final DeleteExpenseUseCase _deleteExpense;
  late final GetExpensesUseCase _getExpenses;
  late final GetSummaryUseCase _getSummary;

  bool _initialized = false;

  @override
  ExpenseState build() {
    _addExpense = ref.read(addExpenseUseCaseProvider);
    _updateExpense = ref.read(updateExpenseUseCaseProvider);
    _deleteExpense = ref.read(deleteExpenseUseCaseProvider);
    _getExpenses = ref.read(getExpensesUseCaseProvider);
    _getSummary = ref.read(getSummaryUseCaseProvider);

    if (!_initialized) {
      _initialized = true;
      _init();
    }

    return ExpenseState.initial();
  }

  Future<void> _init() async {
    // ⛔ Defer to next event loop tick (safe)
    await Future.delayed(Duration.zero);

    state = state.copyWith(
      isLoading: true,
      isLoadingSummary: true,
      errorMessage: null,
      summaryErrorMessage: null,
    );

    await Future.wait([loadExpenses(), loadSummary()]);

    state = state.copyWith(isLoading: false, isLoadingSummary: false);
  }

  /// Load all expenses
  Future<void> loadExpenses() async {
    final result = await _getExpenses(NoParams());

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (list) => state = state.copyWith(expenses: list),
    );
  }

  /// Add a new expense
  Future<void> addExpense(AddExpenseParams params) async {
    state = state.copyWith(isAddingExpense: true);

    final result = await _addExpense(AddExpenseParams(expense: params.expense));

    result.fold(
      (failure) => state = state.copyWith(
        isAddingExpense: false,
        errorMessage: failure.message,
      ),
      (_) async {
        await loadExpenses();
        await loadSummary();
        state = state.copyWith(isAddingExpense: false);
      },
    );
  }

  Future<void> updateExpense(ExpenseEntity expense) async {
    state = state.copyWith(isUpdatingExpense: true);

    final result = await _updateExpense(expense);

    result.fold(
      (failure) => state = state.copyWith(
        isUpdatingExpense: false,
        errorMessage: failure.message,
      ),
      (_) async {
        await loadExpenses();
        await loadSummary();
        state = state.copyWith(isUpdatingExpense: false);
      },
    );
  }

  Future<void> deleteExpense(String expenseId) async {
    state = state.copyWith(isDeletingExpense: true);

    final result = await _deleteExpense(expenseId);

    result.fold(
      (failure) => state = state.copyWith(
        isDeletingExpense: false,
        errorMessage: failure.message,
      ),
      (_) async {
        await loadExpenses();
        await loadSummary();
        state = state.copyWith(isDeletingExpense: false);
      },
    );
  }

  /// Load expense summary
  Future<void> loadSummary() async {
    final result = await _getSummary(NoParams());

    result.fold(
      (failure) => state = state.copyWith(summaryErrorMessage: failure.message),
      (summary) => state = state.copyWith(summary: summary),
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

import 'dart:async';
import 'package:expense_tracker/core/network/network_info.dart';
import 'package:expense_tracker/injection.dart';
import 'package:expense_tracker/core/errors/failures.dart';

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

  StreamSubscription<bool>? _networkSubscription;
  bool _initialized = false;

  DateTime? _lastSuccessfulSync;
  bool _hadNetworkError = false;
  bool _isRefreshingFromReconnect = false;

  static const _syncInterval = Duration(minutes: 5);

  // BUILD
  @override
  ExpenseState build() {
    _setupDependencies();

    if (!_initialized) {
      _initialized = true;
      _bootstrap();
    }

    return ExpenseState.initial();
  }

  void _setupDependencies() {
    _addExpense = ref.read(addExpenseUseCaseProvider);
    _updateExpense = ref.read(updateExpenseUseCaseProvider);
    _deleteExpense = ref.read(deleteExpenseUseCaseProvider);
    _getExpenses = ref.read(getExpensesUseCaseProvider);
    _getSummary = ref.read(getSummaryUseCaseProvider);
  }

  void _bootstrap() {
    _loadInitialData();
    _listenToNetworkChanges();

    ref.onDispose(() {
      _networkSubscription?.cancel();
    });
  }

  // INITIAL LOAD
  Future<void> _loadInitialData() async {
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

  void _listenToNetworkChanges() {
    final networkInfo = sl<NetworkInfo>();

    _networkSubscription = networkInfo.onConnectionChanged.distinct().listen((
      connected,
    ) async {
      if (!connected) return;

      final now = DateTime.now();

      final shouldRefresh =
          _hadNetworkError ||
          state.expenses.isEmpty ||
          _lastSuccessfulSync == null ||
          now.difference(_lastSuccessfulSync!) > _syncInterval;

      if (!shouldRefresh || _isRefreshingFromReconnect) return;

      _isRefreshingFromReconnect = true;

      await Future.wait([loadExpenses(), loadSummary()]);

      _isRefreshingFromReconnect = false;
    });
  }

  //EXPENSES
  Future<void> loadExpenses() async {
    final result = await _getExpenses(NoParams());

    result.fold(
      (failure) {
        if (failure is NetworkFailure) {
          _hadNetworkError = true;
        }

        state = state.copyWith(errorMessage: failure.message);
      },
      (list) {
        _hadNetworkError = false;
        _lastSuccessfulSync = DateTime.now();

        state = state.copyWith(expenses: list, errorMessage: null);
      },
    );
  }

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

    final previousExpenses = state.expenses;
    state = state.copyWith(
      expenses: previousExpenses.where((e) => e.id != expenseId).toList(),
    );

    final result = await _deleteExpense(expenseId);

    result.fold(
      (failure) => state = state.copyWith(
        expenses: previousExpenses,
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

  //SUMMARY
  Future<void> loadSummary() async {
    final result = await _getSummary(NoParams());

    result.fold(
      (failure) {
        if (failure is NetworkFailure) {
          _hadNetworkError = true;
        }

        state = state.copyWith(summaryErrorMessage: failure.message);
      },
      (summary) {
        _hadNetworkError = false;
        _lastSuccessfulSync = DateTime.now();

        state = state.copyWith(summary: summary, summaryErrorMessage: null);
      },
    );
  }

  // UTIL
  void clearError() {
    state = state.copyWith(errorMessage: null, summaryErrorMessage: null);
  }
}

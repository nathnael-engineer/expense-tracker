import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:expense_tracker/features/expenses/domain/entities/summary_result.dart';

class ExpenseState extends Equatable {
  final bool isLoading;
  final bool isAddingExpense;
  final bool isUpdatingExpense;
  final bool isDeletingExpense;
  final bool isLoadingSummary;
  final List<ExpenseEntity> expenses;
  final SummaryResult? summary;
  final String? errorMessage;
  final String? summaryErrorMessage;

  const ExpenseState({
    this.isLoading = false,
    this.isAddingExpense = false,
    this.isUpdatingExpense = false,
    this.isDeletingExpense = false,
    this.isLoadingSummary = false,
    this.expenses = const [],
    this.summary,
    this.errorMessage,
    this.summaryErrorMessage,
  });

  factory ExpenseState.initial() => const ExpenseState();

  ExpenseState copyWith({
    bool? isLoading,
    bool? isAddingExpense,
    bool? isUpdatingExpense,
    bool? isDeletingExpense,
    bool? isLoadingSummary,
    List<ExpenseEntity>? expenses,
    SummaryResult? summary,
    String? errorMessage,
    String? summaryErrorMessage,
  }) {
    return ExpenseState(
      isLoading: isLoading ?? this.isLoading,
      isAddingExpense: isAddingExpense ?? this.isAddingExpense,
      isUpdatingExpense: isUpdatingExpense ?? this.isUpdatingExpense,
      isDeletingExpense: isDeletingExpense ?? this.isDeletingExpense,
      isLoadingSummary: isLoadingSummary ?? this.isLoadingSummary,
      expenses: expenses ?? this.expenses,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
      summaryErrorMessage: summaryErrorMessage ?? this.summaryErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isAddingExpense,
    isUpdatingExpense,
    isDeletingExpense,
    isLoadingSummary,
    expenses,
    summary,
    errorMessage,
    summaryErrorMessage,
  ];
}

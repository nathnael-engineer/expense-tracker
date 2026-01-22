import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/errors/failures.dart';

import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:expense_tracker/features/expenses/domain/entities/summary_result.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, void>> addExpense(ExpenseEntity expense);
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses();
  Future<Either<Failure, void>> updateExpense(ExpenseEntity expense);
  Future<Either<Failure, void>> deleteExpense(String expenseId);
  Future<Either<Failure, SummaryResult>> getSummary();
}

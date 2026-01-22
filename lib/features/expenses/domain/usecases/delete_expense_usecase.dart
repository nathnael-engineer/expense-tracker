import 'package:expense_tracker/core/usecases/usecase.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/errors/failures.dart';

class UpdateExpenseUseCase implements UseCase<void, ExpenseEntity> {
  final ExpenseRepository repository;

  UpdateExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ExpenseEntity expense) {
    return repository.updateExpense(expense);
  }
}

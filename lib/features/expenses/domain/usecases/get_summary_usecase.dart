import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/errors/failures.dart';
import 'package:expense_tracker/core/usecases/usecase.dart';
import 'package:expense_tracker/features/expenses/domain/entities/summary_result.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:flutter/material.dart';

class GetSummaryUseCase implements UseCase<SummaryResult, NoParams> {
  final ExpenseRepository repository;

  GetSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, SummaryResult>> call(NoParams params) {
    debugPrint("🔥 GetSummaryUseCase CALLED");
    return repository.getSummary();
  }
}

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/errors/failures.dart';
import 'package:expense_tracker/core/usecases/usecase.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';

class ReloadUserUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  ReloadUserUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.reloadUser();
  }
}

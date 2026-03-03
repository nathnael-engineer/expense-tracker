import 'package:dartz/dartz.dart';
import 'package:expense_tracker/features/auth/domain/entities/user_entity.dart';
import 'package:expense_tracker/core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> sendEmailVerification();
  Future<Either<Failure, void>> reloadUser();
  Stream<UserEntity?> authStateChanges();
}

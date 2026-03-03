import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/auth/domain/entities/user_entity.dart';

class AuthState extends Equatable {
  final UserEntity? user;
  final bool requiresEmailVerification;

  const AuthState({this.user, this.requiresEmailVerification = false});

  @override
  List<Object?> get props => [user, requiresEmailVerification];
}

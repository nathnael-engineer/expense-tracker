import 'package:expense_tracker/features/auth/domain/usecases/send_email_verification_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker/features/auth/domain/usecases/login_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/logout_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/register_usecase.dart';

import 'package:expense_tracker/features/auth/application/state/auth_state.dart';
import 'package:expense_tracker/core/providers/providers.dart';
import 'package:expense_tracker/core/config/app_env.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState.initial();
  }

  // ====== Dependencies ======
  LoginUseCase get _loginUseCase => ref.read(loginUseCaseProvider);
  RegisterUseCase get _registerUseCase => ref.read(registerUseCaseProvider);
  LogoutUseCase get _logoutUseCase => ref.read(logoutUseCaseProvider);
  SendEmailVerificationUseCase get _sendEmailVerificationUseCase =>
      ref.read(sendEmailVerificationUseCaseProvider);

  // ====== Actions ======

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _loginUseCase(LoginParams(email, password));

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user);
      },
    );
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true);

    final result = await _registerUseCase(RegisterParams(email, password));

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },

      (user) {
        state = state.copyWith(isLoading: false, user: user);

        if (!AppEnv.disableEmailVerification) {
          _sendEmailVerificationUseCase();
        }
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    final result = await _logoutUseCase(NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (_) => state = AuthState.initial(),
    );
  }
}

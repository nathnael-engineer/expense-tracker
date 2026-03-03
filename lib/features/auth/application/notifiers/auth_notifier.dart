import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker/core/usecases/usecase.dart';
import 'package:expense_tracker/core/providers/providers.dart';

import 'package:expense_tracker/features/auth/application/state/auth_state.dart';
import 'package:expense_tracker/features/auth/domain/entities/user_entity.dart';

import 'package:expense_tracker/features/auth/domain/usecases/login_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/logout_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/register_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/send_email_verification_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/reload_user_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/listen_auth_state_changes_usecase.dart';

class AuthNotifier extends AsyncNotifier<AuthState> {
  // === DEPENDENCIES ===

  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final SendEmailVerificationUseCase _sendEmailVerificationUseCase;
  late final ReloadUserUseCase _reloadUserUseCase;
  late final ListenAuthStateChangesUseCase _listenAuthStateChangesUseCase;

  StreamSubscription<UserEntity?>? _authSubscription;

  // ===== BUILD =====

  @override
  Future<AuthState> build() async {
    _setupDependencies();
    return _bootstrap();
  }

  void _setupDependencies() {
    _loginUseCase = ref.read(loginUseCaseProvider);
    _registerUseCase = ref.read(registerUseCaseProvider);
    _logoutUseCase = ref.read(logoutUseCaseProvider);
    _sendEmailVerificationUseCase = ref.read(
      sendEmailVerificationUseCaseProvider,
    );
    _reloadUserUseCase = ref.read(reloadUserUseCaseProvider);
    _listenAuthStateChangesUseCase = ref.read(listenAuthStateChangesProvider);
  }

  Future<AuthState> _bootstrap() async {
    final completer = Completer<AuthState>();
    final start = DateTime.now();

    _authSubscription = _listenAuthStateChangesUseCase().listen((user) async {
      final newState = AuthState(
        user: user,
        requiresEmailVerification: user != null && !user.emailVerified,
      );

      if (!completer.isCompleted) {
        final elapsed = DateTime.now().difference(start);
        const minDuration = Duration(milliseconds: 3000);

        if (elapsed < minDuration) {
          await Future.delayed(minDuration - elapsed);
        }

        completer.complete(newState);
      }

      state = AsyncData(newState);
    });

    ref.onDispose(() => _authSubscription?.cancel());

    return completer.future;
  }

  // ===== Actions =====

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    final result = await _loginUseCase(LoginParams(email, password));

    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) {},
    );
  }

  Future<void> register(String email, String password) async {
    state = const AsyncLoading();

    final result = await _registerUseCase(RegisterParams(email, password));

    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) {},
    );
  }

  Future<void> resendVerificationEmail() async {
    await _sendEmailVerificationUseCase();
  }

  Future<void> reloadUser() async {
    await _reloadUserUseCase(NoParams());
  }

  Future<void> logout() async {
    await _logoutUseCase(NoParams());
  }
}

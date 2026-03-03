import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/injection.dart';

import 'package:expense_tracker/features/auth/domain/usecases/login_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/register_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/logout_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/send_email_verification_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/reload_user_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/listen_auth_state_changes_usecase.dart';

import 'package:expense_tracker/features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/get_expenses_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/get_summary_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/update_expense_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/delete_expense_usecase.dart';

// ----------- AUTH USECASES -----------
final loginUseCaseProvider = Provider((ref) => sl<LoginUseCase>());
final registerUseCaseProvider = Provider((ref) => sl<RegisterUseCase>());
final logoutUseCaseProvider = Provider((ref) => sl<LogoutUseCase>());
final sendEmailVerificationUseCaseProvider = Provider(
  (ref) => sl<SendEmailVerificationUseCase>(),
);
final reloadUserUseCaseProvider = Provider((ref) => sl<ReloadUserUseCase>());
final listenAuthStateChangesProvider = Provider(
  (ref) => sl<ListenAuthStateChangesUseCase>(),
);

// ----------- EXPENSE USECASES -----------
final addExpenseUseCaseProvider = Provider((ref) => sl<AddExpenseUseCase>());
final getExpensesUseCaseProvider = Provider((ref) => sl<GetExpensesUseCase>());
final getSummaryUseCaseProvider = Provider((ref) => sl<GetSummaryUseCase>());
final updateExpenseUseCaseProvider = Provider(
  (ref) => sl<UpdateExpenseUseCase>(),
);
final deleteExpenseUseCaseProvider = Provider(
  (ref) => sl<DeleteExpenseUseCase>(),
);

import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

// ------------------------------
// Features - Auth
// ------------------------------
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/send_email_verification_usecase.dart';

// ------------------------------
// Features - Expenses
// ------------------------------
import 'features/expenses/data/datasources/expense_remote_datasource.dart';
import 'features/expenses/data/repositories/expense_repository_impl.dart';
import 'features/expenses/domain/repositories/expense_repository.dart';
import 'features/expenses/domain/usecases/add_expense_usecase.dart';
import 'features/expenses/domain/usecases/get_expenses_usecase.dart';
import 'features/expenses/domain/usecases/get_summary_usecase.dart';
import 'features/expenses/domain/usecases/update_expense_usecase.dart';
import 'features/expenses/domain/usecases/delete_expense_usecase.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ------------------------------
  // Firebase
  // ------------------------------
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseDatabase>(() => FirebaseDatabase.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseFunctions>(() => FirebaseFunctions.instance);

  // ------------------------------
  // Auth Datasource
  // ------------------------------
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<FirebaseAuth>(), sl<FirebaseDatabase>()),
  );

  // ------------------------------
  // Auth Repository
  // ------------------------------
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  // ------------------------------
  // Auth Usecases
  // ------------------------------
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SendEmailVerificationUseCase>(
    () => SendEmailVerificationUseCase(sl<AuthRepository>()),
  );

  // ------------------------------
  // Expense Datasource
  // ------------------------------
  sl.registerLazySingleton<ExpenseRemoteDataSource>(
    () => ExpenseRemoteDataSourceImpl(
      sl<FirebaseFirestore>(),
      sl<FirebaseFunctions>(),
      sl<FirebaseAuth>(),
    ),
  );

  // ------------------------------
  // Expense Repository
  // ------------------------------
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(sl<ExpenseRemoteDataSource>()),
  );

  // ------------------------------
  // Expense Usecases
  // ------------------------------
  sl.registerLazySingleton<AddExpenseUseCase>(
    () => AddExpenseUseCase(sl<ExpenseRepository>()),
  );

  sl.registerLazySingleton<UpdateExpenseUseCase>(
    () => UpdateExpenseUseCase(sl<ExpenseRepository>()),
  );

  sl.registerLazySingleton<DeleteExpenseUseCase>(
    () => DeleteExpenseUseCase(sl<ExpenseRepository>()),
  );

  sl.registerLazySingleton<GetExpensesUseCase>(
    () => GetExpensesUseCase(sl<ExpenseRepository>()),
  );

  sl.registerLazySingleton<GetSummaryUseCase>(
    () => GetSummaryUseCase(sl<ExpenseRepository>()),
  );
}

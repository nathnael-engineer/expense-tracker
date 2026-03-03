import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:expense_tracker/firebase_options.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/router/app_router.dart';
// import 'package:expense_tracker/core/firebase/firebase_emulator.dart';
import 'package:expense_tracker/injection.dart' as injection;
// import 'package:expense_tracker/core/firebase/firebase_appcheck.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase SDK
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable Firebase App Check (DEBUG MODE)
  // await FirebaseAppCheckService.activate();

  // Connect Firebase services to Firebase Emulators (DEBUG ONLY)
  // await FirebaseEmulatorConfig.connect();

  // Initialize GetIt / DI
  await injection.initDependencies();

  // Wrap the entire app with ProviderScope for Riverpod
  runApp(const ProviderScope(child: ExpenseTrackerApp()));
}

class ExpenseTrackerApp extends ConsumerWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

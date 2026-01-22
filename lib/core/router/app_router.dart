import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_tracker/features/auth/application/providers/auth_providers.dart';

import 'package:expense_tracker/features/auth/presentation/screens/login_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/signup_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/splash_screen.dart';

import 'package:expense_tracker/features/home/presentation/screens/home_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/dashboard_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/view_expense_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authListenable = ref.watch(authListenableProvider);
  ref.read(authNotifierProvider.notifier);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final loggedIn = authState.user != null;

      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && state.matchedLocation == '/login') return '/home';

      return null;
    },

    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // HOME
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'add-expense',
            name: 'add-expense',
            builder: (context, state) {
              return const AddExpenseScreen();
            },
          ),
          GoRoute(
            path: 'edit-expense',
            name: 'edit-expense',
            builder: (context, state) {
              final expense = state.extra as ExpenseEntity?;
              return AddExpenseScreen(expense: expense);
            },
          ),
          GoRoute(
            path: 'dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: 'view-expense',
            name: 'view-expense',
            builder: (context, state) {
              final expense = state.extra as ExpenseEntity;
              return ViewExpenseScreen(expense: expense);
            },
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found 🎯'))),
  );
});

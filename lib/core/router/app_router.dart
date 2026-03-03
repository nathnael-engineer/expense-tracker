import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/router/router_refresh_notifier.dart';

import 'package:expense_tracker/features/auth/application/providers/auth_providers.dart';

import 'package:expense_tracker/features/auth/presentation/screens/login_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/signup_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/splash_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/verify_email_screen.dart';

import 'package:expense_tracker/features/home/presentation/screens/home_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/dashboard_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/view_expense_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authAsync = ref.read(authNotifierProvider);

      if (!authAsync.hasValue) {
        return state.matchedLocation == '/' ? null : '/';
      }

      final authState = authAsync.value!;

      final loggedIn = authState.user != null;
      final requiresVerification = authState.requiresEmailVerification;

      final goingToSplash = state.matchedLocation == '/';
      final goingToAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';
      final goingToVerify = state.matchedLocation == '/verify-email';

      if (!loggedIn) {
        return goingToAuth ? null : '/login';
      }

      if (requiresVerification) {
        return goingToVerify ? null : '/verify-email';
      }

      if (goingToAuth || goingToVerify || goingToSplash) {
        return '/home';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: SplashScreen());
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
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

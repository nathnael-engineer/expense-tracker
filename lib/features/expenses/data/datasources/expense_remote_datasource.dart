import 'dart:async';
import 'package:expense_tracker/core/errors/exceptions.dart';
import 'package:expense_tracker/core/network/request_handler.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/features/expenses/data/models/expense_model.dart';
import 'package:expense_tracker/features/expenses/data/models/summary_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getExpenses();
  Future<void> addExpense(ExpenseModel model);
  Future<void> updateExpense(ExpenseModel model);
  Future<void> deleteExpense(String expenseId);
  Future<SummaryModel> getSummary();
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final RequestHandler requestHandler;

  ExpenseRemoteDataSourceImpl(this.firestore, this.auth, this.requestHandler);

  CollectionReference<Map<String, dynamic>> _expenseRef(String uid) {
    return firestore.collection('users').doc(uid).collection('expenses');
  }

  /// 🔹 Read user expenses
  @override
  Future<List<ExpenseModel>> getExpenses() {
    return requestHandler.execute(() async {
      final user = auth.currentUser;

      if (user == null) {
        throw AuthException('User not authenticated');
      }

      final snapshot = await _expenseRef(
        user.uid,
      ).orderBy('date', descending: true).get();

      return snapshot.docs
          .map((doc) => ExpenseModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// 🔹 Write user expense
  @override
  Future<void> addExpense(ExpenseModel model) async {
    return requestHandler.execute(() async {
      final user = auth.currentUser;
      if (user == null) {
        throw AuthException('User not authenticated');
      }

      await _expenseRef(user.uid).add(model.toMap());
    });
  }

  /// 🔹 Update user expense
  @override
  Future<void> updateExpense(ExpenseModel model) async {
    return requestHandler.execute(() async {
      final user = auth.currentUser;
      if (user == null) {
        throw AuthException('User not authenticated');
      }

      await _expenseRef(user.uid).doc(model.id).update(model.toMap());
    });
  }

  /// 🔹 Delete user expense
  @override
  Future<void> deleteExpense(String expenseId) async {
    return requestHandler.execute(() async {
      final user = auth.currentUser;
      if (user == null) {
        throw AuthException('User not authenticated');
      }

      await _expenseRef(user.uid).doc(expenseId).delete();
    });
  }

  /// 🔹 Get summary of expenses for today, this week, and this month
  @override
  Future<SummaryModel> getSummary() async {
    return requestHandler.execute(() async {
      final user = auth.currentUser;
      if (user == null) {
        throw AuthException('User not authenticated');
      }

      final now = DateTime.now();

      // Date boundaries
      final startOfToday = DateTime(now.year, now.month, now.day);
      final startOfTomorrow = startOfToday.add(const Duration(days: 1));

      final startOfWeek = startOfToday.subtract(
        Duration(days: startOfToday.weekday - 1),
      );
      final startOfNextWeek = startOfWeek.add(const Duration(days: 7));

      final startOfMonth = DateTime(now.year, now.month);
      final startOfNextMonth = DateTime(now.year, now.month + 1);

      // Convert to Firestore Timestamps for querying
      final today = Timestamp.fromDate(startOfToday);
      final tomorrow = Timestamp.fromDate(startOfTomorrow);
      final week = Timestamp.fromDate(startOfWeek);
      final nextWeek = Timestamp.fromDate(startOfNextWeek);
      final month = Timestamp.fromDate(startOfMonth);
      final nextMonth = Timestamp.fromDate(startOfNextMonth);

      final expensesRef = firestore
          .collection('users')
          .doc(user.uid)
          .collection('expenses');

      // Run queries in parallel to minimize latency
      final results = await Future.wait([
        expensesRef
            .where('date', isGreaterThanOrEqualTo: today)
            .where('date', isLessThan: tomorrow)
            .get(),
        expensesRef
            .where('date', isGreaterThanOrEqualTo: week)
            .where('date', isLessThan: nextWeek)
            .get(),
        expensesRef
            .where('date', isGreaterThanOrEqualTo: month)
            .where('date', isLessThan: nextMonth)
            .get(),
      ]);

      final todaySnap = results[0];
      final weekSnap = results[1];
      final monthSnap = results[2];

      double sum(QuerySnapshot snap) {
        return snap.docs.fold(
          0.0,
          (total, doc) => total + (doc['amount'] as num).toDouble(),
        );
      }

      return SummaryModel(
        totalToday: sum(todaySnap),
        totalThisWeek: sum(weekSnap),
        totalThisMonth: sum(monthSnap),
      );
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
  final FirebaseFunctions functions;
  final FirebaseAuth auth;

  ExpenseRemoteDataSourceImpl(this.firestore, this.functions, this.auth);

  CollectionReference<Map<String, dynamic>> _expenseRef(String uid) {
    return firestore.collection('users').doc(uid).collection('expenses');
  }

  /// 🔹 Read user expenses
  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final snapshot = await _expenseRef(
      user.uid,
    ).orderBy('date', descending: true).get();

    return snapshot.docs
        .map((doc) => ExpenseModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// 🔹 Write user expense
  @override
  Future<void> addExpense(ExpenseModel model) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _expenseRef(user.uid).add(model.toMap());
  }

  /// 🔹 Update user expense
  @override
  Future<void> updateExpense(ExpenseModel model) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _expenseRef(user.uid).doc(model.id).update(model.toMap());
  }

  /// 🔹 Delete user expense
  @override
  Future<void> deleteExpense(String expenseId) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _expenseRef(user.uid).doc(expenseId).delete();
  }

  /// 🔹 Cloud Function summary
  @override
  Future<SummaryModel> getSummary() async {
    final result = await functions.httpsCallable('getExpenseSummary').call();

    return SummaryModel.fromMap(Map<String, dynamic>.from(result.data));
  }
}

import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.category,
    required super.date,
  });

  /// Entity → Model (USED by Repository)
  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      category: entity.category,
      date: entity.date,
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toMap() => {
    'title': title,
    'amount': amount,
    'category': category,
    'date': Timestamp.fromDate(date),
  };

  /// Firestore → Model
  factory ExpenseModel.fromMap(String id, Map<String, dynamic> map) {
    final Timestamp timestamp = map['date'] as Timestamp;

    return ExpenseModel(
      id: id,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? 'Other',
      date: timestamp.toDate(),
    );
  }
}

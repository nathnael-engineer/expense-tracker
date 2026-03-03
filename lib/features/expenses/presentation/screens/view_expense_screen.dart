import 'package:flutter/material.dart';
import 'package:expense_tracker/core/utils/formatter.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/widgets/network_banner.dart';
import 'package:expense_tracker/core/network/network_banner_provider.dart';

class ViewExpenseScreen extends ConsumerWidget {
  final ExpenseEntity expense;
  const ViewExpenseScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerAsync = ref.watch(networkBannerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Expense Details")),
      body: Column(
        children: [
          NetworkBanner(bannerAsync: bannerAsync),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Title: ${expense.title}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Amount: ${Formatter.currency(expense.amount)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Category: ${expense.category}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Date: ${Formatter.date(expense.date)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

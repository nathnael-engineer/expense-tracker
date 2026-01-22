import 'package:expense_tracker/features/expenses/domain/entities/expense_category.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/core/utils/formatter.dart';
import 'package:expense_tracker/core/utils/validators.dart';
import 'package:expense_tracker/features/expenses/application/providers/expense_providers.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/add_expense_usecase.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseEntity? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _selectedCategory = ExpenseCategories.other;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();

    if (widget.expense != null) {
      _titleCtrl.text = widget.expense!.title;
      _amountCtrl.text = widget.expense!.amount.toString();
      _selectedCategory = widget.expense!.category;
      _date = widget.expense!.date;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;

    final expense = ExpenseEntity(
      id: widget.expense?.id ?? '',
      title: _titleCtrl.text.trim(),
      amount: amount,
      category: _selectedCategory,
      date: _date,
    );

    final notifier = ref.read(expenseNotifierProvider.notifier);

    if (widget.expense == null) {
      await notifier.addExpense(AddExpenseParams(expense: expense));
    } else {
      await notifier.updateExpense(expense);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? "Add Expense" : "Edit Expense"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: "Title"),
                validator: Validators.nonEmpty,
              ),
              const SizedBox(height: 12),

              // Amount
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Amount required";
                  if (double.tryParse(val) == null) return "Invalid number";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: ExpenseCategories.all.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),

              const SizedBox(height: 12),

              // Date Picker
              Row(
                children: [
                  Text("Date: ${Formatter.date(_date)}"),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text("Pick Date"),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      expenseState.isAddingExpense ||
                          expenseState.isUpdatingExpense
                      ? null
                      : _onSubmit,
                  child:
                      expenseState.isAddingExpense ||
                          expenseState.isUpdatingExpense
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        )
                      : Text(
                          widget.expense == null
                              ? "Add Expense"
                              : "Update Expense",
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

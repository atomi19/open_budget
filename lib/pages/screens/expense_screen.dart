import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/widgets/transaction_add_form.dart';

class ExpenseScreen extends StatefulWidget {
  final TransactionsDatabase db;
  final void Function({
    required bool isIncome, 
    required Function(int index) onTap,
  }) showCategories;

  const ExpenseScreen({
    super.key,
    required this.db,
    required this.showCategories,
  });
  @override
  ExpenseScreenState createState() => ExpenseScreenState();
}

class ExpenseScreenState extends State<ExpenseScreen> {
  @override
  Widget build(BuildContext context) {
    return TransactionAddForm(
      db: widget.db, 
      isIncome: false, 
      showCategories: widget.showCategories
    );
  }
}

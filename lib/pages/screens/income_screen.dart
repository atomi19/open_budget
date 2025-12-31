import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/widgets/transaction_add_form.dart';

class IncomeScreen extends StatefulWidget {
  final TransactionsDatabase db;
  final void Function({
    required bool isIncome, 
    required Function(int index) onTap,
  }) showCategories;

  const IncomeScreen({
    super.key,
    required this.db,
    required this.showCategories,
  });
  @override
  IncomeScreenState createState() => IncomeScreenState();
}

class IncomeScreenState extends State<IncomeScreen> {
  @override
  Widget build(BuildContext context) {
    return TransactionAddForm(
      db: widget.db, 
      isIncome: true,
      showCategories: widget.showCategories
    );
  }
}
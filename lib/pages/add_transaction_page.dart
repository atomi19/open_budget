// main page that contains income and expense screens (switch between them)
import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/pages/screens/expense_screen.dart';
import 'package:open_budget/pages/screens/income_screen.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionsDatabase db;

  const AddTransactionPage({
    super.key,
    required this.db,
  });
  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  int _transactionPageIndex = 0; // 0 - income page, 1 - spending page

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body:  Column(
        spacing: 10,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: _transactionPageIndex == 0
                    ? Colors.blue
                    : Colors.transparent
                  ),
                  onPressed: () => setState(() => _transactionPageIndex = 0), 
                  child: Text(
                    'Income',
                    style: TextStyle(color: _transactionPageIndex == 0
                    ? Colors.white
                    : Colors.black
                    ),
                  )
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: _transactionPageIndex == 1
                    ? Colors.blue
                    : Colors.transparent
                  ),
                  onPressed: () => setState(() => _transactionPageIndex = 1), 
                  child: Text(
                    'Expense', 
                    style: TextStyle(color: _transactionPageIndex ==1
                    ? Colors.white
                    : Colors.black
                    )
                  )
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _transactionPageIndex,
              children: [
                IncomeScreen(
                  db: widget.db,
                ),
                ExpenseScreen(
                  db: widget.db,
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}
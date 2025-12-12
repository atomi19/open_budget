// used inside home_page_content to build the ListView.builder 
// with transactions (as for now all transactions and last 3 transactions)

import 'package:flutter/material.dart';
import 'package:open_budget/logic/currencies.dart';
import 'package:open_budget/logic/database/database.dart';

Widget buildTransactionList({
  required BuildContext context,
  required bool shrinkWrap,
  required List<Transaction> items,
  required Currency currentCurrency,
  required Function(Transaction) showTransactionDetails,
}) {
  return ListView.builder(
    shrinkWrap: shrinkWrap,
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      return Stack(
        children: [
          ListTile(
            title: Text(item.category),
            subtitle: item.description.trim().isNotEmpty
              ? Text(item.description)
              : null,
            trailing: Text(
              '${item.amount.toString()} ${currentCurrency.symbol}',
              style: TextStyle(
                color: item.amount > 0
                ? Colors.green
                : Colors.black,
                fontSize: 16
              ),
            ),
            onTap: () => showTransactionDetails(item),
          ),
          Positioned(
            left: 15,
            right: 15,
            bottom: 0,
            child: Container(
              height: 1,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      );
    }
  );
}
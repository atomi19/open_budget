// used inside home_page_content to build the ListView.builder 
// with transactions (as for now all transactions and last 3 transactions)

import 'package:flutter/material.dart';
import 'package:open_budget/logic/currencies.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';

const List<String> _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

Widget buildTransactionList({
  required BuildContext context,
  required bool shrinkWrap,
  required List<Transaction> items,
  required Currency currentCurrency,
  required Function(Transaction) showTransactionDetails,
  required bool shouldInsertDate,
  required bool showDescription,
}) {
  return ListView.builder(
    shrinkWrap: shrinkWrap,
    itemCount: items.length,
    itemBuilder: (context, index) {
      bool showDate = false;
      final item = items[index];
      final previousItem = index > 0 ? items[index-1] : null;

      // check if this is required to insert date (each day) between transactions
      if(shouldInsertDate) {
        if(previousItem == null) {
          // show date if there is only one transaction
          showDate = true;
        } else {
          final previousDate = DateTime(previousItem.dateAndTime.year, previousItem.dateAndTime.month, previousItem.dateAndTime.day);
          final currentDate = DateTime(item.dateAndTime.year, item.dateAndTime.month, item.dateAndTime.day);
          // show date if current date is not the same as previous date
          if(currentDate != previousDate) {
            showDate = true;
          }
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // date between transactions (each day)
          if(showDate)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
              child: Center(
                child: Text('${item.dateAndTime.day} ${_months[item.dateAndTime.month - 1]} ${item.dateAndTime.year}'),
              ),
            ),
          // transaction ListTile
          CustomListTile(
            title: item.category,
            subtitle: showDescription
            ? item.description.trim().isNotEmpty
              ? Text(
                item.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600),
              )
              : null
            : null,
            trailing: Text(
              '${item.amount.toString()} ${currentCurrency.symbol}',
              style: TextStyle(
                color: item.amount > 0
                ? Colors.green
                : Colors.black,
                fontSize: 15
              ),
            ),
            onTap: () => showTransactionDetails(item),
          ),
        ]
      );
    }
  );
}
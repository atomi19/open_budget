import 'package:flutter/material.dart';
import 'package:open_budget/logic/currencies.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/format_number.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';

class SummaryWidget extends StatelessWidget {
  final AppDatabase db;
  final Account account;
  final Currency accountCurrency;
  final DateTime startDate;
  final DateTime endDate;

  const SummaryWidget({
    super.key,
    required this.db,
    required this.account,
    required this.accountCurrency,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // net 
        StreamBuilder(
          stream: db.transactionsDao.watchTotalIncome(
            accountOwnerId: account.id,
            customStartDate: startDate,
            customEndDate: endDate
          ), 
          builder: (context, incomeSnapshot) {
            final income = incomeSnapshot.data ?? 0;

            return StreamBuilder(
              stream: db.transactionsDao.watchTotalExpense(
                accountOwnerId: account.id,
                customStartDate: startDate,
                customEndDate: endDate
              ), 
              builder: (context, expenseSnapshot) {
                final expense = (expenseSnapshot.data ?? 0).abs();

                final net = income - expense;
                final formattedNet = formatNumber(net);
                final isPositive = net > 0 ? true : false;
                
                return CustomListTile(
                  tileColor: Theme.of(context).colorScheme.primaryContainer, 
                  leading: const CustomIcon(icon: Icons.bar_chart),
                  title: 'Net',
                  trailing: Text(
                    '$formattedNet ${accountCurrency.symbol}',
                    style: TextStyle(
                      fontSize: 15,
                      color: isPositive ? Colors.green : Theme.of(context).colorScheme.onPrimary
                    ),
                  ),
                  customBorder: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15))
                  ),
                );
              }
            );
          }
        ),
        Divider(
          height: 1,
          color: Theme.of(context).colorScheme.surface,
        ),
        // total incomes
        StreamBuilder(
          stream: db.transactionsDao.watchTotalIncome(
            accountOwnerId: account.id,
            customStartDate: startDate,
            customEndDate: endDate,
          ), 
          builder: (context, snapshot) {
            final income = snapshot.data ?? 0;
            final formattedIncome = formatNumber(income);

            return CustomListTile(
              tileColor: Theme.of(context).colorScheme.primaryContainer,
              leading: const CustomIcon(icon: Icons.download_outlined),
              title: 'Income',
              trailing: Text(
                '+$formattedIncome ${accountCurrency.symbol}',
                style: TextStyle(
                  fontSize: 15,
                  color: income > 0 ? Colors.green : Theme.of(context).colorScheme.onPrimary
                ),
              ),
              customBorder: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero
              ),
            );
          }
        ),
        // total expenses
        StreamBuilder(
          stream: db.transactionsDao.watchTotalExpense(
            accountOwnerId: account.id,
            customStartDate: startDate,
            customEndDate: endDate,
          ), 
          builder: (context, snapshot) {
            final expense = snapshot.data ?? 0;
            final formattedExpense = formatNumber(expense);

            return CustomListTile(
              tileColor: Theme.of(context).colorScheme.primaryContainer,
              leading: const CustomIcon(icon: Icons.upload_outlined),
              title: 'Expense',
              trailing: Text(
                '$formattedExpense ${accountCurrency.symbol}',
                style: const TextStyle(
                  fontSize: 15
                ),
              ),
              customBorder: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))
              ),
            );
          }
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:open_budget/logic/currencies.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/widgets/build_transactions_list.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_text_field.dart';
import 'package:open_budget/widgets/empty_list_placeholder.dart';

class AllTransactionsBottomSheet extends StatefulWidget {
  final AppDatabase db;
  final int selectedAccountId;
  final Map<int, Category> categoriesById;
  final Currency currentCurrency;
  final bool isShowingDescription;
  final Function(Transaction, Currency) showTransactionDetails;

  const AllTransactionsBottomSheet({
    super.key,
    required this.db,
    required this.selectedAccountId,
    required this.categoriesById,
    required this.currentCurrency,
    required this.isShowingDescription,
    required this.showTransactionDetails,
  });
  @override
  State<AllTransactionsBottomSheet> createState() => _AllTransactionsBottomSheetState();
}

enum _TransactionsListType {
  incomes,
  all,
  expenses,
}

class _AllTransactionsBottomSheetState extends State<AllTransactionsBottomSheet> {
  final TextEditingController searchTransactionController = TextEditingController();
  bool isSearchingTransactions = false;
  String searchQuery = '';

  // filter for income, all and expense transactions
  _TransactionsListType _currentTransactionsListType = _TransactionsListType.all; // income, all, expense

  // filter transactions by income, expense or all transactions
  List<Transaction> _filterTransactions(List<Transaction> items) {
    final filteredItems = switch (_currentTransactionsListType) {
      _TransactionsListType.incomes => items.where((t) => t.amount > 0),
      _TransactionsListType.all => items,
      _TransactionsListType.expenses => items.where((t) => t.amount < 0),
    }.toList();
    return filteredItems;
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          children: [
            isSearchingTransactions
            // header with searching field
            ? CustomHeader(
              children: [
                // search text field
                Expanded(
                  child: CustomTextField(
                    controller: searchTransactionController, 
                    maxLines: 1,
                    isDense: true,
                    prefixIcon: const CustomIcon(icon: Icons.search_outlined),
                    hintText: 'Search transactions...',
                    onChanged: (String query) {
                      setState(() {
                        searchQuery = query.trim();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // switch to default header icon button
                CustomIconButton(
                  onPressed: () {
                    setState(() {
                      isSearchingTransactions = !isSearchingTransactions;
                      searchTransactionController.clear();
                      searchQuery = '';
                    });
                  }, 
                  icon: const Icon(Icons.close_outlined)
                ),
              ]
            )
            // default header when user is not searching transactions
            : CustomHeader(
              children: [
                CustomIconButton(
                  onPressed: () => Navigator.pop(context), 
                  icon: Icon(Icons.close_outlined, color: Theme.of(context).colorScheme.onPrimary)
                ),
                const CustomHeaderTitle(title: 'All Transactions'),
                CustomIconButton(
                  onPressed: () {
                    setState(() {
                      isSearchingTransactions = !isSearchingTransactions;
                    });
                  }, 
                  icon: Icon(Icons.search_outlined, color: Theme.of(context).colorScheme.onPrimary)
                ),
              ]
            ),
            // incomes, all, expenses textbuttons
            Container(
              padding: const EdgeInsets.all(3),
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child:Row(
                children: _TransactionsListType.values.map((type) {
                  final label = switch (type) {
                    _TransactionsListType.incomes => 'Incomes',
                    _TransactionsListType.all => 'All',
                    _TransactionsListType.expenses => 'Expenses',
                  };
                  final isSelected = _currentTransactionsListType == type;
                  return Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: isSelected
                        ? Colors.blue
                        : Theme.of(context).colorScheme.primaryContainer,
                      ),
                      onPressed: () {
                        setState(() {
                          _currentTransactionsListType = type;
                        });
                      }, 
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.onPrimary
                        ),
                      )
                    ),
                  );
                }).toList(),
              ),
            ),
            // transactions list
            Expanded(
              child: isSearchingTransactions 
              // search transactions
              ? StreamBuilder(
                stream: widget.db.transactionsDao.searchTransactions(
                  query: searchQuery, 
                  accountOwnerId: widget.selectedAccountId
                ),
                builder: (context, snapshot) {
                  final items = snapshot.data ?? [];
                  final filteredItems = _filterTransactions(items);
                  return items.isEmpty
                  ? EmptyListPlaceholder(
                      color: Theme.of(context).colorScheme.surface,
                      icon: Icons.search_off_outlined, 
                      title: 'No results found', 
                      subtitle: 'Try to search by category or amount'
                    )
                  : buildTransactionList(
                    context: context, 
                    tileColor: Theme.of(context).colorScheme.surface,
                    shrinkWrap: false,
                    items: filteredItems, 
                    categoriesById: widget.categoriesById,
                    currentCurrency: widget.currentCurrency, 
                    showTransactionDetails: widget.showTransactionDetails,
                    shouldInsertDate: true,
                    showDescription: widget.isShowingDescription,
                  );
                }
              )
              // all transactions
              : StreamBuilder(
                stream: widget.db.transactionsDao.watchAllTransactionItems(widget.selectedAccountId), 
                builder: (context, snapshot) {
                  final items = snapshot.data ?? [];
                  final filteredItems = _filterTransactions(items);
                  return filteredItems.isEmpty
                  ? EmptyListPlaceholder(
                      color: Theme.of(context).colorScheme.surface,
                      icon: Icons.close_rounded, 
                      title: 'No transactions yet', 
                      subtitle: 'Add transactions and they will appear here'
                    )
                  : buildTransactionList(
                    context: context, 
                    tileColor: Theme.of(context).colorScheme.surface,
                    shrinkWrap: false,
                    items: filteredItems, 
                    categoriesById: widget.categoriesById,
                    currentCurrency: widget.currentCurrency, 
                    showTransactionDetails: widget.showTransactionDetails,
                    shouldInsertDate: true,
                    showDescription: widget.isShowingDescription,
                  );
                }
              ),
            ),
          ],
        );
      },
    );
  }
}
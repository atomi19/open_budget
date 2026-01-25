// contains all the content of home page
import 'package:flutter/material.dart';
import 'package:open_budget/logic/app_settings.dart';
import 'package:open_budget/logic/currencies.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/widgets/build_transactions_list.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/custom_modal_bottom_sheet.dart';
import 'package:open_budget/widgets/custom_text_field.dart';
import 'package:open_budget/widgets/empty_list_placeholder.dart';
import 'package:open_budget/widgets/show_snack_bar.dart';

enum _TransactionsListType {
  incomes,
  all,
  expenses,
}

class HomePageContent extends StatefulWidget {
  final AppDatabase db;

  const HomePageContent({
    super.key,
    required this.db,
  });
  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  // settings
  Currency _currentCurrency = Currency.currencies.first;
  bool _isShowingDescription = false;

  // filter for income, all and expense transactions
  _TransactionsListType _currentTransactionsListType = _TransactionsListType.all; // income, all, expense

  // store categories locally 
  // sort them by id 
  // category is the value
  Map<int, Category> _categoriesById = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadCurrency();
    _loadDescriptionState();
  }

  // load currency from shared_preferences
  Future<void> _loadCurrency() async {
    _currentCurrency = await AppSettings.getSelectedCurrency() ?? Currency.currencies.first;
  }

  // load description preview state from shared_preferences
  Future<void> _loadDescriptionState() async {
    _isShowingDescription = await AppSettings.getTransactionDescriptionState() ?? false;
  }

  // load and keep categories locally
  // e.g. to get category name 
  Future<void> _loadCategories() async {
    widget.db.watchCategories().listen((categories) {
      setState(() {
        _categoriesById= {for (var c in categories) c.id : c};
      });
    });
  }

  // filter transactions by income, expense or all transactions
  List<Transaction> _filterTransactions(List<Transaction> items) {
    final filteredItems = switch (_currentTransactionsListType) {
      _TransactionsListType.incomes => items.where((t) => t.amount > 0),
      _TransactionsListType.all => items,
      _TransactionsListType.expenses => items.where((t) => t.amount < 0),
    }.toList();
    return filteredItems;
  }

  // all transactions modalBottomSheet
  void _showAllTransactions() {
    final TextEditingController searchTransactionController = TextEditingController();
    bool isSearchingTransactions = false;
    String searchQuery = '';
    _currentTransactionsListType = _TransactionsListType.all; // show all transactions

    showCustomModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      backgroundColor: Colors.white,
      borderRadius: 0,
      padding: 0,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsetsGeometry.all(10),
                child: isSearchingTransactions
                // header with searching field
                ? Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: searchTransactionController, 
                        maxLines: 1,
                        isDense: true,
                        backgroundColor: Colors.grey.shade200,
                        prefixIcon: const Icon(Icons.search_outlined),
                        hintText: 'Search transactions...',
                        onChanged: (String query) {
                          setState(() {
                            searchQuery = query.trim();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                      ),
                      onPressed: () {
                        setState(() {
                          isSearchingTransactions = !isSearchingTransactions;
                          searchTransactionController.clear();
                          searchQuery = '';
                        });
                      }, 
                      icon: const Icon(Icons.close_outlined)
                    ),
                  ],
                )
                // default header when user is not searching transactions
                : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      color: Colors.blue,
                      onPressed: () => Navigator.pop(context), 
                      icon: const Icon(Icons.close_outlined)
                    ),
                    const Text(
                      'All Transactions',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      color: Colors.blue,
                      onPressed: () {
                        setState(() {
                          isSearchingTransactions = !isSearchingTransactions;
                        });
                      }, 
                      icon: const Icon(Icons.search_outlined)
                    ),
                  ],
                ),
              ),
              // incomes, all, expenses textbuttons
              Container(
                padding: const EdgeInsets.all(3),
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey.shade200,
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
                          : Colors.grey.shade200,
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
                              ? Colors.white
                              : Colors.black
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
                  stream: widget.db.searchTransactions(searchQuery), 
                  builder: (context, snapshot) {
                    final items = snapshot.data ?? [];
                    final filteredItems = _filterTransactions(items);
                    return items.isEmpty
                    ? const EmptyListPlaceholder(
                        icon: Icons.search_off_outlined, 
                        title: 'No results found', 
                        subtitle: 'Try to search by category or amount'
                      )
                    : buildTransactionList(
                      context: context, 
                      shrinkWrap: false,
                      items: filteredItems, 
                      categoriesById: _categoriesById,
                      currentCurrency: _currentCurrency, 
                      showTransactionDetails: _showTransactionDetails,
                      shouldInsertDate: true,
                      showDescription: _isShowingDescription,
                    );
                  }
                )
                // all transactions
                : StreamBuilder(
                  stream: widget.db.watchAllTransactionItems(), 
                  builder: (context, snapshot) {
                    final items = snapshot.data ?? [];
                    final filteredItems = _filterTransactions(items);
                    return filteredItems.isEmpty
                    ? const EmptyListPlaceholder(
                        icon: Icons.close_rounded, 
                        title: 'No transactions yet', 
                        subtitle: 'Add transactions and they will appear here'
                      )
                    : buildTransactionList(
                      context: context, 
                      shrinkWrap: false,
                      items: filteredItems, 
                      categoriesById: _categoriesById,
                      currentCurrency: _currentCurrency, 
                      showTransactionDetails: _showTransactionDetails,
                      shouldInsertDate: true,
                      showDescription: _isShowingDescription,
                    );
                  }
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // transaction details modalBottomSheet
  void _showTransactionDetails(Transaction item) {
    final TextEditingController transactionDescriptionController = TextEditingController();
    transactionDescriptionController.text = item.description;

    showCustomModalBottomSheet(
      context: context, 
      child: Wrap(
        runSpacing: 10,
        children: [
          // header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // close
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close)
              ),
              const Text(
                'Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // delete transaction
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white
                ),
                onPressed: () {
                  _showDeleteConfirmation(item.id);
                }, 
                icon: const Icon(Icons.delete_outlined)
              ),
            ],
          ),
          // transaction itself
          Align(
            alignment: Alignment.center,
            child: Text(
              item.amount % 1 == 0
                ? '${item.amount.toInt().toString()} ${_currentCurrency.symbol}'
                : '${item.amount.toString()} ${_currentCurrency.symbol}', 
              style: TextStyle(
                fontSize: 40, 
                fontWeight: FontWeight.bold,
                color: item.amount > 0
                  ? Colors.green
                  : Colors.black,
              )),
          ),
          // date and time in dd-mm-yyyy hh:mm format
          CustomListTile(
            title: 'Date',
            trailing: Text(
              '${item.dateAndTime.day.toString().padLeft(2, '0')}-${item.dateAndTime.month.toString().padLeft(2, '0')}-${item.dateAndTime.year} ${item.dateAndTime.hour.toString().padLeft(2, '0')}:${item.dateAndTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 15),
            ),
          ),
          // category
          CustomListTile(
            title: 'Category', 
            trailing: Text(
              _categoriesById[item.categoryId]?.name ?? 'Unknown Category',
              style: const TextStyle(fontSize: 15),
            ),
          ),
          // description inside transaction details
          // if user changed description it will update
          // when focus on CustomTextField is lost
          Focus(
            onFocusChange: (focus) {
              if(!focus) {
                widget.db.updateDescription(item.id, transactionDescriptionController.text);
              }
            },
            child: CustomTextField(
              controller: transactionDescriptionController, 
              hintText: 'Enter description...',
              minLines: 5,
              maxLines: 5,
            ),
          ),
        ],
      )
    );
  }

  // delete transaction confirmation AlertDialog
  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(15),

                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                  ),
                  onPressed: () => Navigator.pop(context), 
                  child: const Text('Cancel', style: TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.red.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context); // close alertDialog
                    Navigator.pop(context); // close transaction details modalBottomSheet
                    bool shouldDelete = true;

                    showSnackBar(
                      context: context, 
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Transaction deleted'),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () {
                              shouldDelete = false;
                              messenger.hideCurrentSnackBar();
                            },
                            child: const Text('Undo', style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                      onClosed: () {
                        if(shouldDelete) {
                          widget.db.deleteTransaction(id);
                        }
                      }
                    );
                  }, 
                  child: const Text('Delete', style: TextStyle(fontSize: 15, color: Colors.white)),
                ),
              )
            ],
          )
        ],
      )
    );
  }

  // settings modalBottomSheet
  void _showSettings() {
    showCustomModalBottomSheet(
      context: context, 
      child: StatefulBuilder(
        builder: (context, StateSetter modalSetState) {
          return Wrap(
            runSpacing: 10,
            children: [
              // header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)
                  ),
                  const Text(
                    'Settings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Column(
                children: [
                  CustomListTile(
                    title: 'Show transaction description',             
                    trailing: Switch(
                      value: _isShowingDescription, 
                      activeThumbColor: Colors.white,
                      inactiveThumbColor: Colors.grey.shade200,
                      activeTrackColor: Colors.blue,
                      inactiveTrackColor: Colors.grey.shade500,
                      trackOutlineColor: WidgetStateProperty.resolveWith(
                        (Set<WidgetState> states) {
                          return Colors.transparent;
                        }
                      ),
                      onChanged: (bool value) {
                        setState(() {
                          setState(() {
                            _isShowingDescription = value;
                          });
                          modalSetState(() {
                            _isShowingDescription = value;
                          });
                          AppSettings.switchTransactionDescription(value);
                          _loadDescriptionState();
                        });
                      }
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                      child: Text('Display the description below each transaction', style: TextStyle(fontSize: 13),),
                    ),
                  )
                ],
              ),
              // currency expansion tile setting
              ExpansionTile(
                backgroundColor: Colors.white,
                collapsedBackgroundColor: Colors.white,
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: const Text('Currency'),
                trailing: const Icon(Icons.arrow_drop_down_rounded),
                children: [
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      itemCount: Currency.currencies.length,
                      itemBuilder: (context, index) {
                        final currencyItem = Currency.currencies[index]; 
                        return CustomListTile(
                          title: currencyItem.name, 
                          trailing: Text(
                            currencyItem.code,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {                              
                              AppSettings.setCurrency(currencyItem.code); // save selected currency
                              _loadCurrency(); // load selected currency
                            });
                          }
                        );
                      }
                    ),
                  )
                ]
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 10,
        children: [
          // header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48),
              IconButton(
                onPressed: () => _showSettings(), 
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                icon: const Icon(Icons.settings_outlined)
              ),
            ],
          ),
          // total balance
          StreamBuilder(
            stream: widget.db.watchTotalBalance(), 
            builder: (context, snapshot) {
              final totalBalance = snapshot.data ?? 0;
              return Container(
                alignment: Alignment.center,
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Text(
                  '${totalBalance.toString()} ${_currentCurrency.symbol}', 
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              );
            }
          ),
          // last 3 transactions
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            )
          ),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                StreamBuilder(
                  stream: widget.db.watchAllTransactionItems(),
                  builder: (context, snapshot) {
                    final items = snapshot.data ?? [];
                    final lastThreeItems = items.take(3).toList();
                    return items.isNotEmpty
                    ? buildTransactionList(
                      context: context, 
                      shrinkWrap: true,
                      items: lastThreeItems, 
                      categoriesById: _categoriesById,
                      currentCurrency: _currentCurrency, 
                      showTransactionDetails: _showTransactionDetails,
                      shouldInsertDate: false,
                      showDescription: _isShowingDescription,
                    )
                    : const Padding(
                      padding: EdgeInsets.all(10),
                      child: EmptyListPlaceholder(
                        icon: Icons.close_rounded, 
                        title: 'No transactions yet', 
                        subtitle: 'Add transactions and they will appear here'
                      )
                    );
                  }
                ),
                CustomListTile(
                  title: 'All Transactions',
                  trailing: const Icon(Icons.arrow_right_rounded),
                  onTap: () => _showAllTransactions(),
                ),
              ],
            )
          ),
        ],
      )
    );
  }
}
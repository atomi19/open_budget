// contains all the content of home page
import 'package:flutter/material.dart';
import 'package:open_budget/logic/app_settings.dart';
import 'package:open_budget/logic/currencies.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/widgets/build_transactions_list.dart';
import 'package:open_budget/widgets/custom_text_field.dart';


class HomePageContent extends StatefulWidget {
  final TransactionsDatabase db;

  const HomePageContent({
    super.key,
    required this.db,
  });
  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final TextEditingController _transactionDescriptionController = TextEditingController();
  Currency _currentCurrency = Currency.currencies.first;

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  // load currency from shared_preferences
  Future<void> _loadCurrency() async {
    _currentCurrency = await AppSettings.getSelectedCurrency() ?? Currency.currencies.first;
  }

  // all transactions modalBottomSheet
  void _showAllTransactions() {
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      shape:const RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(0))
      ),
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsetsGeometry.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)
                  ),
                  const Text(
                    'All Transactions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // all transactions
            Expanded(
              child: StreamBuilder(
                stream: widget.db.watchAllTransactionItems(), 
                builder: (context, snapshot) {
                  final items = snapshot.data ?? [];
                  return items.isEmpty
                  ? const Center(child: Text('No Transactions Found'))
                  : buildTransactionList(
                    context: context, 
                    shrinkWrap: false,
                    items: items, 
                    currentCurrency: _currentCurrency, 
                    showTransactionDetails: _showTransactionDetails
                  );
                }
              )
            )
          ],
        );
      }
    );
  }

  // transaction details modalBottomSheet
  void _showTransactionDetails(Transaction item) {
    _transactionDescriptionController.text = item.description;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(15))
      ),
      backgroundColor: Colors.grey.shade200,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Wrap(
            runSpacing: 10,
            children: [
              // header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // close showModalBottomSheet
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)
                  ),
                  const Text(
                    'Transaction Details',
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
                child: Text('${item.amount.toString()} ${_currentCurrency.symbol}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              ),
              // date and time in dd-mm-yyyy hh:mm format
              ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
                ),
                title: const Text('Date'),
                trailing: Text(
                  '${item.dateAndTime.day.toString().padLeft(2, '0')}-${item.dateAndTime.month.toString().padLeft(2, '0')}-${item.dateAndTime.year} ${item.dateAndTime.hour.toString().padLeft(2, '0')}:${item.dateAndTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              // category  
              ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
                ),
                title: const Text('Category'),
                trailing: Text(
                  item.category,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              // description inside transaction details
              // if user changed description it will update
              // when focus on CustomTextField is lost
              Focus(
                onFocusChange: (focus) {
                  if(!focus) {
                    widget.db.updateDescription(item.id, _transactionDescriptionController.text);
                  }
                },
                child: CustomTextField(
                  controller: _transactionDescriptionController, 
                  hintText: 'Enter description...',
                  minLines: 5,
                  maxLines: 5,
                ),
              ),
            ],
          )
        );
      }
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
            Navigator.pop(context); // close alertDialog
            Navigator.pop(context); // close transaction details modalBottomSheet
            widget.db.deleteTransaction(id);
          }, 
          child: const Text('Delete')),
        ],
      )
    );
  }

  // settings modalBottomSheet
  void _showSettings() {
    showModalBottomSheet(
      context: context, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(15))
      ),
      backgroundColor: Colors.grey.shade200,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Wrap(
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
                        return ListTile(
                          title: Text(currencyItem.name),
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
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('History', style: TextStyle(fontSize: 14)),
                  TextButton(
                    onPressed: () => _showAllTransactions(),
                    child: const Row(
                      children: [
                        Text('All'),
                        Icon(Icons.arrow_right),
                      ],
                    )
                  )
                ],
              ),
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
                    currentCurrency: _currentCurrency, 
                    showTransactionDetails: 
                    _showTransactionDetails
                  )
                  : const Text('No Transactions Found');
                }
              )
            ],
          )
        ),
      ],
    );
  }
}
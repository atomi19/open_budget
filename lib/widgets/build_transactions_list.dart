// used inside home_page_content to build the ListView.builder 
// with transactions (as for now all transactions and last 3 transactions)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_budget/logic/currencies.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/models/app_platform.dart';
import 'package:open_budget/ui/transactions/duplicate_transaction_bottom_sheet.dart';
import 'package:open_budget/widgets/custom_alert_dialog.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/custom_modal_bottom_sheet.dart';
import 'package:open_budget/widgets/show_snack_bar.dart';

class TransactionsList extends StatelessWidget {
  final AppDatabase db;
  final bool shrinkWrap;
  final List<Transaction> items;
  final Map<int, Category> categoriesById;
  final Currency currentCurrency;
  final bool shouldInsertDate;
  final bool showDescription;
  final EdgeInsetsGeometry contentPadding;
  final double? listPadding;
  final ScrollPhysics? scrollPhysics;

  final Function(Transaction, Currency) showTransactionDetails;

  const TransactionsList({
    super.key,
    required this.db,
    required this.shrinkWrap,
    required this.items,
    required this.categoriesById,
    required this.currentCurrency,
    required this.shouldInsertDate,
    required this.showDescription,
    this.scrollPhysics,
    required this.contentPadding,
    this.listPadding,
    required this.showTransactionDetails,
  });

  static const List<String> _months = [
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

  // context menu (desktop only)
  void _showContextMenuOnSecondaryTap({
    required BuildContext context,
    required AppDatabase db,
    required Transaction item,
    required bool isIncome,
    required TapDownDetails tapDetails,
  }) async {
    await showMenu(
      context: context, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      menuPadding: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.primaryContainer,
      clipBehavior: Clip.antiAlias,
      position: RelativeRect.fromLTRB(
        tapDetails.globalPosition.dx, 
        tapDetails.globalPosition.dy, 
        tapDetails.globalPosition.dx, 
        tapDetails.globalPosition.dy
      ),
      items: [
        // duplicate 
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            leading: const CustomIcon(icon: Icons.control_point_duplicate),
            title: const Text('Duplicate'),
            onTap: () {
              Navigator.pop(context);
              showCustomModalBottomSheet(
                context: context, 
                backgroundColor: Theme.of(context).colorScheme.surface,
                isScrollControlled: true,
                borderRadius: 0,
                child: DuplicateTransactionBottomSheet(
                  db: db,
                  transaction: item,
                  isIncome: isIncome,
                ),
              );
            }
          )
        ),
        // delete
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteAlertDialog(
                context: context, 
                db: db, 
                item: item,
              );
            }
          )
        ),
      ]
    );
  }

  void _showDeleteAlertDialog({
    required BuildContext context,
    required AppDatabase db,
    required Transaction item,
  }) {
    showDialog(
      context: context, 
      builder: (context) => CustomAlertDialog(
        title: 'Delete transaction?', 
        content: 'Are you sure you want to delete this transaction?', 
        leftButtonLabel: 'Cancel', 
        rightButtonLabel: 'Delete', 
        leftButtonAction: () => Navigator.pop(context, false),
        rightButtonAction: ()  {
          final messenger = ScaffoldMessenger.of(context);
          Navigator.of(context).popUntil((route) => route.isFirst);

          final deletedTransaction = item;
          db.transactionsDao.deleteTransaction(deletedTransaction.id);

          showSnackBar(
            context: context, 
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction deleted',
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                  onPressed: () {
                    // date and time
                    final DateTime dateAndTime = deletedTransaction.dateAndTime;

                    // date
                    final DateTime date = DateTime(
                      dateAndTime.year,
                      dateAndTime.month,
                      dateAndTime.day,
                    );

                    // time
                    final TimeOfDay time = TimeOfDay.fromDateTime(dateAndTime);

                    db.transactionsDao.addTransaction(
                      amount: deletedTransaction.amount, 
                      description: deletedTransaction.description, 
                      accountOwnerId: deletedTransaction.accountOwnerId,
                      categoryId: deletedTransaction.categoryId, 
                      date: date, 
                      time: time
                    );

                    messenger.hideCurrentSnackBar();
                  },
                  child: Text('Undo', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                ),
              ],
            ),
          );
        }
      )
    );
  }

  // transaction tile
  Widget _buildTransactionTile({
    required BuildContext context,
    required bool isTransfer,
    required Transaction item,
    required Map<int, Category> categoriesById,
    required Currency currentCurrency,
    required bool showDescription,
    required String? iconNameKey,
    required bool isFirstInCurrentDate,
    required bool isLastInCurrentDate,
    required Function(Transaction, Currency) showTransactionDetails,
  }) {
    final category = categoriesById[item.categoryId];
    final String? iconNameKey = category?.iconName;

    return CustomListTile(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isFirstInCurrentDate ? 15 : 0),
          bottom: Radius.circular(isLastInCurrentDate ? 15 : 0),
        )
      ),
      contentPadding: contentPadding,
      tileColor: Theme.of(context).colorScheme.primaryContainer,
      // category icon or transfer icon
      leading: isTransfer
        ? const CustomIcon(icon: Icons.swap_horiz)
        : CustomIcon(icon: IconsManager.getCategoryIconByName(iconNameKey)),
      // category name or transfer title based on transactionType
      // 0 - income, 1 - expense, 2 - transfer
      title: isTransfer
        ? item.amount < 0
          ? 'Transfer to account'
          : 'Transfer from account'
        : category?.name ?? 'Unknown Category',
      // description
      subtitle: showDescription
      ? item.description.trim().isNotEmpty
        ? Text(
          item.description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
        )
        : null
      : null,
      // transaction amount
      trailing: Text(
        item.amount % 1 == 0
        ? '${item.amount.toInt().toString()} ${currentCurrency.symbol}'
        : '${item.amount.toString()} ${currentCurrency.symbol}',
        style: TextStyle(
          color: item.amount > 0
          ? Colors.green
          : Theme.of(context).colorScheme.onPrimary,
          fontSize: 15
        ),
      ),
      onTap: () => showTransactionDetails(item, currentCurrency),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: shrinkWrap,
      itemCount: items.length,
      physics: scrollPhysics,
      padding: EdgeInsets.symmetric(horizontal: listPadding ?? 0),
      itemBuilder: (context, index) {
        bool showDate = false;
        final item = items[index];
        final previousItem = index > 0 ? items[index-1] : null;
        final nextItem = index < items.length - 1 ? items[index+1] : null;
        final category = categoriesById[item.categoryId];
        final iconNameKey = category?.iconName;
        bool isFirstInCurrentDate = true;
        bool isLastInCurrentDate = false;

        bool isTransfer = item.transactionType == 2;
        bool isIncome = item.transactionType == 0;

        bool isHapticTrigerred = false;

        // check if this is required to insert date (each day) between transactions
        if(shouldInsertDate) {
          final currentDate = DateTime(
            item.dateAndTime.year,
            item.dateAndTime.month,
            item.dateAndTime.day,
          );

          final previousDate = previousItem == null
            ? null
            : DateTime(
              previousItem.dateAndTime.year,
              previousItem.dateAndTime.month,
              previousItem.dateAndTime.day,
            );

          final nextDate = nextItem == null
            ? null
            : DateTime(
              nextItem.dateAndTime.year,
              nextItem.dateAndTime.month,
              nextItem.dateAndTime.day,
            );

          isFirstInCurrentDate = previousDate == null || currentDate != previousDate;
          isLastInCurrentDate = nextDate == null || currentDate != nextDate;


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
            // transaction list tile with right click menu on desktop
            if(AppPlatform.isDesktop) 
              GestureDetector(
                onSecondaryTapDown: (details) {
                  if(!isTransfer) {
                    _showContextMenuOnSecondaryTap(
                      context: context, 
                      db: db, 
                      item: item, 
                      isIncome: isIncome, 
                      tapDetails: details,
                    );
                  }
                },
                child: _buildTransactionTile(
                  context: context, 
                  isTransfer: isTransfer, 
                  item: item, 
                  categoriesById: categoriesById, 
                  currentCurrency: currentCurrency, 
                  showDescription: showDescription, 
                  isFirstInCurrentDate: isFirstInCurrentDate,
                  isLastInCurrentDate: isLastInCurrentDate,
                  iconNameKey: iconNameKey, 
                  showTransactionDetails: showTransactionDetails
                ),
              ),
            // transaction dismissible list tile on mobile
            if(AppPlatform.isMobile)
              Dismissible(
                key: ValueKey(item.id), 
                direction: isTransfer
                  ? DismissDirection.none
                  : DismissDirection.horizontal,
                background: Container(
                  alignment: Alignment.centerLeft,
                  color: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.control_point_duplicate, color: Colors.white,),
                ),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_outline, color: Colors.white,),
                ),
                onUpdate: (details) {
                  // light impact on list tile drag
                  if(!isHapticTrigerred && details.progress > 0) {
                    HapticFeedback.lightImpact();
                    isHapticTrigerred = true;
                  }

                  if(details.progress == 0) {
                    isHapticTrigerred = false;
                  }
                },
                confirmDismiss: (direction) async {
                  if(direction == DismissDirection.endToStart) {
                    // delete logic
                    _showDeleteAlertDialog(
                      context: context, 
                      db: db, 
                      item: item
                    );
                  } else {
                    // duplicate logic
                    showCustomModalBottomSheet(
                      context: context, 
                      isScrollControlled: true,
                      borderRadius: 0,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: DuplicateTransactionBottomSheet(
                        db: db,
                        transaction: item,
                        isIncome: isIncome,
                      ),
                    );
                  }
                  return false;
                },
                child: _buildTransactionTile(
                  context: context,
                  isTransfer: isTransfer, 
                  item: item, 
                  categoriesById: categoriesById, 
                  currentCurrency: currentCurrency, 
                  showDescription: showDescription, 
                  isFirstInCurrentDate: isFirstInCurrentDate,
                  isLastInCurrentDate: isLastInCurrentDate,
                  iconNameKey: iconNameKey, 
                  showTransactionDetails: showTransactionDetails
                ),
              ),
          ]
        );
      }
    );
  }
}
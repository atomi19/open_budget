import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/widgets/custom_alert_dialog.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/empty_list_placeholder.dart';

class AccountsBottomSheet extends StatelessWidget {
  final BuildContext context;
  final AppDatabase db;
  final VoidCallback showAccountCreateSheet;
  final Function(Account account) showAccountEditSheet;

  const AccountsBottomSheet({
    super.key,
    required this.context,
    required this.db,
    required this.showAccountCreateSheet,
    required this.showAccountEditSheet,
  });

  void _showAccountDeletePrompt(int id) {
    showDialog(
      context: context, 
      builder: (context) => CustomAlertDialog(
        title: 'Delet`e account?', 
        content: 'This will permanently delete your account and all associated transactions.', 
        leftButtonLabel: 'Cancel', 
        rightButtonLabel: 'Delete', 
        leftButtonAction: () => Navigator.pop(context), 
        rightButtonAction: () {
          HapticFeedback.heavyImpact();
          db.transactionsDao.deleteAllTransactionsByAccountOwnerId(id);
          db.accountsDao.deleteAccount(id);
          Navigator.pop(context);
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // header
        CustomHeader(
          children: [
            CustomIconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close)
            ), 
            const CustomHeaderTitle(title: 'Accounts'),
            CustomIconButton(
              onPressed: showAccountCreateSheet,
              icon: const Icon(Icons.add)
            ), 
          ],
        ),
        // accounts list
        Expanded(
          child: StreamBuilder(
            stream: db.accountsDao.watchAccounts(),
            builder: (context, snapshot) {
              final items =snapshot.data ?? [];
              return items.isEmpty
              ? EmptyListPlaceholder(
                  color: Theme.of(context).colorScheme.surface,
                  icon: Icons.close_rounded, 
                  title: 'No accounts yet', 
                  subtitle: 'Create account first'
              )
              : ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 5),
                padding:const EdgeInsets.symmetric(horizontal: 15),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return CustomListTile(
                    tileColor: Theme.of(context).colorScheme.primaryContainer, 
                    leading: CustomIcon(icon: IconsManager.getAccountIconByName(item.icon)),
                    title: item.name,
                    trailing: IconButton(
                      onPressed: () => _showAccountDeletePrompt(item.id), 
                      icon: const Icon(Icons.delete_outlined)
                    ),
                    onTap: () => showAccountEditSheet(item),
                  );
                }
              );
            }
          ),
        )
      ],
    );
  }
}
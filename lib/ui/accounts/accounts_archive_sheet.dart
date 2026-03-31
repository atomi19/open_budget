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

class AccountsArchiveSheet extends StatelessWidget {
  final BuildContext context;
  final AppDatabase db;

  const AccountsArchiveSheet({
    super.key,
    required this.context,
    required this.db,
  });

  // delete account prompt
  void _showAccountDeletePrompt(int id) {
    showDialog(
      context: context, 
      builder: (context) => CustomAlertDialog(
        title: 'Delete account?', 
        content: 'This will permanently delete your account and all associated transactions.', 
        leftButtonLabel: 'Cancel', 
        rightButtonLabel: 'Delete', 
        leftButtonAction: () => Navigator.pop(context), 
        rightButtonAction: () {
          HapticFeedback.heavyImpact();
          // delete all transactions under this account
          db.transactionsDao.deleteAllTransactionsByAccountOwnerId(id);
          // delete account
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
            // close button
            CustomIconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close)
            ), 
            const CustomHeaderTitle(title: 'Archived Accounts'),
            // more pop up menu button
            const SizedBox(width: 48),
          ],
        ),
        // accounts list
        Expanded(
          child: StreamBuilder(
            // list unarchived accounts
            stream: db.accountsDao.watchAccounts(true),
            builder: (context, snapshot) {
              final items =snapshot.data ?? [];
              return items.isEmpty
              ? EmptyListPlaceholder(
                  color: Theme.of(context).colorScheme.surface,
                  icon: Icons.close_rounded, 
                  title: 'No archived accounts', 
                  subtitle: 'Archive accounts and they will appear here'
              )
              : ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 5),
                padding:const EdgeInsets.symmetric(horizontal: 15),
                itemBuilder: (context, index) {
                  final item = items[index];

                  // account list tile
                  return CustomListTile(
                    tileColor: Theme.of(context).colorScheme.primaryContainer, 
                    // account icon 
                    leading: CustomIcon(icon: IconsManager.getAccountIconByName(item.icon)),
                    title: item.name,
                    // unarchive icon button 
                    trailing: PopupMenuButton(
                      menuPadding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_vert_outlined),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)
                      ),
                      clipBehavior: Clip.antiAlias,
                      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                        // add account 
                        PopupMenuItem(
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            leading: const CustomIcon(icon: Icons.unarchive_outlined),
                            title: const Text('Unarchive'),
                            onTap: () {
                              Navigator.pop(context);
                              db.accountsDao.updateAccountArchiveStatus(item.id, false);
                            }
                          )
                        ),
                        // archived accounts 
                        PopupMenuItem(
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding:const EdgeInsets.symmetric(horizontal: 10),
                            leading: const Icon(Icons.delete_outlined, color: Colors.red,),
                            title: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _showAccountDeletePrompt(item.id);
                            },
                          )
                        ),
                      ]
                    ),
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
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
  final VoidCallback showAccountsArchiveSheet;

  const AccountsBottomSheet({
    super.key,
    required this.context,
    required this.db,
    required this.showAccountCreateSheet,
    required this.showAccountEditSheet,
    required this.showAccountsArchiveSheet,
  });

  // archive account prompt
  void _showAccountArchivePrompt(int id) {
    showDialog(
      context: context, 
      builder: (context) => CustomAlertDialog(
        title: 'Achive account?', 
        content: 'This will achive your account, you will be able to restore it.', 
        leftButtonLabel: 'Cancel', 
        rightButtonLabel: 'Archive', 
        leftButtonAction: () => Navigator.pop(context), 
        rightButtonAction: () {
          HapticFeedback.heavyImpact();
          // archive account
          db.accountsDao.updateAccountArchiveStatus(id, true);
          Navigator.pop(context);
        }
      ),
    ); 
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // header
        CustomHeader(
          children: [
            // close button
            CustomIconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close)
            ), 
            const CustomHeaderTitle(title: 'Accounts'),
            // more pop up menu button
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle
              ),
              child: PopupMenuButton(
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
                      leading: const CustomIcon(icon: Icons.add_outlined),
                      title: const Text('Add Account'),
                      onTap: () {
                        Navigator.pop(context);
                        showAccountCreateSheet();
                      }
                    )
                  ),
                  // archived accounts 
                  PopupMenuItem(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding:const EdgeInsets.symmetric(horizontal: 10),
                      leading: const CustomIcon(icon: Icons.archive_outlined),
                      title: const Text('Archived Accounts'),
                      onTap: () {
                        Navigator.pop(context);
                        showAccountsArchiveSheet();
                      },
                    )
                  ),
                ]
              ),
            )
          ],
        ),
        // accounts list
        Expanded(
          child: StreamBuilder(
            // list unarchived accounts
            stream: db.accountsDao.watchAccounts(false),
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

                  // account list tile
                  return CustomListTile(
                    tileColor: Theme.of(context).colorScheme.primaryContainer, 
                    // account icon 
                    leading: CustomIcon(icon: IconsManager.getAccountIconByName(item.icon)),
                    title: item.name,
                    subtitle: Text(
                      item.currency,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    // archive icon button 
                    trailing: IconButton(
                      onPressed: () => _showAccountArchivePrompt(item.id),
                      icon: const Icon(Icons.archive_outlined)
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
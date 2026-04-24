import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/empty_list_placeholder.dart';

class AccountTransferBottomSheet extends StatelessWidget {
  final AppDatabase db;
  final Function(Account acount) onAccountTap;

  const AccountTransferBottomSheet({
    super.key,
    required this.db,
    required this.onAccountTap,
  });

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
            const CustomHeaderTitle(title: 'Choose an account'),
            const SizedBox(width: 48),
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
                  title: 'No accounts found', 
                  subtitle: 'Add accounts and they will appear here'
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
                    onTap: () => onAccountTap(item),
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
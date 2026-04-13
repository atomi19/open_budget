// accounts list on Add Transaction page

import 'package:flutter/material.dart';
import 'package:open_budget/logic/app_settings.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/empty_list_placeholder.dart';

class AccountsListBottomSheet extends StatefulWidget {
  final AppDatabase db;
  final Function(Account) onTap;
  final Account? favoriteAccount;

  const AccountsListBottomSheet({
    super.key,
    required this.db,
    required this.onTap,
    required this.favoriteAccount,
  });

  @override
  State<AccountsListBottomSheet> createState() => _AccountsListBottomSheetState();
}

class _AccountsListBottomSheetState extends State<AccountsListBottomSheet> {
  Account? _favoriteAccount;

  @override
  void initState() {
    super.initState();
    _favoriteAccount = widget.favoriteAccount;
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
            const CustomHeaderTitle(title: 'Choose an account'),
            const SizedBox(width: 48),
          ],
        ),
        // accounts list
        Expanded(
          child: StreamBuilder(
            stream: widget.db.accountsDao.watchAccounts(false),
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
                      onPressed: () async {
                        await AppSettings.setFavoriteAccount(item.id);
                        setState(() {
                          _favoriteAccount = item;
                        });
                      }, 
                      icon: Icon((_favoriteAccount?.id == item.id) ? Icons.star : Icons.star_outline)
                    ),
                    onTap: () => widget.onTap(item),
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
import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';

class AccountChooseBottomSheet extends StatelessWidget {
  final PageController pageViewController;
  final List<Account> allAccounts;

  const AccountChooseBottomSheet({
    super.key,
    required this.pageViewController,
    required this.allAccounts,
  });

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
            const CustomHeaderTitle(title: 'Switch Account'),
            const SizedBox(width: 48),
          ],
        ),
        // body
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            separatorBuilder: (context, index) => const SizedBox(height: 5),
            itemCount: allAccounts.length,
            itemBuilder: (context, index) {
              final item = allAccounts[index];
              // account list tile
              return CustomListTile(
                tileColor: Theme.of(context).colorScheme.primaryContainer, 
                leading: CustomIcon(icon: IconsManager.getAccountIconByName(item.icon)),
                title: item.name,
                onTap: () {
                  Navigator.pop(context);
                  pageViewController.animateToPage(
                    index, 
                    duration: const Duration(milliseconds: 300), 
                    curve: Curves.easeOutCubic,
                  );
                },
              );
            }
          ),
        )
      ],
    );
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';

class AccountChooseBottomSheet extends StatefulWidget {
  final AppDatabase db;
  final PageController pageViewController;
  final List<Account> allAccounts;

  const AccountChooseBottomSheet({
    super.key,
    required this.db,
    required this.pageViewController,
    required this.allAccounts,
  });

  @override
  State<AccountChooseBottomSheet> createState() => _AccountChooseBottomSheetState();
}

class _AccountChooseBottomSheetState extends State<AccountChooseBottomSheet> {
  late List<Account> accounts;

  @override
  void initState() {
    super.initState();
    accounts = List.of(widget.allAccounts);
  }
  
  // accounts reorderable list view proxy decorator 
  Widget _proxyDecorator(
    Widget child,
    int index,
    Animation<double> animation,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(1, 6, animValue)!;
        final double scale = lerpDouble(1, 1.02, animValue)!;

        return Transform.scale(
          scale: scale,
          child: Material(
            borderRadius: BorderRadius.circular(15),
            elevation: elevation,
            color: Colors.transparent,
            child: child!
          )
        );
      },
      child: child,
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
            const CustomHeaderTitle(title: 'Switch Account'),
            const SizedBox(width: 48),
          ],
        ),
        // body
        Expanded(
          child: ReorderableListView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            proxyDecorator: _proxyDecorator,
            buildDefaultDragHandles: false,
            children: [
              for(int index = 0; index < accounts.length; index += 1)
                Column(
                  key: ValueKey('${accounts[index].id}'),
                  children: [
                    CustomListTile(
                      tileColor: Theme.of(context).colorScheme.primaryContainer, 
                      // account icon 
                      leading: CustomIcon(icon: IconsManager.getAccountIconByName(accounts[index].icon)),
                      title: accounts[index].name,
                      // drag nadle
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle), 
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        widget.pageViewController.animateToPage(
                          index, 
                          duration: const Duration(milliseconds: 300), 
                          curve: Curves.easeOutCubic,
                        );
                      },
                    ),
                    const SizedBox(height: 5),
                  ],
                )
            ], 
            onReorder: (oldIndex, newIndex) async {
              setState(() {
                if (newIndex > oldIndex) newIndex--;

                final item = accounts.removeAt(oldIndex);
                accounts.insert(newIndex, item);
              });

              // updated sort index of each account
              for (int i = 0; i < accounts.length; i++) {
                await widget.db.accountsDao.updateAccountSortIndex(
                  accounts[i].id,
                  i,
                );
              }
            }
          ),
        )
      ],
    );
  }
}
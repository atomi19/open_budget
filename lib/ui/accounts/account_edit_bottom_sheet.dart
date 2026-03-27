import 'package:flutter/material.dart';
import 'package:open_budget/logic/currencies.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/custom_modal_bottom_sheet.dart';
import 'package:open_budget/widgets/custom_text_field.dart';

class AccountEditBottomSheet extends StatefulWidget {
  final AppDatabase db;
  final Account account;

  const AccountEditBottomSheet({
    super.key,
    required this.db,
    required this.account,
  });

  @override
  State<AccountEditBottomSheet> createState() => _AccountEditBottomSheetState();
}

class _AccountEditBottomSheetState extends State<AccountEditBottomSheet> {
  String? _initialName;
  String? _inititalBalance;
  String? _initialCurrency;
  String? _initialIcon;

  final _nameController = TextEditingController();
  final _initialBalanceController = TextEditingController();
  String? _selectedIcon;
  String? _selectedAccountCreationCurrency;
  
  @override
  initState() {
    super.initState();
    _initialName = widget.account.name;
    _inititalBalance = widget.account.initialBalance.toString();
    _initialCurrency = widget.account.currency;
    _initialIcon = widget.account.icon;

    _nameController.text = _initialName!;
    _initialBalanceController.text = _inititalBalance!;
    _selectedAccountCreationCurrency = _initialCurrency;
    _selectedIcon = _initialIcon;
  }

  void _showCurrenciesSelectionSheet() {
    showCustomModalBottomSheet(
      context: context, 
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // header
          CustomHeader(
            children: [
              CustomIconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close)
              ), 
              const CustomHeaderTitle(title: 'Select Currency'),
              const SizedBox(width: 48),
            ],
          ),
          // content
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: Currency.currencies.length,
              separatorBuilder: (context, index) => const SizedBox(height: 5),
              itemBuilder: (context, index) {
                final item = Currency.currencies[index];

                return CustomListTile(
                  tileColor: Theme.of(context).colorScheme.primaryContainer, 
                  title: item.name,
                  trailing: Text(
                    item.code,
                    style: const TextStyle(fontSize: 15, color: Colors.grey,),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedAccountCreationCurrency = item.code;
                    });
                    Navigator.pop(context);
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  void _handleAccountEdit(int id) {
    final newName = _nameController.text;
    final newInitialBalance = _initialBalanceController.text;
    final newCurrency = _selectedAccountCreationCurrency;
    final newIcon = _selectedIcon;

    if(newName != _initialName) {
      widget.db.accountsDao.updateAccountName(id, newName);
    }

    if(newInitialBalance != _inititalBalance) {
      final parseBalance = double.tryParse(newInitialBalance) ?? 0;
      widget.db.accountsDao.updateAccountInitialBalance(id, parseBalance);
    }

    if(newCurrency != _initialCurrency) {
      widget.db.accountsDao.updateAccountCurrency(id, newCurrency!);
    }

    if(newIcon != _initialIcon) {
      widget.db.accountsDao.updateAccountIcon(id, newIcon!);
    }
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
            const CustomHeaderTitle(title: 'Edit Account'),
            CustomIconButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                _handleAccountEdit(widget.account.id);
                Navigator.pop(context);
              },
              icon: Icon(Icons.done, color: Theme.of(context).colorScheme.secondary,)
            ), 
          ],
        ),
        // body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              spacing: 10,
              children: [
                // account name
                CustomTextField(
                  controller: _nameController, 
                  hintText: 'Account name...'
                ),
                // initial balance
                CustomTextField(
                  controller: _initialBalanceController, 
                  labelText: 'Initial balance',
                  hintText: '',
                ),
                // currency
                CustomListTile(
                  tileColor: Theme.of(context).colorScheme.primaryContainer, 
                  title: 'Currency',
                  trailing: _selectedAccountCreationCurrency == null
                    ? null
                    : Text(
                      _selectedAccountCreationCurrency!,
                      style: const TextStyle(fontSize: 15, color: Colors.grey,),
                    ),
                  onTap: () => _showCurrenciesSelectionSheet(),
                ),
                // account icon
                ExpansionTile(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  collapsedBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),),
                  title: const Text('Icon'),
                  trailing: _selectedIcon != ''
                    ? CustomIcon(icon: IconsManager.getAccountIconByName(_selectedIcon))
                    : const CustomIcon(icon: Icons.arrow_drop_down_rounded),
                  childrenPadding: const EdgeInsets.all(10),
                  children: [
                    SizedBox(
                      height: 150,
                      child: GridView.builder(
                        shrinkWrap: true,
                        itemCount: IconsManager.accountIcons.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                        ), 
                        itemBuilder: (context, index) {
                          return IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedIcon = IconsManager.accountsKeys[index];
                              });
                            },
                            icon: CustomIcon(icon: IconsManager.getAccountIconByName(IconsManager.accountsKeys[index])),
                            iconSize: 25,
                            padding: EdgeInsets.zero,
                          );
                        }
                      )
                    )
                  ]
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
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
import 'package:open_budget/widgets/show_snack_bar.dart';

class AccountCreateBottomSheet extends StatefulWidget {
  final AppDatabase db;

  const AccountCreateBottomSheet({
    super.key,
    required this.db,
  });

  @override
  State<AccountCreateBottomSheet> createState() => _AccountCreateBottomSheetState();
}

class _AccountCreateBottomSheetState extends State<AccountCreateBottomSheet> {
  final nameController = TextEditingController();
  final initialBalanceController = TextEditingController(text: '0');
  String? selectedIcon;
  String? selectedAccountCreationCurrency;

  void _handleAccountCreation({
    required String initialBalanceStr,
    required String? name,
    required String? selectedCurrency,
    required String? selectedIcon,
  }) async {

    double? initialBalance = double.tryParse(initialBalanceStr);
    if(initialBalance == null) {
      showSnackBar(
        context: context, 
        content: const Text('Enter valid initial balance')
      );
      return;
    }

    if(name == null) {
      showSnackBar(
        context: context, 
        content: const Text('Enter valid account name')
      );
      return;
    }

    if(selectedCurrency == null) {
      showSnackBar(
        context: context, 
        content: const Text('Select account currency')
      );
      return;
    }

    if(selectedIcon == null) {
      showSnackBar(
        context: context, 
        content: const Text('Select account icon')
      );
      return;
    }

    // add account into db
    await widget.db.accountsDao.createAccount(
      initialBalance: initialBalance, 
      name: name, 
      currency: selectedCurrency, 
      icon: selectedIcon
    );
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
                      selectedAccountCreationCurrency = item.code;
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
            const CustomHeaderTitle(title: 'Create Account'),
            CustomIconButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () {                
                _handleAccountCreation(
                  initialBalanceStr: initialBalanceController.text, 
                  name: nameController.text, 
                  selectedCurrency: selectedAccountCreationCurrency, 
                  selectedIcon: selectedIcon
                );
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
                  controller: nameController, 
                  hintText: 'Account name...'
                ),
                // initial balance
                CustomTextField(
                  controller: initialBalanceController, 
                  labelText: 'Initial balance',
                  hintText: '',
                ),
                // currency
                CustomListTile(
                  tileColor: Theme.of(context).colorScheme.primaryContainer, 
                  title: 'Currency',
                  trailing: selectedAccountCreationCurrency == null
                    ? null
                    : Text(
                      selectedAccountCreationCurrency!,
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
                  trailing: selectedIcon != null
                    ? CustomIcon(icon: IconsManager.getAccountIconByName(selectedIcon))
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
                                selectedIcon = IconsManager.accountsKeys[index];
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
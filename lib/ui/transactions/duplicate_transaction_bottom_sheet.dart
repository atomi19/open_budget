import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/format_number.dart';
import 'package:open_budget/logic/handle_data_submit.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/ui/accounts/account_duplicate_bottom_sheet.dart';
import 'package:open_budget/ui/categories/categories_list_bottom_sheet.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/custom_modal_bottom_sheet.dart';
import 'package:open_budget/widgets/custom_text_field.dart';
import 'package:open_budget/widgets/date_time_picker.dart';
import 'package:open_budget/widgets/show_snack_bar.dart';

class DuplicateTransactionBottomSheet extends StatefulWidget {
  final AppDatabase db;
  final Transaction transaction;
  final bool isIncome;
  
  const DuplicateTransactionBottomSheet({
    super.key,
    required this.db,
    required this.transaction,
    required this.isIncome,
  });

  @override
  State<DuplicateTransactionBottomSheet> createState() => _DuplicateTransactionBottomSheetState();
}

class _DuplicateTransactionBottomSheetState extends State<DuplicateTransactionBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Account? _selectedAccount;
  Category? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _amountController.text = formatNumber(widget.transaction.amount.abs());
    _findAccountById(widget.transaction.accountOwnerId);
    _findCategoryById(widget.transaction.categoryId!);
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _findCategoryById(int id) async {
    final selectedCategory = await widget.db.categoriesDao.getCategoryById(id);
    setState(() {
      _selectedCategory = selectedCategory;
    });
  }

  Future<void> _findAccountById(int id) async {
    _selectedAccount = await widget.db.accountsDao.getAccountById(id);
  }

  // list income or expense categories
  void _showCategories({
    required bool isIncome,
  }) {
    showCustomModalBottomSheet(
      context: context, 
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: CategoriesListBottomSheet(
        context: context,
        db: widget.db, 
        isIncome: isIncome, 
        onTap: (int id) async {
          Navigator.pop(context);
          await _findCategoryById(id);
        }
      ),
    );
  }

  // accounts list modal bottom sheet
  void _showAccountsSheet() {
    showCustomModalBottomSheet(
      context: context, 
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: AccountDuplicateBottomSheet(
        db: widget.db,
        onAccountTap: (Account account) {
          setState(() {
            _selectedAccount = account;
          });
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // header
        CustomHeader(
          children: [
            CustomIconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close)
            ),
            CustomHeaderTitle(
              title: widget.isIncome ? 'Duplicate Income' : 'Duplicate Expense'
            ),
            // confirm category changes button
            CustomIconButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                HapticFeedback.lightImpact();
                handleDataSubmit(
                  db: widget.db, 
                  isIncome: widget.isIncome,
                  amountStr: _amountController.text,
                  selectedDate: _selectedDate, 
                  selectedTime: _selectedTime, 
                  accountOwner: _selectedAccount, 
                  categoryId: _selectedCategory?.id, 
                  descriptionController: _descriptionController, 
                  displaySnackBar: (content) => showSnackBar(context: context, content: content), 
                  clearInputDataOnSubmit: () {}
                );
                Navigator.pop(context);
              }, 
              icon: Icon(Icons.done, color: Theme.of(context).colorScheme.secondary,)
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              spacing: 10,
              children: [
                CustomTextField(
                  controller: _amountController, 
                  prefix: Text(widget.isIncome ? '+ ': '- '),
                  textInputType: TextInputType.number,
                  hintText: widget.isIncome
                    ? 'Enter income...'
                    : 'Enter expense...',
                ),
                // account
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: CustomListTile(
                        leading: _selectedAccount == null 
                          ? const CustomIcon(icon: Icons.help_outline)
                          : CustomIcon(icon: IconsManager.getAccountIconByName(_selectedAccount!.icon)),
                        title: _selectedAccount != null
                          ? _selectedAccount!.name.toString()
                          : 'Account',
                        trailing: const CustomIcon(icon: Icons.chevron_right),
                        onTap: _showAccountsSheet,
                      ),
                    ),
                  ],
                ),
                // date 
                CustomListTile(
                  leading: const CustomIcon(icon: Icons.calendar_month),
                  title: _selectedDate != null
                    ? '${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}'
                    : 'Date',
                  trailing: const CustomIcon(icon: Icons.chevron_right),
                  onTap: () async {
                    final selectedDate = await pickDate(context: context);
                    setState(() => _selectedDate = selectedDate);
                  },
                ),
                // time 
                CustomListTile(
                  leading: const CustomIcon(icon: Icons.access_time),
                  title: _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'Time',
                  trailing: const CustomIcon(icon: Icons.chevron_right),
                  onTap: () async {
                    final selectedTime = await pickTime(context: context);
                    setState(() => _selectedTime = selectedTime);
                  },
                ),
                // category
                CustomListTile(
                  leading: _selectedCategory == null 
                    ? const CustomIcon(icon: Icons.help_outline)
                    : CustomIcon(icon: IconsManager.getCategoryIconByName(_selectedCategory!.iconName)),
                  title: _selectedCategory?.name ?? 'Category',
                  trailing: const CustomIcon(icon: Icons.chevron_right),
                  onTap: () => _showCategories(isIncome: widget.isIncome),
                ),
                // description textfield
                CustomTextField(
                  controller: _descriptionController,
                  hintText: 'Enter description...',
                  minLines: 1,
                  maxLines: 5,
                  textInputType: TextInputType.multiline,
                ),
              ],
            )
          ),
        )
      ],
    );
  }
}
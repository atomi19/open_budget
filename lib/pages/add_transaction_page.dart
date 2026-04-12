// main page that contains income and expense screens (switch between them)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/handle_data_submit.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/ui/accounts/accounts_list_bottom_sheet.dart';
import 'package:open_budget/ui/categories/categories_list_bottom_sheet.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/custom_modal_bottom_sheet.dart';
import 'package:open_budget/widgets/custom_text_field.dart';
import 'package:open_budget/widgets/date_time_picker.dart';
import 'package:open_budget/widgets/show_snack_bar.dart';
import 'package:open_budget/widgets/submit_button.dart';

class AddTransactionPage extends StatefulWidget {
  final AppDatabase db;

  const AddTransactionPage({
    super.key,
    required this.db,
  });
  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final PageController _pageViewController = PageController();
  int _transactionPageIndex = 0; // 0 - income page, 1 - spending page

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Account? _selectedAccount;
  Category? _selectedCategory;

  int? _selectedCategoryId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // reset all variables for _transactionAddForm
  void _resetData() {
    setState(() {
      _amountController.clear();
      _selectedDate = null;
      _selectedTime = null;
      _selectedAccount = null;
      _selectedCategory = null;
      _selectedCategoryId = null;
      _descriptionController.clear();
    });
  }

  // clear amount and description fields on transaction submit
  void _clearInputDataOnSubmit() {
    setState(() {
      _amountController.clear();
      _descriptionController.clear();
    });
  }

  Future<void> _findCategoryById(int id) async {
    _selectedCategory = await widget.db.categoriesDao.getCategoryById(id);
  }

  // list income or expense categories
  void _showCategories({
    required bool isIncome,
  }) {
    showCustomModalBottomSheet(
      context: context, 
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: CategoriesListBottomSheet(
        db: widget.db, 
        isIncome: isIncome, 
        onTap: (int id) async {
          setState(() {
            _selectedCategoryId = id;
          });
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
      child: AccountsListBottomSheet(
        db: widget.db,
        onTap: (Account account) {
          setState(() {
            _selectedAccount = account;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  // income or expense form
  Widget _transactionAddForm({
    required bool isIncome
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        spacing: 10,
        children: [
          // amount textfield
          CustomTextField(
            controller: _amountController, 
            hintText: isIncome
              ? 'Enter income...'
              : 'Enter expense...',
            prefix: Text(isIncome ? '+ ': '- '),
            maxLines: 1,
            textInputType: TextInputType.number,
          ),
          // account
          CustomListTile(
            tileColor: Theme.of(context).colorScheme.primaryContainer, 
            leading: _selectedAccount == null 
              ? const CustomIcon(icon: Icons.help_outline)
              : CustomIcon(icon: IconsManager.getAccountIconByName(_selectedAccount!.icon)),
            title: _selectedAccount != null
              ? _selectedAccount!.name.toString()
              : 'Account',
            trailing: const CustomIcon(icon: Icons.chevron_right),
            onTap: _showAccountsSheet,
          ),
          // date 
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: CustomListTile(
                  tileColor: Theme.of(context).colorScheme.primaryContainer,
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
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer
                ),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime.now();
                  });
                }, 
                child: Text('Now', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),)
              ),
            ],
          ),
          // time 
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: CustomListTile(
                  tileColor: Theme.of(context).colorScheme.primaryContainer,
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
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
                onPressed: () {
                  setState(() {
                    _selectedTime = TimeOfDay.now();
                  });
                }, 
                child: Text('Now', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),)
              ),
            ],
          ),
          // category
          CustomListTile(
            tileColor: Theme.of(context).colorScheme.primaryContainer,
            leading: _selectedCategory == null 
              ? const CustomIcon(icon: Icons.help_outline)
              : CustomIcon(icon: IconsManager.getCategoryIconByName(_selectedCategory!.iconName)),
            title: _selectedCategory?.name ?? 'Category',
            trailing: const CustomIcon(icon: Icons.chevron_right),
            onTap: () => _showCategories(
              isIncome: isIncome,
            ),
          ),
          // description textfield
          CustomTextField(
            controller: _descriptionController,
            hintText: 'Enter description...',
            minLines: 1,
            maxLines: 5,
            textInputType: TextInputType.multiline,
          ),
          // save button
          SubmitButton(
            onTap: () {
              HapticFeedback.lightImpact();
              handleDataSubmit(
                db: widget.db, 
                displaySnackBar: (content) => 
                  showSnackBar(
                    context: context, 
                    content: Text(
                      content,
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                amountStr: isIncome
                ? _amountController.text // income amount
                : '-${_amountController.text}', // expense amount
                selectedDate: _selectedDate, 
                selectedTime: _selectedTime, 
                accountOwner: _selectedAccount,
                categoryId: _selectedCategoryId, 
                descriptionController: _descriptionController, 
                clearInputDataOnSubmit: _clearInputDataOnSubmit,
              );
            },
            text: 'Save'
          ),
        ],
      ),
    );
  }

  // income / expense switch button
  Widget _switchButton({
    required bool isIncome,
    required int pageIndex,
  }) {
    int currentPageIndex = isIncome
      ? 0
      : 1;

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: pageIndex == currentPageIndex
          ? Colors.blue
          : Theme.of(context).colorScheme.primaryContainer,
        shape: const StadiumBorder()
      ),
      onPressed: () => _pageViewController.animateToPage(
        currentPageIndex, 
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeOutCubic
      ),
      child: Row(
        children: [
          pageIndex == currentPageIndex
            ? Icon(
              isIncome ? Icons.download_outlined : Icons.upload_outlined,
              color: Theme.of(context).colorScheme.secondary,
            )
            : const SizedBox(),
          const SizedBox(width: 5),
          Text(
            isIncome ? 'Income' : 'Expense',
            style: TextStyle(
              color: pageIndex == currentPageIndex
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.onPrimary
            ),
          )
        ],
      )
    );
  } 

  void _handlePageViewChanged(int currentPageIndex) {
    HapticFeedback.selectionClick();
    _resetData();
    _transactionPageIndex = currentPageIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        spacing: 10,
        children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [
                  // income button
                  _switchButton(
                    isIncome: true, 
                    pageIndex: _transactionPageIndex,
                  ),
                  // expense button
                  _switchButton(
                    isIncome: false, 
                    pageIndex: _transactionPageIndex,
                  ),
                ],
              ),
            ),
          ),
          // income and expense forms
          Expanded(
            child: PageView(
              controller: _pageViewController,
              onPageChanged: _handlePageViewChanged,
              children: [
                _transactionAddForm(isIncome: true),
                _transactionAddForm(isIncome: false),
              ],
            ),
          )
        ],
      )
    );
  }
}
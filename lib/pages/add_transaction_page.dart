// main page that contains income and expense screens (switch between them)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_budget/logic/app_settings.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/format_number.dart';
import 'package:open_budget/logic/handle_data_submit.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/ui/accounts/account_transfer_bottom_sheet.dart';
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
  final int currentTabIndex;

  const AddTransactionPage({
    super.key,
    required this.db,
    required this.currentTabIndex,
  });
  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final PageController _pageViewController = PageController();
  int _transactionPageIndex = 0; // 0 - income page, 1 - spending page

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Account? _favoriteAccount;
  Account? _selectedAccount;
  Category? _selectedCategory;

  int? _selectedCategoryId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // quick amounts
  final List<double> _quickAmounts = [10, 50, 100, 200, 500, 1000];
  List<Category> _recentIncomeCategories = [];
  List<Category> _recentExpenseCategories = [];
  
  // transfer 
  Account? _fromAccount;
  Account? _toAccount;

  @override
  void initState() {
    super.initState();
    _getFavoriteAccount();
    _getRecentCategories();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _pageViewController.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(AddTransactionPage oldWidget)  {
    super.didUpdateWidget(oldWidget);

    if(widget.currentTabIndex == 1 && oldWidget.currentTabIndex != widget.currentTabIndex) {
      _getRecentCategories();
    }
  }

  void _getFavoriteAccount() async {
    final favoriteAccountId = await AppSettings.getFavoriteAccount();
    final Account? favoriteAccount = await widget.db.accountsDao.getAccountById(favoriteAccountId);
    setState(() {
      _favoriteAccount = favoriteAccount;
      _selectedAccount = favoriteAccount;
    });
  }

  void _getRecentCategories() async {
    final recentIncomeCategoriesIds = await AppSettings.getRecentCategories(true);
    final recentExpenseCategoriesIds = await AppSettings.getRecentCategories(false);

    final List<Category> recentIncomeCategories = [];
    final List<Category> recentExpenseCategories = [];

    for (final id in recentIncomeCategoriesIds) {
      final category = await _getCategoryById(id);

      if(category != null) {
        recentIncomeCategories.add(category);
      }
    }

    for (final id in recentExpenseCategoriesIds) {
      final category = await _getCategoryById(id);

      if(category != null) {
        recentExpenseCategories.add(category);
      }
    }

    setState(() {
      _recentIncomeCategories = recentIncomeCategories;
      _recentExpenseCategories = recentExpenseCategories;
    });
  }

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
      _fromAccount = null;
      _toAccount = null;
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

  Future<Category?> _getCategoryById(int id) async {
    return await widget.db.categoriesDao.getCategoryById(id);
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
        favoriteAccount: _favoriteAccount,
        onTap: (Account account) {
          setState(() {
            _selectedAccount = account;
          });
          Navigator.pop(context);
        },
        onFavoriteTap: (Account account) async {
          if(_favoriteAccount?.id == account.id) {
            // favorite account and current selected account are the same
            // remove favorite account key from shared_preferences
            await AppSettings.removeFavoriteAccount();
            setState(() {
              _favoriteAccount = null;
            });
          } else {
            // set favorite account 
            await AppSettings.setFavoriteAccount(account.id);
            setState(() {
              _favoriteAccount = account;
            });
          }
        }
      ),
    );
  }

  // accounts list for transfer
  void _showAccountsTransferSheet(bool isFromAccount) {
    showCustomModalBottomSheet(
      context: context, 
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: AccountTransferBottomSheet(
        db: widget.db,
        onAccountTap: (Account account) {
          setState(() {            
            if(isFromAccount) {
              _fromAccount = account;
            } else {
              _toAccount = account;
            }
          });
          Navigator.pop(context);
        },
      )
    );
  }

  void _handleRecentCategories(bool isIncome) {
    if(_selectedCategory != null) {
      // recent income categories
      if(isIncome) {
        if(_recentIncomeCategories.length > 5) {
          // limit length by 5
          _recentIncomeCategories.removeLast();
        }
        if(!_recentIncomeCategories.contains(_selectedCategory)) {
          // check if recent caegories already contains this category
          _recentIncomeCategories.insert(
            0, 
            _selectedCategory!,
          );
        }
      } else {
        // recent expense categories
        if(_recentExpenseCategories.length > 5) {
          // limit length by 5
          _recentExpenseCategories.removeLast();
        }
        if(!_recentExpenseCategories.contains(_selectedCategory)) {
          // check if recent caegories already contains this category
          _recentExpenseCategories.insert(
            0, 
            _selectedCategory!,
          );
        }
      }
    }
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
          // quick amounts
          SizedBox(
            height: 35,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quickAmounts.length,
              itemBuilder: (context, index) {
                final amount = formatNumber(_quickAmounts[index]);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ActionChip(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    side: BorderSide.none,
                    label: Text(
                      isIncome 
                      ? '+$amount' 
                      : '-$amount'
                    ),
                    onPressed: () {
                      double? amount = double.tryParse(_amountController.text);

                      if(_amountController.text.isEmpty) amount = 0;

                      if(amount != null) {
                        amount += _quickAmounts[index];
                        _amountController.text = formatNumber(amount);
                      }
                    },
                  ),
                );
              }
            ),
          ),
          // amount textfield
          CustomTextField(
            controller: _amountController, 
            hintText: isIncome
              ? 'Enter income...'
              : 'Enter expense...',
            prefix: Text(isIncome ? '+ ': '- '),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: GestureDetector(
                onTap: () => _amountController.clear(),
                child: const Icon(Icons.cancel_outlined, size: 20,),
              ),
            ),
            maxLines: 1,
            textInputType: TextInputType.number,
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
              // insert Default text button only if there is chosen favorite account
              if(_favoriteAccount != null)
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  _getFavoriteAccount();
                }, 
                child: Text('Default', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),)
              ),
            ],
          ),
          // date 
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: CustomListTile(
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
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
          // recent categories chips (up to 5)
          if(isIncome && _recentIncomeCategories.isNotEmpty || !isIncome && _recentExpenseCategories.isNotEmpty)
            SizedBox(
              height: 35,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: isIncome 
                  ? _recentIncomeCategories.length
                  : _recentExpenseCategories.length,
                itemBuilder: (context, index) {
                  final category = isIncome
                    ? _recentIncomeCategories[index]
                    : _recentExpenseCategories[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ActionChip(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      side: BorderSide.none,
                      avatar: CustomIcon(
                        icon: IconsManager.getCategoryIconByName(category.iconName)
                      ),
                      label: Text(
                        category.name,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedCategory = category;
                          _selectedCategoryId = category.id;
                        });
                      },
                    ),
                  );
                }
              ),
            ),
          // category
          CustomListTile(
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

              _handleRecentCategories(isIncome);

              handleDataSubmit(
                db: widget.db, 
                isIncome: isIncome,
                displaySnackBar: (content) => 
                  showSnackBar(
                    context: context, 
                    content: Text(
                      content,
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                amountStr: _amountController.text,
                selectedDate: _selectedDate, 
                selectedTime: _selectedTime, 
                accountOwner: _selectedAccount,
                categoryId: _selectedCategoryId, 
                recentCategories: isIncome
                  ? _recentIncomeCategories
                  : _recentExpenseCategories,
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

  // transfer form
  Widget _transactionTransferForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        spacing: 10,
        children: [
          // amount textfield
          CustomTextField(
            controller: _amountController, 
            hintText: 'Enter transfer',
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: GestureDetector(
                onTap: () => _amountController.clear(),
                child: const Icon(Icons.cancel_outlined, size: 20,),
              ),
            ),
            maxLines: 1,
            textInputType: TextInputType.number,
          ),
          // from account
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: CustomListTile(
                  leading: _fromAccount == null 
                    ? const CustomIcon(icon: Icons.help_outline)
                    : CustomIcon(icon: IconsManager.getAccountIconByName(_fromAccount!.icon)),
                  title: _fromAccount != null
                    ? _fromAccount!.name.toString()
                    : 'From account',
                  trailing: const CustomIcon(icon: Icons.chevron_right),
                  onTap: () =>_showAccountsTransferSheet(true),
                ),
              ),
            ],
          ),
          // to account
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: CustomListTile(
                  leading: _toAccount == null 
                    ? const CustomIcon(icon: Icons.help_outline)
                    : CustomIcon(icon: IconsManager.getAccountIconByName(_toAccount!.icon)),
                  title: _toAccount != null
                    ? _toAccount!.name.toString()
                    : 'To account',
                  trailing: const CustomIcon(icon: Icons.chevron_right),
                  onTap: () => _showAccountsTransferSheet(false),
                ),
              ),
            ],
          ),
          // date 
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: CustomListTile(
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
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
              handleTransferSubmit(
                db: widget.db, 
                amountStr: _amountController.text, 
                fromAccount: _fromAccount, 
                toAccount: _toAccount, 
                selectedDate: _selectedDate, 
                selectedTime: _selectedTime, 
                description: _descriptionController.text, 
                displaySnackBar: (String content) {
                  showSnackBar(
                    context: context, 
                    content: Text(content),
                  );
                }, 
                clearTransferDataOnSubmit: _clearInputDataOnSubmit
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
    required int pageIndex,
  }) {
    const titles = ['Income', 'Expense', 'Transfer'];
    const icons = [Icons.download_outlined, Icons.upload_outlined, Icons.swap_horiz];

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: pageIndex == _transactionPageIndex
          ? Colors.blue
          : Theme.of(context).colorScheme.primaryContainer,
        shape: const StadiumBorder()
      ),
      onPressed: () => _pageViewController.animateToPage(
        pageIndex, 
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeOutCubic
      ),
      child: Row(
        children: [
          pageIndex == _transactionPageIndex
            ? Row(
              children: [
                Icon(
                  icons[pageIndex],
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 5),
              ],
            )
            : const SizedBox(),
          Text(
            titles[pageIndex],
            style: TextStyle(
              color: pageIndex == _transactionPageIndex
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
            padding: const EdgeInsets.only(top: 15),
            child: Container(
              padding: const EdgeInsets.all(3),
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
                  _switchButton(pageIndex: 0),
                  // expense button
                  _switchButton(pageIndex: 1),
                  // transfer button
                  _switchButton(pageIndex: 2),
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
                _transactionTransferForm(),
              ],
            ),
          )
        ],
      )
    );
  }
}
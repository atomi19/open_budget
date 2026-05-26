// contains all the content of home page
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_budget/logic/app_settings.dart';
import 'package:open_budget/logic/currencies.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/pages/settings_page.dart';
import 'package:open_budget/pages/statistics_page.dart';
import 'package:open_budget/ui/accounts/account_choose_bottom_sheet.dart';
import 'package:open_budget/ui/accounts/account_create_bottom_sheet.dart';
import 'package:open_budget/ui/categories/categories_bottom_sheet.dart';
import 'package:open_budget/ui/transactions/all_transactions_bottom_sheet.dart';
import 'package:open_budget/ui/transactions/amount_edit_bottom_sheet.dart';
import 'package:open_budget/ui/transactions/transaction_details_bottom_sheet.dart';
import 'package:open_budget/widgets/build_transactions_list.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/custom_modal_bottom_sheet.dart';
import 'package:open_budget/widgets/date_time_picker.dart';
import 'package:open_budget/widgets/empty_list_placeholder.dart';
import 'package:open_budget/widgets/section_header.dart';
import 'package:open_budget/widgets/summary_widget.dart';

class HomePageContent extends StatefulWidget {
  final AppDatabase db;
  final Function(ThemeMode) setTheme;

  const HomePageContent({
    super.key,
    required this.db,
    required this.setTheme,
  });
  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final PageController _pageViewController = PageController();
  int currentPageIndex = 0;

  bool _isShowingDescription = false;
  int _homeTransactionsCount = 3;

  // store categories locally 
  // sort them by id 
  // category is the value
  Map<int, Category> _categoriesById = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadDescriptionState();
    _loadTransactionsCount();
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  // load description preview state from shared_preferences
  Future<void> _loadDescriptionState() async {
    _isShowingDescription = await AppSettings.getTransactionDescriptionState() ?? false;
  }

  // load and keep categories locally
  // e.g. to get category name 
  Future<void> _loadCategories() async {
    widget.db.categoriesDao.watchCategories().listen((categories) {
      setState(() {
        _categoriesById= {for (var c in categories) c.id : c};
      });
    });
  }

  Future<void> _loadTransactionsCount() async {
    _homeTransactionsCount = await AppSettings.getTransactionsCountOnHomePage() ?? 3;
  }

  // all transactions modalBottomSheet
  void _showAllTransactions({
    required int selectedAccountId,
    required Currency accountCurrency,
  }) {
    showCustomModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      borderRadius: 0,
      padding: 0,
      child: AllTransactionsBottomSheet(
        db: widget.db, 
        selectedAccountId: selectedAccountId, 
        categoriesById: _categoriesById, 
        currentCurrency: accountCurrency, 
        isShowingDescription: _isShowingDescription, 
        showTransactionDetails: _showTransactionDetails,
      ),
    );
  }

  // change transaction category modalBottomSheet
  void _showCategories({
    required bool isIncome,
    required Transaction item,
    }) {
    showCustomModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: CategoriesBottomSheet(
        db: widget.db,
        isIncome: isIncome,
        item: item,
      ),
    );
  }

  // amount editing modalBottomSheet
  void _showAmountEditingSheet({
    required bool isIncome,
    required Transaction item
  }) {
    showCustomModalBottomSheet(
      context: context, 
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: AmountEditBottomSheet(
        db: widget.db,
        isIncome: isIncome,
        item: item,
      ),
    );
  }

  // edit date picker 
  void _showEditDatePicker(Transaction item) async {
    final oldDate = item.dateAndTime;

    // show date picker 
    DateTime? newDate = await pickDate(
      context: context,
      currentDate: oldDate,
    );

    if(newDate != null) {
      newDate = DateTime(
        newDate.year,
        newDate.month,
        newDate.day,
        oldDate.hour,
        oldDate.minute,
      );
      // update in db
      if(item.transactionType == 2) {
        // update transfer date and time
        widget.db.transactionsDao.updateTransferDateAndTime(item.transferId!, newDate);
      } else {
        // update transaction date and time
        widget.db.transactionsDao.updateDateAndTime(item.id, newDate);
      }
      if(!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  // edit time picker
  void _showEditTimePicker(Transaction item) async {
    final oldDate = item.dateAndTime;

    // show time picker
    final newTime = await pickTime(
      context: context,
      initialTime: TimeOfDay(hour: oldDate.hour, minute: oldDate.minute),
    );

    if(newTime != null) {
      final newDate = DateTime(
        oldDate.year,
        oldDate.month,
        oldDate.day,
        newTime.hour,
        newTime.minute,
      );
      // update in db
      if(item.transactionType == 2) {
        // update transfer date and time
        widget.db.transactionsDao.updateTransferDateAndTime(item.transferId!, newDate);
      } else {
        // update transaction date and time
        widget.db.transactionsDao.updateDateAndTime(item.id, newDate);
      }
      if(!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  // transaction details modalBottomSheet
  void _showTransactionDetails(Transaction item, Currency accountCurrency) {
    final category = _categoriesById[item.categoryId];
    final iconNameKey = category?.iconName;
    bool isIncome = item.amount > 0
      ? true
      : false;

    showCustomModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      borderRadius: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: TransactionDetailsBottomSheet(
        db: widget.db, 
        item: item, 
        currentCurrency: accountCurrency, 
        categoriesById: _categoriesById, 
        isIncome: isIncome, 
        iconNameKey: iconNameKey, 
        showAmountEditingSheet: _showAmountEditingSheet, 
        showCategories: _showCategories, 
        showEditDatePicker: _showEditDatePicker, 
        showEditTimePicker: _showEditTimePicker
      ),
    );
  }

  // switch description state for transaction (show on home page or not)
  void _switchDescriptionState(bool state) {
    setState(() {
      _isShowingDescription = state;
    });
  }

  // handle transaction count increase or decrease on home page
  // return number of transactions for settings_bottom_sheet updating value
  int? _handleTransactionCount(int digit) {
    final newValue = _homeTransactionsCount + digit;

    if(newValue < 3 || newValue > 10) {
      HapticFeedback.selectionClick();
      return null;
    }
    setState(() {
      _homeTransactionsCount = newValue;
    });
    AppSettings.setTransactionsCountOnHomePage(_homeTransactionsCount);
    return _homeTransactionsCount;
  }

  void _showAccountCreateSheet() {
    showCustomModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      borderRadius: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: AccountCreateBottomSheet(db: widget.db,)
    );
  }

  void _showAccountChooseSheet({required List<Account> allAccounts}) {
    showCustomModalBottomSheet(
      context: context, 
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: AccountChooseBottomSheet(
        db: widget.db,
        pageViewController: _pageViewController,
        allAccounts: allAccounts,
      ),
    );
  }

  void _handlePageViewChanged({
    required int pageIndex,
    required List<Account> items,
  }) {
    HapticFeedback.selectionClick();
    currentPageIndex = pageIndex; // selected account based on page view index
  }

  // header
  Widget _header({
    required Account account,
    required List<Account> allAccounts,
    required Currency accountCurrency,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // statistics icon button
          CustomIconButton(
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => StatisticsPage(
                  db: widget.db, 
                  account: account,
                  currentCurrency: accountCurrency, 
                )
              )
            ),
            icon: const Icon(Icons.data_usage_outlined)
          ),
          // account filled button
          // on tap account choose modal botom sheet
          FilledButton(
            onPressed: () => _showAccountChooseSheet(allAccounts: allAccounts), 
            child: Row(
              spacing: 5,
              children: [
                Text(
                  account.name,
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            )
          ),
          // settings icon button
          CustomIconButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => SettingsPage(
                    db: widget.db,
                    homeTransactionsCount: _homeTransactionsCount,
                    isShowingDescription: _isShowingDescription,
                    setTheme: (newTheme) => widget.setTheme(newTheme),
                    switchDescriptionState: (bool state) => _switchDescriptionState(state),
                    handleTransactionCount: (digit) => _handleTransactionCount(digit),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined)
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: widget.db.accountsDao.watchAccounts(false), 
              builder: (context, snapshot) {
                final items = snapshot.data ?? [];

                // if there is no accounts
                // show placeholder
                return items.isEmpty 
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EmptyListPlaceholder(
                        color: Theme.of(context).colorScheme.surface, 
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'No accounts yet',
                        subtitle: 'Please, create account first'
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary
                        ),
                        child: Text(
                          'Create Account',
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                        onPressed: () => _showAccountCreateSheet(),
                      ),
                    ],
                  )
                  // otherwise show body
                  : PageView.builder(
                    controller: _pageViewController,
                    onPageChanged: (index) => _handlePageViewChanged(
                      pageIndex: index,
                      items: items
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final account = items[index];
                      final Currency accountCurrency = Currency.currencies.firstWhere((c) => c.code == account.currency);

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                        child: Column(
                          children: [
                            _header(
                              account: account, 
                              allAccounts: items,
                              accountCurrency: accountCurrency
                            ),
                            const SizedBox(height: 10),
                            // total balance
                            StreamBuilder(
                              stream: widget.db.transactionsDao.watchTotalBalance(account),
                              builder: (context, snapshot) {
                                final totalBalance = snapshot.data ?? 0;
                                return Container(
                                  alignment: Alignment.center,
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: Column(
                                    children: [
                                      CustomIcon(icon: IconsManager.getAccountIconByName(account.icon)),
                                      Text(account.name),
                                      Text(
                                        '${totalBalance.toString()} ${accountCurrency.symbol}', 
                                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                );
                              }
                            ),
                            const SizedBox(height: 10),
                            // tab indicator
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Theme.of(context).colorScheme.primaryContainer,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 10,
                                children: [
                                  CustomIconButton(
                                    onPressed: () {
                                      _pageViewController.animateToPage(
                                        currentPageIndex - 1, 
                                        duration: const Duration(milliseconds: 300), 
                                        curve: Curves.easeOutCubic
                                      );
                                    }, 
                                    icon: const Icon(Icons.chevron_left)
                                  ),
                                  ...List.generate(
                                    items.length, 
                                    (int index) {
                                      bool isSelected = items[index].id == account.id;
                                      return Icon(
                                        color: Theme.of(context).colorScheme.tertiary,
                                        size: 10,
                                        isSelected
                                          ? Icons.circle
                                          : Icons.circle_outlined
                                      );
                                    }
                                  ),
                                  CustomIconButton(
                                    onPressed: () {
                                      _pageViewController.animateToPage(
                                        currentPageIndex + 1, 
                                        duration: const Duration(milliseconds: 300), 
                                        curve: Curves.easeOutCubic
                                      );
                                    }, 
                                    icon: const Icon(Icons.chevron_right)
                                  ),
                                ] 
                              ),
                            ),
                            // last transactions (3 to 10)
                            const SectionHeader(
                              title: 'Transactions'
                            ),
                            const SizedBox(height: 10),
                            Material(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(15),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  StreamBuilder(
                                    stream: widget.db.transactionsDao.watchAllTransactionItems(account.id),
                                    builder: (context, snapshot) {
                                      final items = snapshot.data ?? [];
                                      final lastThreeItems = items.take(_homeTransactionsCount).toList();
                                      return items.isNotEmpty
                                      ? TransactionsList(
                                        db: widget.db, 
                                        shrinkWrap: true, 
                                        items: lastThreeItems, 
                                        categoriesById: _categoriesById, 
                                        currentCurrency: accountCurrency, 
                                        shouldInsertDate: false, 
                                        contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 24.0),
                                        showDescription: _isShowingDescription, 
                                        showTransactionDetails: _showTransactionDetails
                                      )
                                      : Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: EmptyListPlaceholder(
                                          color: Theme.of(context).colorScheme.primaryContainer,
                                          icon: Icons.close_rounded, 
                                          title: 'No transactions yet', 
                                          subtitle: 'Add transactions and they will appear here'
                                        )
                                      );
                                    }
                                  ),
                                  Divider(
                                    height: 1,
                                    color: Theme.of(context).colorScheme.surface,
                                  ),
                                  // all transactions listtile
                                  CustomListTile(
                                    title: 'All Transactions',
                                    trailing: const CustomIcon(icon: Icons.chevron_right),
                                    customBorder: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.zero,
                                        bottom: Radius.circular(15)
                                      )
                                    ),
                                    onTap: () => _showAllTransactions(
                                      selectedAccountId: account.id, 
                                      accountCurrency: accountCurrency
                                    ),
                                  ),
                                ],
                              )
                            ),
                            // summary 
                            const SectionHeader(title: 'This month'),
                            const SizedBox(height: 10),
                            SummaryWidget(
                              db: widget.db, 
                              account: account, 
                              accountCurrency: accountCurrency,
                              startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
                              endDate: DateTime.now(),
                            ),
                          ],
                        ),
                      );
                    },
                  );
              }
            ),
          ),
        ],
      ),
    );
  }
}
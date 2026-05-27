import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_budget/logic/app_settings.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/ui/accounts/account_create_bottom_sheet.dart';
import 'package:open_budget/ui/accounts/account_edit_bottom_sheet.dart';
import 'package:open_budget/ui/accounts/accounts_archive_sheet.dart';
import 'package:open_budget/ui/accounts/accounts_bottom_sheet.dart';
import 'package:open_budget/ui/categories/categories_manager_bottom_sheet.dart';
import 'package:open_budget/ui/categories/category_create_bottom_sheet.dart';
import 'package:open_budget/ui/categories/category_edit_bottom_sheet.dart';
import 'package:open_budget/ui/settings/about_bottom_sheet.dart';
import 'package:open_budget/widgets/custom_alert_dialog.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/custom_modal_bottom_sheet.dart';
import 'package:open_budget/widgets/custom_switch.dart';
import 'package:open_budget/widgets/section_header.dart';
import 'package:open_budget/widgets/show_snack_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  final AppDatabase db;
  final int homeTransactionsCount;
  final bool isShowingDescription;
  final void Function(ThemeMode newTheme) setTheme;
  final void Function(bool isShowingDescription) switchDescriptionState;
  final int? Function(int digit) handleTransactionCount;

  const SettingsPage({
    super.key,
    required this.db,
    required this.homeTransactionsCount,
    required this.isShowingDescription,
    required this.setTheme,
    required this.switchDescriptionState,
    required this.handleTransactionCount,
  });
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool isShowingDescription;
  late int homeTransactionsCount;
  ThemeMode? theme;

  PackageInfo _appInfo = PackageInfo(
    appName: 'Unknown', 
    packageName: 'Unknown', 
    version: 'Unknown', 
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    isShowingDescription = widget.isShowingDescription;
    homeTransactionsCount = widget.homeTransactionsCount;
    _loadTheme();
    _initAppInfo();
  }

  void _loadTheme() async {
    final loadedTheme = await AppSettings.getTheme();
    setState(() {
      theme = loadedTheme;
    });
  }

  // get app info
  Future<void> _initAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appInfo = info;
    });
  }

  // open url in browser
  Future<void> _openWebsite(Uri url) async {
    if(!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      if(!mounted) return;
      showSnackBar(context: context, content: 'Could not launch url');
    }
  }

  // about app modal bottom sheet
  void _showAboutSheet() {
    showCustomModalBottomSheet(
      context: context, 
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: AboutBottomSheet(
        appInfo: _appInfo,
        openWebsite: _openWebsite,
      ),
    );
  }

  // categories manager modal bottom sheet
  void _showCategoriesManager() {
    showCustomModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      borderRadius: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: CategoriesManagerBottomSheet(
        db: widget.db, 
        showCategoryDeletetionPrompt: _showCategoryDeletetionPrompt, 
        showCategoryEditingSheet: _showCategoryEditingSheet, 
        showCategoryCreationSheet: _showCategoryCreationSheet,
      ),
    );
  }

  // category delete alert dialog
  void _showCategoryDeletetionPrompt(int categoryId) {
    showDialog(
      context: context, 
      builder: (context) => CustomAlertDialog(
        title: 'Delete category?', 
        content: 'Transactions will stay, but without a category.', 
        leftButtonLabel: 'Cancel', 
        rightButtonLabel: 'Delete', 
        leftButtonAction: () => Navigator.pop(context), 
        rightButtonAction: () {
          HapticFeedback.heavyImpact();
          widget.db.categoriesDao.deleteCategory(categoryId);
          Navigator.pop(context);
        }
      ),
    );
  }

  // category create modal bottom sheet
  void _showCategoryCreationSheet({
    required bool isIncome,
  }) {
    showCustomModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      borderRadius: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: CategoryCreateBottomSheet(
        db: widget.db,
        isIncome: isIncome,
      ),
    );
  }

  // edit category modal bottom sheet
  void _showCategoryEditingSheet(Category category) {
    showCustomModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      borderRadius: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: CategoryEditBottomSheet(
        db: widget.db,
        category: category,
      )
    );
  }

  // accounts list bottom sheet
  void _showAccountsSheet() {
    showCustomModalBottomSheet(
      context: context, 
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      borderRadius: 0,
      child: AccountsBottomSheet(
        context: context,
        db: widget.db,
        showAccountCreateSheet: _showAccountCreateSheet,
        showAccountEditSheet: _showAccountEditSheet,
        showAccountsArchiveSheet: _showAccountsArchiveSheet,
      ),
    );
  }

  // create account bottom sheet
  void _showAccountCreateSheet() {
    showCustomModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      borderRadius: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: AccountCreateBottomSheet(db: widget.db,)
    );
  }

  // account edit bottom sheet
  void _showAccountEditSheet(Account account) {
    showCustomModalBottomSheet(
      context: context, 
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      borderRadius: 0,
      child: AccountEditBottomSheet(db: widget.db, account: account,)
    );
  }

  // accounts archive bottom sheet
  void _showAccountsArchiveSheet() {
    showCustomModalBottomSheet(
      context: context, 
      backgroundColor: Theme.of(context).colorScheme.surface,
      borderRadius: 0,
      isScrollControlled: true,
      child: AccountsArchiveSheet(
        context: context,
        db: widget.db,
      )
    );
  }

  // light/system/dark button
  Widget _buildThemeSelectionButton({
    required ThemeMode? theme,
    required ThemeMode newTheme,
    required String label,
  }) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: theme == newTheme
          // active theme
          ? Colors.blue
          // inactive theme
          : Theme.of(context).colorScheme.primaryContainer
      ),
      onPressed: () {
        HapticFeedback.selectionClick();
        widget.setTheme(newTheme); // set new theme
        Navigator.pop(context);
      },
      child: Text(
        label,
        style: TextStyle(
          color: theme == newTheme
          ? Theme.of(context).colorScheme.secondary
          : Theme.of(context).colorScheme.onPrimary,
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StatefulBuilder(
          builder: (context, StateSetter setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // header
                  CustomHeader(
                    children: [
                      CustomIconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close)
                      ), 
                      const CustomHeaderTitle(title: 'Settings'),
                      const SizedBox(width: 48),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding:const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        spacing: 10,
                        children: [
                          // theme
                          const SectionHeader(
                            title: 'Appearance'
                          ),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 10,
                              children: [
                                _buildThemeSelectionButton(
                                  theme: theme, 
                                  newTheme: ThemeMode.light,
                                  label: 'Light',
                                ),
                                _buildThemeSelectionButton(
                                  theme: theme, 
                                  newTheme: ThemeMode.system,
                                  label: 'System',
                                ),
                                _buildThemeSelectionButton(
                                  theme: theme, 
                                  newTheme: ThemeMode.dark,
                                  label: 'Dark',
                                ),
                              ],
                            ),
                          ),
                          const SectionHeader(
                            title: 'Home'
                          ),
                          // home transactions count
                          CustomListTile(
                            title: 'Recent Transactions',
                            subtitle: Text(
                              'Number of transactions shown on the Home page',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 10,
                              children: [
                                // transactions counter
                                Text(
                                  '$homeTransactionsCount',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // decrease
                                CustomIconButton(
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  onPressed: () {
                                    final updated = widget.handleTransactionCount(-1);
                                    if(updated != null) {
                                      setState(() {
                                        homeTransactionsCount = updated;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.remove)
                                ),
                                // increase
                                CustomIconButton(
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  onPressed: () {
                                    final updated = widget.handleTransactionCount(1);
                                    if(updated != null) {
                                      setState(() {
                                        homeTransactionsCount = updated;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.add)
                                ),
                              ],
                            ),
                          ),
                          // transaction description switch
                          CustomListTile(
                            title: 'Show transaction description',
                            subtitle: Text(
                              'Display the description below each transaction',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            trailing: CustomSwitch(
                              value: isShowingDescription, 
                              onChanged: (bool value) {
                                setState(() {
                                  isShowingDescription = value;
                                });
                                widget.switchDescriptionState(value);
                                AppSettings.switchTransactionDescription(value);
                              }
                            ),
                          ),
                          const SectionHeader(
                            title: 'Preferences'
                          ),
                          // accounts
                          CustomListTile(
                            title: 'Accounts',
                            trailing: const CustomIcon(icon: Icons.chevron_right),
                            onTap: () => _showAccountsSheet(),
                          ),
                          // categories manager
                          CustomListTile(
                            title: 'Categories',
                            trailing: const CustomIcon(icon: Icons.chevron_right),
                            onTap: () => _showCategoriesManager(),
                          ),
                          // about
                          CustomListTile(
                            title: 'About',
                            trailing: const CustomIcon(icon: Icons.chevron_right),
                            onTap: () => _showAboutSheet(),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          }
        )
      )
    );
  }
}
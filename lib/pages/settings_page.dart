import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_budget/logic/app_settings.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/custom_switch.dart';
import 'package:open_budget/widgets/section_header.dart';

class SettingsPage extends StatefulWidget {
  final int homeTransactionsCount;
  final bool isShowingDescription;
  final void Function(ThemeMode newTheme) setTheme;
  final void Function(bool isShowingDescription) switchDescriptionState;
  final int? Function(int digit) handleTransactionCount;
  final VoidCallback showAccountsSheet;
  final VoidCallback showCategoriesManager;
  final VoidCallback showAboutSheet;

  const SettingsPage({
    super.key,
    required this.homeTransactionsCount,
    required this.isShowingDescription,
    required this.setTheme,
    required this.switchDescriptionState,
    required this.handleTransactionCount,
    required this.showAccountsSheet,
    required this.showCategoriesManager,
    required this.showAboutSheet,
  });
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool isShowingDescription;
  late int homeTransactionsCount;
  ThemeMode? theme;

  @override
  void initState() {
    super.initState();
    isShowingDescription = widget.isShowingDescription;
    homeTransactionsCount = widget.homeTransactionsCount;
    _loadTheme();
  }

  void _loadTheme() async {
    final loadedTheme = await AppSettings.getTheme();
    setState(() {
      theme = loadedTheme;
    });
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
                            tileColor: Theme.of(context).colorScheme.primaryContainer, 
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
                            tileColor: Theme.of(context).colorScheme.primaryContainer,
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
                            tileColor: Theme.of(context).colorScheme.primaryContainer, 
                            title: 'Accounts',
                            trailing: const CustomIcon(icon: Icons.chevron_right),
                            onTap: () => widget.showAccountsSheet(),
                          ),
                          // categories manager
                          CustomListTile(
                            tileColor: Theme.of(context).colorScheme.primaryContainer,
                            title: 'Categories',
                            trailing: const CustomIcon(icon: Icons.chevron_right),
                            onTap: () => widget.showCategoriesManager(),
                          ),
                          // about
                          CustomListTile(
                            tileColor: Theme.of(context).colorScheme.primaryContainer,
                            title: 'About',
                            trailing: const CustomIcon(icon: Icons.chevron_right),
                            onTap: () => widget.showAboutSheet(),
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
import 'package:flutter/material.dart';
import 'package:open_budget/logic/currencies.dart';
import 'package:open_budget/logic/database/category_summary.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/format_number.dart';
import 'package:open_budget/models/additional_info_summary.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/custom_modal_bottom_sheet.dart';
import 'package:open_budget/widgets/date_time_picker.dart';
import 'package:open_budget/widgets/empty_list_placeholder.dart';
import 'package:open_budget/widgets/section_header.dart';
import 'package:open_budget/widgets/summary_widget.dart';

class StatisticsPage extends StatefulWidget {
  final AppDatabase db;
  final Account account;
  final Currency currentCurrency;

  const StatisticsPage({
    super.key,
    required this.db,
    required this.account,
    required this.currentCurrency,
  });

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String _periodButtonLabel = 'This month';
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();

  bool _isAdditionalInfoTileExpanded = false;

  // list of categories 
  Widget _buildCategoriesRankingList({
    required int accountOwnerId,
    required bool isIncome,
  }) {
    return StreamBuilder(
      stream: widget.db.categoriesDao.sortCategoriesByTotalAmount(
        accountOwnerId: accountOwnerId,
        isIncome: isIncome,
        startDate: _startDate,
        endDate: _endDate,
      ),
      builder: (context, snapshot) {
        final sortedCategories = snapshot.data ?? [];
        final lastThreeItems = sortedCategories.length < 3 
          ? sortedCategories
          : sortedCategories.take(3).toList();

        return Column(
          children: [
            ListView.builder(
              itemCount: lastThreeItems.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {

                final category = lastThreeItems[index];
                bool isFirst = index == 0
                  ? true 
                  : false;

                return _buildCategory(
                  isFirst: isFirst, 
                  isLast: false,
                  index: index, 
                  title: category.category.name, 
                  value: category.totalAmount,
                  percentage: category.percentage,
                );
              }
            ),
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.surface,
            ),
            sortedCategories.isEmpty
              ? EmptyListPlaceholder(
                color: Theme.of(context).colorScheme.primaryContainer,
                icon: Icons.receipt_long, 
                title: isIncome 
                  ? 'No top incomes'
                  : 'No top expenses', 
                subtitle: isIncome
                ? 'Add incomes and they will appear here'
                : 'Add expenses and they will appear here'
              )
              : CustomListTile(
                customBorder: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.zero,
                    bottom: Radius.circular(15),
                  )
                ),
                title: 'See All',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAllCategoriesRanking(
                  context: context, 
                  isIncome: isIncome,
                  categories: sortedCategories
                ),
              ),
          ],
        );
      }
    );
  }

  Widget _buildAdditionalInfo() {
    return StreamBuilder(
      stream: widget.db.transactionsDao.additionalInfoSummary(
        accountOwnerId: widget.account.id, 
        startDate: _startDate, 
        endDate: _endDate
      ), 
      builder: (context, snapshot) {
        final data = snapshot.data ?? 
          const AdditionalInfoSummary(
            totalTransactionsCount: 0, 
            incomeTransactionsCount: 0, 
            expenseTransactionsCount: 0,
            transferTransactionsCount: 0,
          );

        return ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          collapsedBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
          title: const Text(
            'Transactions',
            style: TextStyle(fontSize: 15),
          ),
          onExpansionChanged: (bool expanded) {
            setState(() {
              _isAdditionalInfoTileExpanded = expanded;
            });
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              // total transactions count
              Text(
                data.totalTransactionsCount.toString(),
                style: const TextStyle(fontSize: 15),
              ),
              AnimatedRotation(
                turns: _isAdditionalInfoTileExpanded ? 0.5 : 0.0, 
                duration: const Duration(milliseconds: 200),
                child: const CustomIcon(icon: Icons.expand_more),
              ),
            ],
          ),
          children: [
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.surface,
            ),
            // income transaction count
            CustomListTile(
              leading: const CustomIcon(icon: Icons.download_outlined),
              title: 'Incomes',
              trailing: Text(
                data.incomeTransactionsCount.toString(),
                style: const TextStyle(fontSize: 15),
              ),
            ),
            // expense transactions count
            CustomListTile(
              leading: const CustomIcon(icon: Icons.upload_outlined),
              title: 'Expenses',
              trailing: Text(
                data.expenseTransactionsCount.toString(),
                style: const TextStyle(fontSize: 15),
              ),
            ),
            // transfer transactions count
            CustomListTile(
              leading: const CustomIcon(icon: Icons.swap_horiz),
              title: 'Transfers',
              trailing: Text(
                data.transferTransactionsCount.toString(),
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ]
        );
      }
    );
  }

  // category custom list tile
  Widget _buildCategory({
    required bool isFirst,
    required bool isLast,
    required int index,
    required String title,
    required double value,
    required double percentage,
  }) {
    return CustomListTile(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          // top border 
          top: isFirst 
            // first in list so rounded corners
            ? const Radius.circular(15)
            // not first
            : Radius.zero,
          // bottom border
          bottom: isLast 
            // last in list so rounded corners
            ? const Radius.circular(15)
            // not last
            : Radius.zero
        )
      ),
      // category ranking number 
      leading: Text(
        '${index+1}.',
        style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onPrimary),
      ),
      // category name
      title: title,
      // amount of spent money in this category
      trailing: Text(
        '${formatNumber(value)} ${widget.currentCurrency.symbol} (${formatNumber(percentage)}%)',
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  // all categories ranking modal bottom sheet
  void _showAllCategoriesRanking({
    required BuildContext context,
    required bool isIncome,
    required List<CategorySummary> categories,
    }) {
    showCustomModalBottomSheet(
      context: context, 
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          CustomHeader(
            children: [
              CustomIconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close)
              ),
              CustomHeaderTitle(                
                title: isIncome
                  ? 'Top Income Categories'
                  : 'Top Expense Categories'
              ),
              const SizedBox(width: 48),
            ],
          ),
          Expanded(
            child: ListView.separated(
              itemCount: categories.length,
              padding:const EdgeInsets.symmetric(horizontal: 15),
              separatorBuilder: (context, index) => const SizedBox(height: 1),
              itemBuilder: (context, index) {
                final category = categories[index];
                
                bool isFirst = index == 0
                  ? true 
                  : false;
                bool isLast = index == categories.length - 1
                  ? true
                  : false;

                return _buildCategory(
                  isFirst: isFirst, 
                  isLast: isLast,
                  index: index, 
                  title: category.category.name, 
                  value: category.totalAmount,
                  percentage: category.percentage,
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  // periods for statistics
  void _showPeriodsSheet() {
    showCustomModalBottomSheet(
      context: context, 
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Wrap(
        children: [
          CustomHeader(
            children: [
              CustomIconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close)
              ),
              const CustomHeaderTitle(
                title: 'Period'
              ),
              const SizedBox(width: 48),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              spacing: 5,
              children: [
                // this month
                CustomListTile(
                  leading: const CustomIcon(icon: Icons.calendar_today),
                  title: 'This month',
                  onTap: () {
                    final now = DateTime.now();
                    Navigator.pop(context);
                    setState(() {
                      _periodButtonLabel = 'This month';
                      _startDate = DateTime(now.year, now.month, 1);
                      _endDate = DateTime(now.year, now.month + 1, 0);
                    });
                  },
                ),
                // previous month
                CustomListTile(
                  leading: const CustomIcon(icon: Icons.calendar_month),
                  title: 'Previous month',
                  onTap: () {
                    final now = DateTime.now();
                    Navigator.pop(context);
                    setState(() {
                      _periodButtonLabel = 'Previous month';
                      _startDate = DateTime(now.year, now.month - 1, 1);
                      _endDate = DateTime(now.year, now.month, 0);
                    });
                  },
                ),
                // all time
                CustomListTile(
                  leading: const CustomIcon(icon: Icons.calendar_view_week_outlined),
                  title: 'All time',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {   
                      _periodButtonLabel = 'All time';
                      _startDate = DateTime(2000);
                      _endDate = DateTime.now();
                    });
                  },
                ),
                // custom period
                CustomListTile(
                  leading: const CustomIcon(icon: Icons.edit),
                  title: 'Custom period',
                  trailing: const CustomIcon(icon: Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(context);
                    final dateRange = await pickDateRange(context: context);

                    if(dateRange != null) {
                      setState(() {
                        // label in period button
                        // format dd.mm.yyyy - dd.mm.yyyy
                        _periodButtonLabel = 
                          '${dateRange.start.day.toString().padLeft(2, '0')}.'
                          '${dateRange.start.month.toString().padLeft(2, '0')}.'
                          '${dateRange.start.year} - '
                          '${dateRange.end.day.toString().padLeft(2, '0')}.'
                          '${dateRange.end.month.toString().padLeft(2, '0')}.'
                          '${dateRange.end.year}';
                        
                        _startDate = dateRange.start;
                        _endDate = DateTime(
                          dateRange.end.year,
                          dateRange.end.month,
                          dateRange.end.day,
                          23,
                          59,
                          59,
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // header
            CustomHeader(
              children: [
                CustomIconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)
                ), 
                FilledButton(
                  onPressed: () => _showPeriodsSheet(),
                  child: Row(
                    spacing: 5,
                    children: [
                      Text(
                        _periodButtonLabel, 
                        style: const TextStyle(color: Colors.white)
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    // summary
                    const SectionHeader(title: 'Summary'),
                    const SizedBox(height: 10),
                    SummaryWidget(
                      db: widget.db, 
                      account: widget.account, 
                      accountCurrency: widget.currentCurrency,
                      startDate: _startDate,
                      endDate: _endDate,
                    ),
                    // top expense categories
                    const SectionHeader(title: 'Top Expense Categories'),
                    const SizedBox(height: 10),
                    _buildCategoriesRankingList(
                      accountOwnerId: widget.account.id, 
                      isIncome: false,
                    ),
                    // top income categories
                    const SectionHeader(title: 'Top Income Categories'),
                    const SizedBox(height: 10),
                    _buildCategoriesRankingList(
                      accountOwnerId: widget.account.id, 
                      isIncome: true,
                    ),
                    // additional info (transactions count)
                    const SectionHeader(title: 'Additional Info'),
                    const SizedBox(height: 10),
                    _buildAdditionalInfo(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}
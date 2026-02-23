import 'package:flutter/material.dart';
import 'package:open_budget/logic/currency_manager.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/format_number.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/custom_modal_bottom_sheet.dart';
import 'package:open_budget/widgets/date_time_picker.dart';
import 'package:open_budget/widgets/empty_list_placeholder.dart';
import 'package:open_budget/widgets/section_header.dart';

class StatisticsPage extends StatefulWidget {
  final AppDatabase db;

  const StatisticsPage({
    super.key,
    required this.db,
  });
  @override
  State<StatisticsPage> createState() => _StatisticsPage();
}

class _StatisticsPage extends State<StatisticsPage> {
  String periodButtonLabel = 'All Time';
  DateTime startDate = DateTime(2000);
  DateTime endDate = DateTime.now();

  // top 3 categories 
  Widget _buildCategoriesRankingList({
    required AppDatabase db,
    required bool isIncome,
    }) {
    return StreamBuilder(
      stream: db.sortCategoriesByTotalAmount(
        isIncome: isIncome,
        startDate: startDate,
        endDate: endDate,
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
                  index: index, 
                  title: category.key.name, 
                  value: category.value,
                );
              }
            ),
            Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
            sortedCategories.isEmpty
              ? EmptyListPlaceholder(
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

  // top income or expense categories ranking (full list)
  void _showAllCategoriesRanking({
    required BuildContext context,
    required bool isIncome,
    required List<MapEntry<Category, double>> categories,
    }) {
    showCustomModalBottomSheet(
      context: context, 
      child: Wrap(
        runSpacing: 10,
        children: [
          CustomHeader(
            startWidget: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.white
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close)
            ),
            title: isIncome
              ? 'Top Income Categories'
              : 'Top Expense Categories'
          ),
          ListView.builder(
            itemCount: categories.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {

              final category = categories[index];
              bool isFirst = index == 0
                ? true 
                : false;

              return _buildCategory(
                isFirst: isFirst, 
                index: index, 
                title: category.key.name, 
                value: category.value
              );
            }
          ),
        ],
      ),
    );
  }

  // category custom list tile
  Widget _buildCategory({
    required bool isFirst,
    required int index,
    required String title,
    required double value,
  }) {
    return CustomListTile(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: isFirst 
            ? const Radius.circular(15)
            : Radius.zero,
          bottom: Radius.zero,
        )
      ),
      leading: Text(
        '${index+1}.',
        style: const TextStyle(fontSize: 15, color: Colors.black54),
      ),
      title: title,
      trailing: Text(
        '${formatNumber(value)} ${CurrencyManager.currentCurrency!.symbol}',
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  // choose period for statistics
  void _showPeriodMenuSheet() {
    showCustomModalBottomSheet(
      context: context, 
      child: Wrap(
        runSpacing: 10,
        children: [
          // header
          CustomHeader(
            startWidget: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.white
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close)
            ),
            title: 'Period',
          ),
          // all time
          CustomListTile(
            leading: const Icon(Icons.all_inclusive),
            title: 'All Time',
            onTap: () {
              setState(() {
                periodButtonLabel = 'All Time';
                startDate = DateTime(2000);
                endDate = DateTime.now();
              });
              Navigator.pop(context);
            },
          ),
          // this month
          CustomListTile(
            leading: const Icon(Icons.calendar_today),
            title: 'This Month',
            onTap: () {
              final now = DateTime.now();
              setState(() {
                periodButtonLabel = 'This Month';
                startDate = DateTime(now.year, now.month, 1); // first day of this month
                endDate = DateTime(now.year, now.month + 1, 0); // first day of next month
              });
              Navigator.pop(context);
            },
          ),
          // previous month
          CustomListTile(
            leading: const Icon(Icons.calendar_month),
            title: 'Previous Month',
            onTap: () {
              final now = DateTime.now();
              setState(() {
                periodButtonLabel = 'Previous Month';
                startDate = DateTime(now.year, now.month - 1, 1); // first day of previous month
                endDate = DateTime(now.year, now.month, 0); // first day of this month
              });
              Navigator.pop(context);
            },
          ),
          // custom period
          CustomListTile(
            leading: const Icon(Icons.tune),
            title: 'Custom Period',
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              Navigator.pop(context);
              final dateRange = await pickDateRange(context: context);

              if(dateRange != null) {
                setState(() {
                  // label in period button
                  // format dd.mm.yyyy - dd.mm.yyyy
                  periodButtonLabel = 
                    '${dateRange.start.day.toString().padLeft(2, '0')}.'
                    '${dateRange.start.month.toString().padLeft(2, '0')}.'
                    '${dateRange.start.year} - '
                    '${dateRange.end.day.toString().padLeft(2, '0')}.'
                    '${dateRange.end.month.toString().padLeft(2, '0')}.'
                    '${dateRange.end.year}';

                  // start date
                  startDate = dateRange.start; 
                  // end date including last day
                  endDate = DateTime(
                    dateRange.end.year,
                    dateRange.end.month,
                    dateRange.end.day,
                    23,
                    59,
                    59,
                    999,
                  );
                });
              }
            },
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // period button
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              onPressed: () => _showPeriodMenuSheet(), 
              child: Text(periodButtonLabel),
            ),
            const SizedBox(height: 10),
            // top income categories section
            const SectionHeader(
              title: 'Top Income Categories'
            ),
            const SizedBox(height: 10),
            _buildCategoriesRankingList(
              db: widget.db,
              isIncome: true,
            ),
            const SizedBox(height: 10),
            // top expense categories section
            const SectionHeader(
              title: 'Top Expense Categories'
            ),
            const SizedBox(height: 10),
            _buildCategoriesRankingList(
              db: widget.db, 
              isIncome: false,
            ),
          ],
        ),
      )
    );
  }
}
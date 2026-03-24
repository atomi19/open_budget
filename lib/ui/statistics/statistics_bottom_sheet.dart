import 'package:flutter/material.dart';
import 'package:open_budget/logic/currencies.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/format_number.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/custom_modal_bottom_sheet.dart';
import 'package:open_budget/widgets/empty_list_placeholder.dart';
import 'package:open_budget/widgets/section_header.dart';

class StatisticsBottomSheet extends StatelessWidget {
  final BuildContext context;
  final AppDatabase db;
  final Currency currentCurrency;
  final int accountOwnerId;

  const StatisticsBottomSheet({
    super.key,
    required this.context,
    required this.db,
    required this.currentCurrency,
    required this.accountOwnerId,
  });

  // list of categories 
  Widget _buildCategoriesRankingList({
    required int accountOwnerId,
    required bool isIncome,
  }) {
    return StreamBuilder(
      stream: db.categoriesDao.sortCategoriesByTotalAmount(
        accountOwnerId: accountOwnerId,
        isIncome: isIncome,
        startDate: DateTime(2000),
        endDate: DateTime(2000),
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
                  title: category.key.name, 
                  value: category.value,
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
                tileColor: Theme.of(context).colorScheme.primaryContainer,
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

  // all categories ranking modal bottom sheet
  void _showAllCategoriesRanking({
    required BuildContext context,
    required bool isIncome,
    required List<MapEntry<Category, double>> categories,
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
                  title: category.key.name, 
                  value: category.value
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  // category custom list tile
  Widget _buildCategory({
    required bool isFirst,
    required bool isLast,
    required int index,
    required String title,
    required double value,
  }) {
    return CustomListTile(
      tileColor: Theme.of(context).colorScheme.primaryContainer,
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
        '${formatNumber(value)} ${currentCurrency.symbol}',
        style: const TextStyle(fontSize: 15),
      ),
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
            const CustomHeaderTitle(title: 'Statistics'),
            const SizedBox(width: 48),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const SectionHeader(
                  title: 'Top Income Categories'
                ),
                const SizedBox(height: 5),
                _buildCategoriesRankingList(
                  accountOwnerId: accountOwnerId, 
                  isIncome: true,
                ),
                const SectionHeader(
                  title: 'Top Expense Categories'
                ),
                const SizedBox(height: 5),
                _buildCategoriesRankingList(
                  accountOwnerId: accountOwnerId, 
                  isIncome: false,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
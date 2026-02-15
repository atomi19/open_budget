import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/format_number.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/custom_modal_bottom_sheet.dart';
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
  // top 3 categories 
  Widget _buildCategoriesRankingList({
    required AppDatabase db,
    required bool isIncome,
    }) {
    return StreamBuilder(
      stream: db.sortCategoriesByTotalAmount(isIncome: isIncome), 
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
                
                // do not display categories with total amount 0
                if(category.value == 0) return null;

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
            CustomListTile(
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
        formatNumber(value),
        style: const TextStyle(fontSize: 15),
      ),
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
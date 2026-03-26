import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/empty_list_placeholder.dart';

class CategoriesBottomSheet extends StatelessWidget {
  final AppDatabase db;
  final bool isIncome;
  final Transaction item;

  const CategoriesBottomSheet({
    super.key,
    required this.db,
    required this.isIncome,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // header
        CustomHeader(
          children: [
            CustomIconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close)
            ),
            const CustomHeaderTitle(title: 'Change category'),
            const SizedBox(width: 48),
          ]
        ),
        // categories
        Expanded(
          child: ListView(
            children: [
              StreamBuilder(
                stream: db.categoriesDao.watchIncomeOrExpenseCategories(isIncome),
                builder: (context, snapshot) {
                  final items = snapshot.data ?? [];
                  return items.isEmpty
                  ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: EmptyListPlaceholder(
                      color: Theme.of(context).colorScheme.surface,
                      icon: Icons.close_rounded, 
                      title: 'No categories yet', 
                      subtitle: 'Create category first'
                    )
                  )
                  : ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemBuilder: (context, index) {
                      final category = items[index];

                      return CustomListTile(
                        tileColor: Theme.of(context).colorScheme.primaryContainer, 
                        leading: CustomIcon(icon: IconsManager.categoryIcons[category.iconName]!),
                        title: category.name,
                        trailing: category.id == item.categoryId
                          ? const Icon(Icons.done)
                          : null,
                        onTap: () {
                          // if user selects same category as current transaction category just return
                          if(item.categoryId == category.id) return;
                          // update transaction category
                          db.transactionsDao.updateTransactionCategoryId(item.id, category.id);
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                      );
                    }
                  );
                }
              ),
            ],
          ),
        )
      ],
    );
  }
}
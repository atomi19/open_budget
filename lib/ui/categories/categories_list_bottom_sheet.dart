// categories list on Add Transaction page

import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/empty_list_placeholder.dart';

class CategoriesListBottomSheet extends StatelessWidget {
  final AppDatabase db;
  final bool isIncome;
  final Function(int index) onTap;

  const CategoriesListBottomSheet({
    super.key,
    required this.db,
    required this.isIncome,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // header
        CustomHeader(
          children: [
            // close button
            CustomIconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close)
            ),
            const CustomHeaderTitle(
              title: 'Choose a category'
            ),
            const SizedBox(width: 48),
          ],
        ),
        // categories list
        Expanded(
          child: StreamBuilder(
            stream: db.categoriesDao.watchIncomeOrExpenseCategories(isIncome),
            builder: (context, snapshot) {
              final items =snapshot.data ?? [];
              return items.isEmpty
              ? EmptyListPlaceholder(
                  color: Theme.of(context).colorScheme.surface,
                  icon: Icons.close_rounded, 
                  title: 'No categories yet', 
                  subtitle: 'Create category first'
              )
              : ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 5),
                padding:const EdgeInsets.symmetric(horizontal: 15),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return CustomListTile(
                    tileColor: Theme.of(context).colorScheme.primaryContainer, 
                    leading: CustomIcon(icon: IconsManager.getCategoryIconByName(item.iconName)),
                    title: item.name,
                    onTap: () => onTap(item.id),
                  );
                }
              );
            }
          ),
        )
      ],
    );
  }
}
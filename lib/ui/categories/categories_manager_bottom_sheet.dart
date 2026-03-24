import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/empty_list_placeholder.dart';

class CategoriesManagerBottomSheet extends StatefulWidget {
  final AppDatabase db;
  final Function(int itemId) showCategoryDeletetionPrompt;
  final Function(Category item) showCategoryEditingSheet;
  final Function({required bool isIncome}) showCategoryCreationSheet;

  const CategoriesManagerBottomSheet({
    super.key,
    required this.db,
    required this.showCategoryDeletetionPrompt,
    required this.showCategoryEditingSheet,
    required this.showCategoryCreationSheet,
  });

  @override
  State<CategoriesManagerBottomSheet> createState() => _CategoriesManagerBottomSheetState();
}

class _CategoriesManagerBottomSheetState extends State<CategoriesManagerBottomSheet> {
  bool isIncome = true;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            // header
            CustomHeader(
              children: [
                CustomIconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)
                ),
                const CustomHeaderTitle(title: 'Categories'),
                const SizedBox(width: 48),
              ],
            ),
            Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        backgroundColor: isIncome
                          ? Colors.blue
                          : Theme.of(context).colorScheme.primaryContainer,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20
                        )
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          isIncome = true;
                        });
                      },
                      child:Text(
                        'Income categories',
                        style: TextStyle(
                          color: isIncome 
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.onPrimary
                        ),
                      )
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        backgroundColor: isIncome
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20
                        )
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          isIncome = false;
                        });
                      },
                      child: Text(
                        'Expense categories',
                        style: TextStyle(
                          color: isIncome 
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.secondary
                        ),
                      )
                    ),
                  )
                ],
              ),
            ),
            // income or expense categories
            Expanded(
              child: StreamBuilder(
                stream: widget.db.categoriesDao.watchIncomeOrExpenseCategories(isIncome),
                builder: (context, snapshot) {
                  final items =snapshot.data ?? [];
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
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    separatorBuilder: (context, index) => const SizedBox(height: 5),
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return CustomListTile(
                        tileColor: Theme.of(context).colorScheme.primaryContainer,
                        leading: CustomIcon(icon: IconsManager.getCategoryIconByName(item.iconName)),
                        title: item.name,
                        trailing: IconButton(
                          onPressed: () => widget.showCategoryDeletetionPrompt(item.id),
                          icon: const Icon(Icons.delete_outlined)
                        ),
                        onTap: () => widget.showCategoryEditingSheet(item),
                      );
                    }
                  );
                }
              ),
            ),
            // create category button
            FilledButton(
              onPressed: () => widget.showCategoryCreationSheet(isIncome: isIncome), 
              child: Text(
                'Create category',
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              )
            ),
          ],
        );
      }
    );
  }
}
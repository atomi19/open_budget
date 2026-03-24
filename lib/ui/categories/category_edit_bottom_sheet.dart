import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_text_field.dart';

class CategoryEditBottomSheet extends StatefulWidget {
  final AppDatabase db;
  final Category category;
  const CategoryEditBottomSheet({
    super.key,
    required this.db,
    required this.category,
  });

  @override
  State<CategoryEditBottomSheet> createState() => _CategoryEditBottomSheetState();
}

class _CategoryEditBottomSheetState extends State<CategoryEditBottomSheet> {
  String? selectedIcon;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.category.name);
    selectedIcon = widget.category.iconName;
  }

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
                const CustomHeaderTitle(title: 'Edit'),
                // confirm category changes button
                CustomIconButton(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    final categoryName = controller.text.trim();

                    if(categoryName.isEmpty || selectedIcon == null) return;

                    // update in db
                    widget.db.categoriesDao.updateCategoryName(widget.category.id, categoryName);
                    widget.db.categoriesDao.updateCategoryIcon(widget.category.id, selectedIcon!);

                    Navigator.pop(context);
                  }, 
                  icon: Icon(Icons.done_rounded, color: Theme.of(context).colorScheme.primaryContainer),
                ),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    // edit name text field
                    CustomTextField(
                      controller: controller, 
                      hintText: 'Edit category name'
                    ),
                    const SizedBox(height: 10),
                    // edit icon
                    ExpansionTile(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      collapsedBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      title: const Text('Icon'),
                      trailing: selectedIcon != null
                        ? CustomIcon(icon: IconsManager.getCategoryIconByName(selectedIcon!))
                        : const CustomIcon(icon: Icons.arrow_drop_down_rounded),
                      childrenPadding: const EdgeInsets.all(10),
                      children: [
                        SizedBox(
                          height: 150,
                          child: GridView.builder(
                            shrinkWrap: true,
                            itemCount: IconsManager.categoriesKeys.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 2,
                              crossAxisSpacing: 2,
                            ), 
                            itemBuilder: (context, index) {
                              return IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectedIcon = IconsManager.categoriesKeys[index];
                                  });
                                },
                                icon: CustomIcon(icon: IconsManager.getCategoryIconByName(IconsManager.categoriesKeys[index])),
                                iconSize: 25,
                                padding: EdgeInsets.zero,
                              );
                            }
                          )
                        )
                      ]
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      }
    );
  }
}
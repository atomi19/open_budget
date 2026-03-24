import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/icons_manager.dart';
import 'package:open_budget/widgets/custom_header.dart';
import 'package:open_budget/widgets/custom_header_title.dart';
import 'package:open_budget/widgets/custom_icon.dart';
import 'package:open_budget/widgets/custom_icon_button.dart';
import 'package:open_budget/widgets/custom_text_field.dart';
import 'package:open_budget/widgets/show_snack_bar.dart';
import 'package:open_budget/widgets/submit_button.dart';

class CategoryCreateBottomSheet extends StatefulWidget {
  final AppDatabase db;
  final bool isIncome;
  const CategoryCreateBottomSheet({
    super.key,
    required this.db,
    required this.isIncome,
  });

  @override
  State<CategoryCreateBottomSheet> createState() => _CategoryCreateBottomSheetState();
}

class _CategoryCreateBottomSheetState extends State<CategoryCreateBottomSheet> {
  final TextEditingController categoryNameController = TextEditingController();
  String? selectedIcon;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, StateSetter setState) {
        return Column(
          children: [
            // header
            CustomHeader(
              children: [
                CustomIconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)
                ),
                CustomHeaderTitle(                    
                  title: widget.isIncome
                    ? 'Create income category'
                    : 'Create expense category',
                ),
                const SizedBox(width: 48),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    // category name
                    CustomTextField(
                      controller: categoryNameController,
                      maxLines: 1,
                      hintText: 'Enter category name...'
                    ),
                    const SizedBox(height: 10),
                    // expansion tile with icons for custom categories 
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
                    const SizedBox(height: 10),
                    // submit button
                    SubmitButton(
                      onTap: () async {
                        if(categoryNameController.text.trim().isNotEmpty &&
                          selectedIcon != null) {
                          Navigator.pop(context);
                          await widget.db.categoriesDao.addCategory(
                            name: categoryNameController.text,
                            isIncome: widget.isIncome,
                            iconName: selectedIcon!
                          );
                        } else {
                          showSnackBar(
                            context: context, 
                            content: const Text('Enter category name'),
                          );
                        }
                      }, 
                      text: 'Create'
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}
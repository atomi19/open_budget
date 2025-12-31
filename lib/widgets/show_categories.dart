// show separate categories for income and expense (used inside income and expense screens)
import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';

void showCategories({
  required BuildContext context,
  required bool isIncome,
  required List<Category> categories,
  required Function(int index) onTap,
}) {
  showModalBottomSheet(
    context: context, 
    backgroundColor: Colors.grey.shade200,
    shape:const RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(15))
    ),
    builder: (context) {
      return Column(
        spacing: 10,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey.shade200,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)
                ),
                Text(
                  isIncome
                  ? 'Select income category'
                  : 'Select expense category',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(                
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      CustomListTile(
                        leading: Icon(
                          // use icon code point
                          IconData(
                            categories[index].iconCodePoint,
                            fontFamily: 'MaterialIcons'
                          ),
                          color: Colors.blue,
                          weight: 1,
                        ),
                        title: categories[index].name,
                        onTap: () => onTap(index),
                      ),
                      const SizedBox(height: 5),
                    ],
                  );
                }
              ),
            )
          )
        ],
      );
    }
  );
}
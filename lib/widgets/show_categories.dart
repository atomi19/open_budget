// show categories based on category list (used in income and expense screens)
import 'package:flutter/material.dart';

void showCategories({
  required BuildContext context,
  required bool isIncome,
  required List<Map<String, dynamic>> categories,
  required Function(int index) onTap,
}) {
  showModalBottomSheet(
    context: context, 
    backgroundColor: Colors.grey.shade200,
    shape:const RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(15))
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          spacing: 10,
          children: [
            Row(
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
            Expanded(                
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)
                        ),
                        leading: Icon(
                          categories[index]['icon'],
                          color: Colors.blue,
                          weight: 1,
                        ),
                        title: Text(categories[index]['name']),
                        onTap: () => onTap(index),
                      ),
                      const SizedBox(height: 5),
                    ],
                  );
                }
              ),
            )
          ],
        ),
      );
    }
  );
}
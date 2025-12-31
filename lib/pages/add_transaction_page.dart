// main page that contains income and expense screens (switch between them)
import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/pages/screens/expense_screen.dart';
import 'package:open_budget/pages/screens/income_screen.dart';
import 'package:open_budget/widgets/custom_text_field.dart';
import 'package:open_budget/widgets/show_snack_bar.dart';
import 'package:open_budget/widgets/submit_button.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionsDatabase db;

  const AddTransactionPage({
    super.key,
    required this.db,
  });
  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  int _transactionPageIndex = 0; // 0 - income page, 1 - spending page
  final TextEditingController _categoryNameController = TextEditingController();

  IconData? _selectedIcon;

  // icons for custom categories
  final _categoryIcons = [
    Icons.restaurant_outlined,
    Icons.local_cafe_outlined,
    Icons.local_grocery_store_outlined,
    Icons.fastfood_outlined,

    Icons.directions_car_outlined,
    Icons.directions_bus_outlined,
    Icons.train_outlined,
    Icons.flight_outlined,

    Icons.home_outlined,
    Icons.lightbulb_outlined,
    Icons.water_drop_outlined,
    Icons.wifi_outlined,

    Icons.shopping_cart_outlined,
    Icons.shopping_bag_outlined,
    Icons.checkroom_outlined,
    Icons.watch_outlined,

    Icons.work_outlined,
    Icons.account_balance_outlined,
    Icons.credit_card_outlined,
    Icons.receipt_long_outlined,

    Icons.trending_up_outlined,
    Icons.favorite_outlined,
    Icons.local_hospital_outlined,
    Icons.fitness_center_outlined,

    Icons.pets_outlined,
    Icons.school_outlined,
    Icons.card_giftcard_outlined,
    Icons.movie_outlined,
  ];

  void _showCategories({
    required bool isIncome,
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
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              // header
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
                child: ListView(
                  children: [
                    StreamBuilder(
                      stream: isIncome
                      ? widget.db.watchIncomeOrExpenseCategories(isIncome)
                      : widget.db.watchIncomeOrExpenseCategories(isIncome),
                      builder: (context, snapshot) {
                        final items =snapshot.data ?? [];
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Column(
                              children: [
                                ListTile(
                                  tileColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)
                                  ),
                                  leading: Icon(IconData(item.iconCodePoint, fontFamily: 'MaterialIcons'), color: Colors.blue,),
                                  title: Text(item.name),
                                  trailing: IconButton(
                                    onPressed: () => widget.db.deleteCategory(item.id),
                                    icon: const Icon(Icons.delete_outlined)
                                  ),
                                  onTap: () => onTap(item.id),
                                ),
                                const SizedBox(height: 5),
                              ],
                            );
                          }
                        );
                      }
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white
                      ),
                      onPressed: () => _showCategoryCreationSheet(isIncome: isIncome), 
                      child: const Text('Create category', style: TextStyle(decoration: TextDecoration.underline),)
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }
    );
  }

  void _showCategoryCreationSheet({
    required bool isIncome,
  }) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.grey.shade200,
      shape:const RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(15))
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                spacing: 10,
                children: [
                  // header
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
                        ? 'Create income category'
                        : 'Create expense category',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  CustomTextField(
                    controller: _categoryNameController,
                    hintText: 'Enter category name...'
                  ),
                  // expansion tile with icons for custom categories 
                  ExpansionTile(
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: const Text('Icon'),
                    trailing: _selectedIcon != null
                    ? Icon(_selectedIcon)
                    : const Icon(Icons.arrow_drop_down_rounded),
                    childrenPadding: const EdgeInsets.all(10),
                    children: [
                      SizedBox(
                        height: 150,
                        child: GridView.builder(
                          shrinkWrap: true,
                          itemCount: _categoryIcons.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 2,
                            crossAxisSpacing: 2,
                          ), 
                          itemBuilder: (context, index) {
                            return IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedIcon = _categoryIcons[index];
                                });
                              },
                              icon: Icon(_categoryIcons[index]),
                              iconSize: 25,
                              padding: EdgeInsets.zero,
                            );
                          }
                        )
                      )
                    ]
                  ),
                  // submit button
                  SubmitButton(
                    onTap: () async {
                      if(_categoryNameController.text.trim().isNotEmpty &&
                        _selectedIcon != null) {
                        Navigator.pop(context);
                        await widget.db.addCategory(
                          name: _categoryNameController.text,
                          isIncome: isIncome,
                          iconCodePoint: _selectedIcon!.codePoint,
                        );
                      } else {
                        showSnackBar(
                          context: context, 
                          content: 'Enter category name'
                        );
                      }
                    }, 
                    text: 'Create'
                  ),
                ],
              ),
            );
          }
        );
      }
    ).then((_) {
      _categoryNameController.clear();
      _selectedIcon = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body:  Column(
        spacing: 10,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: _transactionPageIndex == 0
                    ? Colors.blue
                    : Colors.transparent
                  ),
                  onPressed: () => setState(() => _transactionPageIndex = 0), 
                  child: Text(
                    'Income',
                    style: TextStyle(color: _transactionPageIndex == 0
                    ? Colors.white
                    : Colors.black
                    ),
                  )
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: _transactionPageIndex == 1
                    ? Colors.blue
                    : Colors.transparent
                  ),
                  onPressed: () => setState(() => _transactionPageIndex = 1), 
                  child: Text(
                    'Expense', 
                    style: TextStyle(color: _transactionPageIndex ==1
                    ? Colors.white
                    : Colors.black
                    )
                  )
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _transactionPageIndex,
              children: [
                IncomeScreen(
                  db: widget.db,
                  showCategories: _showCategories,
                ),
                ExpenseScreen(
                  db: widget.db,
                  showCategories: _showCategories,
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}
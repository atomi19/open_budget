// main page that contains income and expense screens (switch between them)
import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/handle_data_submit.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/custom_modal_bottom_sheet.dart';
import 'package:open_budget/widgets/custom_text_field.dart';
import 'package:open_budget/widgets/date_time_picker.dart';
import 'package:open_budget/widgets/empty_list_placeholder.dart';
import 'package:open_budget/widgets/show_snack_bar.dart';
import 'package:open_budget/widgets/submit_button.dart';

class AddTransactionPage extends StatefulWidget {
  final AppDatabase db;

  const AddTransactionPage({
    super.key,
    required this.db,
  });
  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  int _transactionPageIndex = 0; // 0 - income page, 1 - spending page

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Category? _selectedCategory;
  int? _selectedCategoryId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // reset all variables for _transactionAddForm
  void _resetData() {
    setState(() {
      _amountController.clear();
      _selectedDate = null;
      _selectedTime = null;
      _selectedCategory = null;
      _selectedCategoryId = null;
      _descriptionController.clear();
    });
  }

  Future _findCategoryById(int id) async {
    _selectedCategory = await widget.db.getCategoryById(id);
  }

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

  // list income or expense categories
  void _showCategories({
    required bool isIncome,
    required Function(int index) onTap,
  }) {
    showCustomModalBottomSheet(
      context: context, 
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
                    return items.isEmpty
                    ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: EmptyListPlaceholder(
                        icon: Icons.close_rounded, 
                        title: 'No categories yet', 
                        subtitle: 'Create category first'
                      )
                    )
                    : ListView.builder(
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
                const SizedBox(height: 10),
                SubmitButton(
                  onTap: () => _showCategoryCreationSheet(isIncome: isIncome), 
                  text: 'Create category'
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // category creation modalBottomSheet
  void _showCategoryCreationSheet({
    required bool isIncome,
  }) {
    final TextEditingController categoryNameController = TextEditingController();
    IconData? selectedIcon;
    showCustomModalBottomSheet(
      context: context, 
      child: StatefulBuilder(
        builder: (context, StateSetter setState) {
          return Column(
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
                controller: categoryNameController,
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
                trailing: selectedIcon != null
                ? Icon(selectedIcon)
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
                              selectedIcon = _categoryIcons[index];
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
                  if(categoryNameController.text.trim().isNotEmpty &&
                    selectedIcon != null) {
                    Navigator.pop(context);
                    await widget.db.addCategory(
                      name: categoryNameController.text,
                      isIncome: isIncome,
                      iconCodePoint: selectedIcon!.codePoint,
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
          );
        }
      )
    );
  }

  // income or expense form
  Widget _transactionAddForm({
    required bool isIncome
  }) {
    return Column(
      spacing: 10,
      children: [
        // amount textfield
        CustomTextField(
          controller: _amountController, 
          hintText: isIncome
            ? 'Enter income...'
            : 'Enter expense...',
          prefix: Text(
            isIncome
              ? '+ '
              : '- '
          ),
          maxLines: 1,
        ),
        // date 
        CustomListTile(
          title: _selectedDate != null
            ? '${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}'
            : 'Date',
          trailing: const Icon(Icons.arrow_drop_down_rounded),
          onTap: ()async {
            final selectedDate = await pickDate(context);
            setState(() {
              _selectedDate = selectedDate;
            });
          },
        ),
        // time 
        CustomListTile(
          title: _selectedTime != null
            ? _selectedTime!.format(context)
            : 'Time',
          trailing: const Icon(Icons.arrow_drop_down_rounded),
          onTap: () async {
            final selectedTime = await pickTime(context);
            setState(() {
              _selectedTime = selectedTime;
            });
          },
        ),
        // category
        CustomListTile(
          title: _selectedCategory?.name ?? 'Category',
          trailing: const Icon(Icons.arrow_drop_down_rounded),
          onTap: () => _showCategories(
            isIncome: isIncome,
            onTap: (id) async {
              setState(() {
                _selectedCategoryId = id;
              });
              Navigator.pop(context);
              await _findCategoryById(id);
            }
          ),
        ),
        // description textfield
        CustomTextField(
          controller: _descriptionController,
          hintText: 'Enter description...',
          minLines: 1,
          maxLines: 5,
        ),
        // save button
        SubmitButton(
          onTap: () => handleDataSubmit(
            db: widget.db, 
            displaySnackBar: (content) => showSnackBar(context: context, content: Text(content)),
            amountStr: isIncome
            ? _amountController.text // income amount
            : '-${_amountController.text}', // expense amount
            selectedDate: _selectedDate, 
            selectedTime: _selectedTime, 
            categoryId: _selectedCategoryId, 
            descriptionController: _descriptionController, 
            clearInputData: _resetData
          ),
          text: 'Save'
        ),
      ],
    );
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
                  onPressed: () {
                    if(_transactionPageIndex != 0)  {
                      _resetData();
                      setState(() => _transactionPageIndex = 0);
                    }
                  },
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
                  onPressed: () {
                    if(_transactionPageIndex != 1) {
                      _resetData();
                      setState(() => _transactionPageIndex = 1);
                    }
                  },
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
                // income form
                _transactionAddForm(isIncome: true),
                // expense form
                _transactionAddForm(isIncome: false),
              ],
            ),
          ),
        ],
      )
    );
  }
}
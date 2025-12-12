import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/handle_data_submit.dart';
import 'package:open_budget/widgets/custom_text_field.dart';
import 'package:open_budget/widgets/date_time_picker.dart';
import 'package:open_budget/widgets/show_categories.dart';
import 'package:open_budget/widgets/show_snack_bar.dart';
import 'package:open_budget/widgets/submit_button.dart';

class ExpenseScreen extends StatefulWidget {
  final TransactionsDatabase db;

  const ExpenseScreen({
    super.key,
    required this.db,
  });
  @override
  ExpenseScreenState createState() => ExpenseScreenState();
}

class ExpenseScreenState extends State<ExpenseScreen> {
  final TextEditingController _expenseController = TextEditingController();
  final TextEditingController _expenseDescriptionController = TextEditingController();

  static const List<Map<String, dynamic>> _expenseCategories = [
    {
      'name': 'Rent / Mortgage',
      'icon': Icons.house_outlined,
      'type': 'expense'
    },
    {
      'name': 'Utilities (Water, Electricity, Gas)',
      'icon': Icons.water_drop_outlined,
      'type': 'expense'
    },
    {
      'name': 'Internet',
      'icon': Icons.wifi_outlined,
      'type': 'expense'
    },
    {
      'name': 'Fuel / Gas',
      'icon': Icons.gas_meter_outlined,
      'type': 'expense'
    },
    {
      'name': 'Public Transport',
      'icon': Icons.directions_transit_outlined,
      'type': 'expense'
    },
    {
      'name': 'Vehicle Maintenance',
      'icon': Icons.car_repair_outlined,
      'type': 'expense'
    },
    {
      'name': 'Groceries',
      'icon': Icons.local_grocery_store_outlined,
      'type': 'expense'
    },
    {
      'name': 'Restaurants / Cafes',
      'icon': Icons.restaurant_outlined,
      'type': 'expense'
    }
  ];

  String _selectedCategory = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  void _clearInputData() {
    setState(() {
      _expenseController.clear();
      _selectedDate = null;
      _selectedTime = null;
      _selectedCategory = '';
      _expenseDescriptionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        CustomTextField(
          controller: _expenseController, 
          hintText: 'Enter expense...',
          prefix: const Text('- '),
        ),
        // date 
        ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
          ),
          title: Text(
            _selectedDate != null
            ? '${_selectedDate!.day.toString().padLeft(2, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.year}'
            : 'Date'
          ),
          trailing: const Icon(Icons.arrow_drop_down_rounded),
          onTap: ()async {
            final selectedDate = await pickDate(context);
            setState(() {
              _selectedDate = selectedDate;
            });
          },
        ),
        // time
        ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
          ),
          title: Text(
            _selectedTime != null
            ? _selectedTime!.format(context)
            : 'Time'
          ),
          trailing: const Icon(Icons.arrow_drop_down_rounded),
          onTap: () async {
            final selectedTime = await pickTime(context);
            setState(() {
              _selectedTime = selectedTime;
            });
          },
        ),
        ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
          ),
          title: Text(
            _selectedCategory.isEmpty
            ? 'Category'
            : _selectedCategory
          ),
          trailing: const Icon(Icons.arrow_drop_down_rounded),
          onTap: () => showCategories(
            context: context, 
            isIncome: false, 
            categories: _expenseCategories, 
            onTap: (index) {
              Navigator.pop(context);
              setState(() {
                _selectedCategory = _expenseCategories[index]['name'];
              }); 
            }
          ),
        ),
        CustomTextField(
          controller: _expenseDescriptionController,
          hintText: 'Enter description...',
          minLines: 1,
          maxLines: 5,
        ),
        // save button
        SubmitButton(
          onTap: () => handleDataSubmit(
            db: widget.db, 
            displaySnackBar: (content) => showSnackBar(context: context, content: content),
            amountStr: '-${_expenseController.text}', // pass amount String with - because it is expense
            selectedDate: _selectedDate, 
            selectedTime: _selectedTime, 
            selectedCategory: _selectedCategory, 
            descriptionController: _expenseDescriptionController, 
            clearInputData: _clearInputData
          ),
          text: 'Save'
        ),
      ],
    );
  }
}

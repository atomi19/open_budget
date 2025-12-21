import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/handle_data_submit.dart';
import 'package:open_budget/widgets/custom_text_field.dart';
import 'package:open_budget/widgets/date_time_picker.dart';
import 'package:open_budget/widgets/show_categories.dart';
import 'package:open_budget/widgets/show_snack_bar.dart';
import 'package:open_budget/widgets/submit_button.dart';

class IncomeScreen extends StatefulWidget {
  final TransactionsDatabase db;

  const IncomeScreen({
    super.key,
    required this.db,
  });
  @override
  IncomeScreenState createState() => IncomeScreenState();
}

class IncomeScreenState extends State<IncomeScreen> {
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _incomeDescriptionControler = TextEditingController();

  static const List<Map<String, dynamic>> _incomeCategories = [
    {
      'name': 'Salary',
      'icon': Icons.paid_outlined,
      'type': 'income',
    },
    {
      'name': 'Freelance / Side Jobs',
      'icon': Icons.work_outlined,
      'type': 'income',
    },
    {
      'name': 'Investments',
      'icon': Icons.area_chart_outlined,
      'type': 'income',
    },
    {
      'name': 'Gifts',
      'icon': Icons.card_giftcard_outlined,
      'type': 'income',
    }
  ];

  String _selectedCategory = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  void _clearInputData() {
    setState(() {      
      _incomeController.clear();
      _selectedDate = null;
      _selectedTime = null;
      _selectedCategory = '';
      _incomeDescriptionControler.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      spacing: 10,
      children: [
        // income text field
        CustomTextField(
          controller: _incomeController,
          hintText: 'Enter income...',
          prefix:const Text('+ '),
          //minLines: 1,
          maxLines: 1,
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
          onTap: () async {
            final selectedDate = await pickDate(context);
            setState(() {
              _selectedDate = selectedDate;
            });
          }
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
          }
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
            isIncome: true, 
            categories: _incomeCategories, 
            onTap: (index) {
              Navigator.pop(context);
              setState(() {
                _selectedCategory = _incomeCategories[index]['name'];
              });
            }
          ),
        ),
        // description text field
        CustomTextField(
          controller: _incomeDescriptionControler,
          hintText: 'Enter description...',
          minLines: 1,
          maxLines: 5,
        ),
        // save button
        SubmitButton(
          onTap: () => handleDataSubmit(
            db: widget.db, 
            displaySnackBar: (content) => showSnackBar(context: context, content: content), 
            amountStr: _incomeController.text, 
            selectedDate: _selectedDate, 
            selectedTime: _selectedTime, 
            selectedCategory: _selectedCategory, 
            descriptionController: _incomeDescriptionControler, 
            clearInputData: _clearInputData
          ), 
          text: 'Save'
        ),
      ],
    );
  }
}
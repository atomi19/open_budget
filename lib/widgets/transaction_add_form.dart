// form used for income/expense screens

import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';
import 'package:open_budget/logic/handle_data_submit.dart';
import 'package:open_budget/widgets/custom_list_tile.dart';
import 'package:open_budget/widgets/custom_text_field.dart';
import 'package:open_budget/widgets/date_time_picker.dart';
import 'package:open_budget/widgets/show_snack_bar.dart';
import 'package:open_budget/widgets/submit_button.dart';

class TransactionAddForm extends StatefulWidget {
  final TransactionsDatabase db;
  final bool isIncome;
  final void Function({
    required bool isIncome, 
    required Function(int index) onTap,
  }) showCategories;

  const TransactionAddForm({
    super.key,
    required this.db,
    required this.isIncome,
    required this.showCategories
  });
  @override
  TransactionAddFormState createState() => TransactionAddFormState();
}

class TransactionAddFormState extends State<TransactionAddForm> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Category? _selectedCategory;
  int? _selectedCategoryId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  void _clearInputData() {
    setState(() {
      _amountController.clear();
      _selectedDate = null;
      _selectedTime = null;
      _selectedCategoryId = null;
      _descriptionController.clear();
    });
  }

  Future _findCategoryById(int id) async {
    _selectedCategory = await widget.db.getCategoryById(id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        // amount textfield
        CustomTextField(
          controller: _amountController, 
          hintText: widget.isIncome
          ? 'Enter income...'
          : 'Enter expense...',
          prefix: Text(
            widget.isIncome
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
          onTap: () => widget.showCategories(
            isIncome: widget.isIncome,
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
            displaySnackBar: (content) => showSnackBar(context: context, content: content),
            amountStr: widget.isIncome
            ? _amountController.text
            : '-${_amountController.text}', // pass amount String with - because it is expense
            selectedDate: _selectedDate, 
            selectedTime: _selectedTime, 
            categoryId: _selectedCategoryId, 
            descriptionController: _descriptionController, 
            clearInputData: _clearInputData
          ),
          text: 'Save'
        ),
      ],
    );
  }
}
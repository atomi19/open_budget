import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';

// validate data that user entered and save into db
void handleDataSubmit({
  required TransactionsDatabase db,
  required void Function(String message) displaySnackBar,
  required String amountStr,
  required DateTime? selectedDate, 
  required TimeOfDay? selectedTime,
  required String selectedCategory,
  required TextEditingController descriptionController,
  required VoidCallback clearInputData,
}) async {
  try {
    // validate amount
    double? amount = double.tryParse(amountStr);
    if(amount == null) {
      displaySnackBar('Enter valid amount');
      return;
    }

    // validate date
    if(selectedDate == null) {
      displaySnackBar('Select date');
      return;
    }
    // validate time
    if(selectedTime == null) {
      displaySnackBar('Select time');
      return;
    }

    // validate category
    if(selectedCategory.isEmpty) {
      displaySnackBar('Select a category');
      return;
    }

    // add transaction into db
    await db.addTransaction(
      amount: amount, 
      description: descriptionController.text, 
      category: selectedCategory, 
      date: selectedDate, 
      time: selectedTime,
    );
    clearInputData();
  } catch (e) {
    displaySnackBar('Error: $e');
  }
}
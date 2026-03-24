import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';

// validate data that user entered and save into db
void handleDataSubmit({
  required AppDatabase db,
  required void Function(String message) displaySnackBar,
  required String amountStr,
  required DateTime? selectedDate, 
  required TimeOfDay? selectedTime,
  required int? accountOwnerId,
  required int? categoryId,
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

    if(accountOwnerId == null) {
      displaySnackBar('Select an account');
      return;
    }

    // validate category
    if(categoryId == null) {
      displaySnackBar('Select a category');
      return;
    }

    // add transaction into db
    await db.transactionsDao.addTransaction(
      amount: amount, 
      description: descriptionController.text, 
      accountOwnerId: accountOwnerId,
      categoryId: categoryId, 
      date: selectedDate, 
      time: selectedTime,
    );
    clearInputData();
  } catch (e) {
    displaySnackBar('Error: $e');
  }
}
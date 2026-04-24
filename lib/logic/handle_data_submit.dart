import 'package:flutter/material.dart';
import 'package:open_budget/logic/database/database.dart';

// validate data that user entered and save into db
void handleDataSubmit({
  required AppDatabase db,
  required String amountStr,
  required DateTime? selectedDate, 
  required TimeOfDay? selectedTime,
  required Account? accountOwner,
  required int? categoryId,
  required TextEditingController descriptionController,
  required void Function(String message) displaySnackBar,
  required VoidCallback clearInputDataOnSubmit,
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
  
    // validate account
    if(accountOwner == null) {
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
      accountOwnerId: accountOwner.id,
      categoryId: categoryId, 
      date: selectedDate, 
      time: selectedTime,
    );

    // clear amount and description fields
    clearInputDataOnSubmit();
  } catch (e) {
    displaySnackBar('Error: $e');
  }
}

// handle transfer submit
void handleTransferSubmit({
  required AppDatabase db,
  required String amountStr,
  required Account? fromAccount,
  required Account? toAccount,
  required DateTime? selectedDate, 
  required TimeOfDay? selectedTime,
  required String description,
  required void Function(String message) displaySnackBar,
  required VoidCallback clearTransferDataOnSubmit
}) async {
  try {
    // validate amount
    double? amount = double.tryParse(amountStr);
    if(amount == null) {
      displaySnackBar('Enter valid amount');
      return;
    }

    // validate from account
    if(fromAccount== null) {
      displaySnackBar('Select from account');
      return;
    }

    // validate to account
    if(toAccount == null) {
      displaySnackBar('Select to account');
      return;
    }

    // make sure accounts are not the same
    if(fromAccount == toAccount) {
      displaySnackBar('Accounts should be different');
      return;
    }

    // make sure accounts have the same currency
    if(fromAccount.currency != toAccount.currency) {
      displaySnackBar('Accounts cannot have different currencies');
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

    // add to db
    await db.transactionsDao.addTransfer(
      amount: amount, 
      fromAccount: fromAccount.id, 
      toAccount: toAccount.id, 
      date: selectedDate, 
      time: selectedTime, 
      description: description,
    );

    // clear fields
    clearTransferDataOnSubmit();
  } catch (e) {
    displaySnackBar('Error: $e');
  }
}
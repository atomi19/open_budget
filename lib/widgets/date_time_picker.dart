import 'package:flutter/material.dart';

Future<DateTime?> pickDate(BuildContext context) {
  return showDatePicker(
    context: context, 
    firstDate: DateTime(2000), 
    lastDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
  );
}

Future<TimeOfDay?> pickTime(BuildContext context) {
  return showTimePicker(
    context: context, 
    initialEntryMode: TimePickerEntryMode.inputOnly,
    initialTime: TimeOfDay.now(),
  );
}
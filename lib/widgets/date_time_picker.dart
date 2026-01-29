import 'package:flutter/material.dart';

Future<DateTime?> pickDate({
  required BuildContext context,
  DateTime? currentDate,
  }) {
  return showDatePicker(
    context: context, 
    firstDate: DateTime(2000), 
    currentDate: currentDate,
    lastDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
  );
}

Future<TimeOfDay?> pickTime({
  required BuildContext context,
  TimeOfDay? initialTime
  }) {
  return showTimePicker(
    context: context, 
    initialEntryMode: TimePickerEntryMode.inputOnly,
    initialTime: initialTime ?? TimeOfDay.now(),
  );
}
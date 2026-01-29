import 'package:flutter/material.dart';

Future<DateTime?> pickDate({
  required BuildContext context,
  DateTime? currentDate,
  }) {
  return showDatePicker(
    context: context, 
    switchToCalendarEntryModeIcon: const Icon(Icons.calendar_month),
    switchToInputEntryModeIcon: const Icon(Icons.edit_outlined),
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    firstDate: DateTime(2000), 
    currentDate: currentDate,
    lastDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          datePickerTheme: DatePickerThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          colorScheme: const ColorScheme.light(
            primary: Colors.blue,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ), 
        child: child!
      );
    }
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
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          colorScheme: ColorScheme.light(
            primary: Colors.grey.shade50, // selected hour/minute bg color
            onPrimary: Colors.black, // selected hour/minute text color
            onSurface: Colors.black, // not selected hour/minute text color
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: Colors.white,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.grey.shade200,
            )
          )
        ), 
        child: child!
      );
    }
  );
}
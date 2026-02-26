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
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          colorScheme: ColorScheme.light(
            primary: Colors.blue,
            onPrimary: Colors.white,
            onSurface: Theme.of(context).colorScheme.onPrimary,  // text color
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary, // text color
              backgroundColor: Theme.of(context).colorScheme.surface, // button bg color
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
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            hourMinuteColor: Theme.of(context).colorScheme.surface, // hour/minute squares bg color
            hourMinuteTextColor: Theme.of(context).colorScheme.onPrimary,
          ),
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).colorScheme.surface, // selected hour/minute bg color
            onPrimary: Theme.of(context).colorScheme.surface, // selected hour/minute text color
            onSurface: Theme.of(context).colorScheme.surface, // not selected hour/minute text color
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.surface,
            )
          )
        ), 
        child: child!
      );
    }
  );
}

Future<DateTimeRange?> pickDateRange({
  required BuildContext context,
}) {
  return showDateRangePicker(
    context: context, 
    firstDate: DateTime(2000), 
    lastDate: DateTime.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          datePickerTheme: DatePickerThemeData(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            rangeSelectionBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
          colorScheme: ColorScheme.light(
            primary: Colors.blue, // selected day bg color
            onPrimary: Theme.of(context).colorScheme.secondary, // selected day text color
            onSurface: Theme.of(context).colorScheme.onPrimary, // not selected day text color
          ),
          iconButtonTheme: IconButtonThemeData(
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary
            )
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            )
          ),
        ), 
        child: child!
      );
    }
  );
}
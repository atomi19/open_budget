import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      activeThumbColor: Colors.white,
      inactiveThumbColor: Colors.grey.shade200,
      activeTrackColor: Colors.blue,
      inactiveTrackColor: Colors.grey.shade500,
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) {
          return Colors.transparent;
        }
      ), 
      onChanged: onChanged
    );
  }
}
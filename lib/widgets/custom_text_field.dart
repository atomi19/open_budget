import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final Color? backgroundColor;
  final String hintText;
  final int? minLines;
  final int? maxLines;
  final bool? isDense;
  final Widget? prefix;
  final Widget? prefixIcon;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    this.backgroundColor,
    required this.hintText,
    this.minLines,
    this.maxLines,
    this.isDense,
    this.prefix,
    this.prefixIcon,
    this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        isDense: isDense ?? false,
        prefix: prefix,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: backgroundColor ?? Colors.white,
        hoverColor: backgroundColor ?? Colors.white,
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 1
          )
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2,
          )
        )
      ),
      onChanged: onChanged,
    );
  }
}
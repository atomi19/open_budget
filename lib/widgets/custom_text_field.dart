import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int? minLines;
  final int? maxLines;
  final Widget? prefix;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.minLines,
    this.maxLines,
    this.prefix,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefix: prefix,
        filled: true,
        fillColor: Colors.white,
        hoverColor: Colors.white,
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 1
          )
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2,
          )
        )
      ),
    );
  }
}
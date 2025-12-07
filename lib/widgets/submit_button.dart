import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  const SubmitButton({
    super.key,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Text(text, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
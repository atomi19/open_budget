import 'package:flutter/material.dart';

void showSnackBar({
  required BuildContext context,
  required Widget content,
  VoidCallback? onClosed,
  }) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: const EdgeInsets.all(10),
      content: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(15),
        ),
        child: content,
      ),
    ),
  ).closed.then((_) => onClosed?.call());
}
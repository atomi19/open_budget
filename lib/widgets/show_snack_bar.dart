import 'package:flutter/material.dart';

void showSnackBar({
  required BuildContext context,
  required String content,
  SnackBarAction? action,
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
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.black12,
          )
        ),
        child: Text(
          content,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
      action: action,
    ),
  ).closed.then((_) => onClosed?.call());
}
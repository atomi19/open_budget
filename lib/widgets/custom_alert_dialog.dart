import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String leftButtonLabel;
  final String rightButtonLabel;
  final VoidCallback leftButtonAction;
  final VoidCallback rightButtonAction;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.leftButtonLabel,
    required this.rightButtonLabel,
    required this.leftButtonAction,
    required this.rightButtonAction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // left button
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )
                ),
                onPressed: () => leftButtonAction(), 
                child: Text(leftButtonLabel, style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onPrimary)),
              ),
            ),
            const SizedBox(width: 10),
            // right button
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Colors.red.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => rightButtonAction(), 
                child: Text(rightButtonLabel, style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onPrimary)),
              ),
            )
          ],
        )
      ],
    );
  }
}
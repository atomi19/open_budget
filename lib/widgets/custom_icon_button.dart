import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final Color? backgroundColor;
  final Widget icon;
  final VoidCallback onPressed;

  const CustomIconButton({
    super.key,
    this.backgroundColor,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
      ),
      onPressed: onPressed, 
      icon: icon
    );
  }
}
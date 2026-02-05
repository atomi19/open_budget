// header that is used inside modalBottomSheet's

import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final Widget? startWidget;
  final String title;
  final Widget? endWidget;

  const CustomHeader({
    super.key,
    this.startWidget,
    required this.title,
    this.endWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        startWidget ?? const SizedBox(width: 48),
        Text(
          title ,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        endWidget ?? const SizedBox(width: 48),
      ],
    );
  }
}
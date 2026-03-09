// header that is used inside modalBottomSheet's

import 'package:flutter/material.dart';

class CustomHeaderTitle extends StatelessWidget {
  final String title;

  const CustomHeaderTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
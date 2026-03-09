// header that is used inside modalBottomSheet's

import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final List<Widget> children;

  const CustomHeader({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }
}
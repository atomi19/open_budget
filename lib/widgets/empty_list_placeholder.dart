import 'package:flutter/material.dart';

class EmptyListPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyListPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // icon
        Icon(icon, size: 44, color: Colors.grey),
        const SizedBox(height: 8),
        // title
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        // subtitle
        Text(
          subtitle, 
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
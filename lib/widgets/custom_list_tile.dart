import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final Color? tileColor;
  final Widget? leading;
  final String title;
  final Widget? trailing;
  final Widget? subtitle;
  final VoidCallback? onTap;

  const CustomListTile({
    super.key,
    this.tileColor,
    this.leading,
    required this.title,
    this.trailing,
    this.subtitle,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: tileColor ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(fontSize: 15),
      ),
      trailing: trailing,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}
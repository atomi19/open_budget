import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final Color tileColor;
  final Widget? leading;
  final String title;
  final Widget? trailing;
  final Widget? subtitle;
  final VoidCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final RoundedRectangleBorder? customBorder;

  const CustomListTile({
    super.key,
    required this.tileColor,
    this.leading,
    required this.title,
    this.trailing,
    this.subtitle,
    this.onTap,
    this.onTapDown,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    final border = customBorder ?? 
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      );
    return Material(
      color: tileColor,
      shape: border,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onTapDown: onTapDown,
        child: ListTile(
          leading: leading,
          title: Text(
            title,
            style: const TextStyle(fontSize: 15),
          ),
          trailing: trailing,
          subtitle: subtitle,
        ),
      )
    );
  }
}
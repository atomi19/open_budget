import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final Color tileColor;
  final Widget? leading;
  final String title;
  final Widget? trailing;
  final Widget? subtitle;
  final EdgeInsetsGeometry? contentPadding;
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
    this.contentPadding,
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
          contentPadding: contentPadding ?? const EdgeInsetsDirectional.only(start: 16.0, end: 24.0),
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
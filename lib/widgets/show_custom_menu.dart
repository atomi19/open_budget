import 'package:flutter/material.dart';

void showCustomMenu({
  required BuildContext context,
  required TapDownDetails position,
  required List<PopupMenuItem> items,
}) {
  showMenu(
    context: context, 
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15)
    ),
    menuPadding: EdgeInsets.zero,
    color: Theme.of(context).colorScheme.primaryContainer,
    clipBehavior: Clip.antiAlias,
    position: RelativeRect.fromLTRB(
      position.globalPosition.dx, 
      position.globalPosition.dy, 
      position.globalPosition.dx, 
      position.globalPosition.dy,
    ),
    items: items
  );
}
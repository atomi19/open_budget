// reuse showModalBottomSheet

import 'package:flutter/material.dart';

void showCustomModalBottomSheet({
  required BuildContext context,
  bool? isScrollControlled,
  Color? backgroundColor,
  double? borderRadius,
  double? padding,
  required Widget child,
  }) {
  showModalBottomSheet(
    context: context, 
    isScrollControlled: isScrollControlled ?? false,
    backgroundColor: backgroundColor ?? Colors.grey.shade200,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(borderRadius ?? 15))
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: padding ?? 10,
            top: padding ?? 10,
            right: padding ?? 10,
            bottom: MediaQuery.of(context).viewInsets.bottom +10,
          ),
          child: child,
        )
      );
    }
  );
}
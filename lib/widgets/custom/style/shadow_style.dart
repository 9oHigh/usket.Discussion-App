import 'package:app_team1/widgets/utils/app_color.dart';
import 'package:flutter/material.dart';

BoxDecoration createShadowStyle({
  Color color = AppColor.roomTileColor,
  double borderRadius = 20,
  double spreadRadius = 1,
  Offset offset = const Offset(0, 3),
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        spreadRadius: spreadRadius,
        blurRadius: 5,
        offset: offset,
      ),
    ],
  );
}
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SectionTitleStyle {
  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 17,
    color: AppColors.thirdaryColor,
    fontWeight: FontWeight.w500,
  );
}

BoxDecoration createShadowStyle(
    {Color color = AppColors.roomTileColor,
    double borderRadius = 20,
    double spreadRadius = 1,
    Offset offset = const Offset(0, 3)}) {
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

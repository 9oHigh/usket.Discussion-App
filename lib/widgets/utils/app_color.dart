import 'package:flutter/material.dart';

class AppColor {
  static const Color primaryColor = Color(0xff6684F3);
  static const Color secondaryColor = Color(0xffDDE7FF);
  static const Color thirdaryColor = Color(0xff3651B2);
  static const Color startColor = Color(0xff6684F3);
  static const Color endColor = Color(0xffB2C7FC);
  static const Color backgroundColor = Color(0xffEFF3FF);
  static const Color roomTileColor = Color(0xffffffff);
  static const Color appBarContentsColor = Color(0xffffffff);
  static const Color buttonTextColor = Color(0xffffffff);

  static const List<Color> gradientColors = [
    startColor,
    endColor,
  ];

  static const LinearGradient linearGradient = LinearGradient(
    colors: gradientColors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

import 'package:flutter/material.dart';

class AppConstants {
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double spaceBetweenColumns(BuildContext context) {
    return getScreenHeight(context) * 0.05;
  }

  static double spaceBetweenElements(BuildContext context) {
    return getScreenHeight(context) * 0.015;
  }

  static double textFieldWidth(BuildContext context) {
    return getScreenWidth(context) * 0.9;
  }

  static double buttonWidth(BuildContext context) {
    return getScreenWidth(context) * 0.9;
  }

  static double buttonHeight(BuildContext context) {
    return getScreenHeight(context) * 0.04;
  }

  static double topicBoxSize(BuildContext context) {
    return getScreenHeight(context) * 0.09;
  }

  static double badgeSize(BuildContext context) {
    return getScreenHeight(context) * 0.025;
  }
}

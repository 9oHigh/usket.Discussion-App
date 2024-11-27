import 'package:flutter/material.dart';

class AppConstant {
  static double getScreenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  static double getScreenWidth(BuildContext context)  => MediaQuery.of(context).size.width;
  static double spaceMedium(BuildContext context) => getScreenHeight(context) * 0.05;
  static double spaceSmall(BuildContext context) => getScreenHeight(context) * 0.015;
  static double mainInfoWidth(BuildContext context) => getScreenWidth(context) * 0.8;
  static double textFieldWidth(BuildContext context) => getScreenWidth(context) * 0.9;
  static double listImageSize(BuildContext context) => getScreenHeight(context) * 0.07;
  static double topicBoxSize(BuildContext context) => getScreenHeight(context) * 0.092;
  static double badgeSize(BuildContext context) => getScreenHeight(context) * 0.025;
  static double filterImageSize(BuildContext context) => getScreenHeight(context) * 0.06;
  static double appBarHieght(BuildContext context) => getScreenHeight(context) * 0.08;
}
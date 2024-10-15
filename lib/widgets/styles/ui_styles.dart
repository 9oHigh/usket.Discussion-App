import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TextButtonStyle {
  static final ButtonStyle textButtonStyle = TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: Colors.grey, width: 1),
    ),
  );
}

BoxDecoration createShadowStyle({Color color = AppColors.roomTileColor,  double borderRadius = 20}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        spreadRadius: 1,
        blurRadius: 5,
        offset: const Offset(0, 3),
      ),
    ],
  );
}



import 'package:flutter/material.dart';

class TextButtonStyles {
  static final ButtonStyle textButtonStyle = TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: Colors.grey, width: 1),
    ),
  );
}

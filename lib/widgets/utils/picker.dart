import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import '../utils/constants.dart';

class TimePicker extends StatelessWidget {
  final Function(DateTime) onTimeChange;

  const TimePicker({super.key, required this.onTimeChange});

  @override
  Widget build(BuildContext context) {
    return TimePickerSpinner(
      is24HourMode: true,
      normalTextStyle: const TextStyle(fontSize: 18, color: Colors.grey),
      highlightedTextStyle: const TextStyle(
          fontSize: 22, color: AppColors.primaryColor, fontWeight: FontWeight.w500),
      spacing: 50,
      itemHeight: 50,
      isForce2Digits: true,
      alignment: Alignment.center,
      onTimeChange: (time) {
        onTimeChange(time);
      },
    );
  }
}

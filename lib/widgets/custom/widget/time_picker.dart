import 'package:app_team1/widgets/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class TimePicker extends StatelessWidget {
  final Function(DateTime) _onTimeChange;

  const TimePicker({
    super.key,
    required Function(DateTime) onTimeChange,
  }) : _onTimeChange = onTimeChange;

  @override
  Widget build(BuildContext context) {
    return TimePickerSpinner(
      is24HourMode: true,
      normalTextStyle: const TextStyle(fontSize: 18, color: Colors.grey),
      highlightedTextStyle: const TextStyle(
          fontSize: 22,
          color: AppColor.primaryColor,
          fontWeight: FontWeight.w500),
      spacing: 50,
      itemHeight: 50,
      isForce2Digits: true,
      alignment: Alignment.center,
      onTimeChange: (time) {
        _onTimeChange(time);
      },
    );
  }
}
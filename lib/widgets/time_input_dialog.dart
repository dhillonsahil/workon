// lib/widgets/time_input_dialog.dart
import 'package:flutter/material.dart';

class TimeInputDialog extends StatefulWidget {
  final int initialMinutes;
  const TimeInputDialog({super.key, required this.initialMinutes});

  @override
  State<TimeInputDialog> createState() => _TimeInputDialogState();
}

class _TimeInputDialogState extends State<TimeInputDialog> {
  late int _hours;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialMinutes ~/ 60;
    _minutes = widget.initialMinutes % 60;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Time Taken"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _numberPicker(0, 23, _hours, (v) => setState(() => _hours = v)),
          const Text(" h ", style: TextStyle(fontSize: 20)),
          _numberPicker(0, 59, _minutes, (v) => setState(() => _minutes = v)),
          const Text(" m ", style: TextStyle(fontSize: 20)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _hours * 60 + _minutes),
          child: const Text("OK"),
        ),
      ],
    );
  }

  Widget _numberPicker(int min, int max, int value, Function(int) onChange) {
    return SizedBox(
      width: 60,
      height: 100,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 40,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChange,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (_, i) => Center(child: Text(i.toString().padLeft(2, '0'))),
          childCount: max + 1,
        ),
      ),
    );
  }
}

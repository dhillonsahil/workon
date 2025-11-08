import 'package:flutter/material.dart';

class LockTimePicker extends StatefulWidget {
  final int initialHours;
  final int initialMinutes;
  final Function(int hours, int minutes) onChanged;

  const LockTimePicker({
    super.key,
    this.initialHours = 0,
    this.initialMinutes = 0,
    required this.onChanged,
  });

  @override
  State<LockTimePicker> createState() => _LockTimePickerState();
}

class _LockTimePickerState extends State<LockTimePicker> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(
      initialItem: widget.initialHours,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: widget.initialMinutes,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWheel(
          controller: _hourController,
          min: 0,
          max: 23,
          label: 'H',
          onSelect: (i) => widget.onChanged(i, _minuteController.selectedItem),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            ":",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
        _buildWheel(
          controller: _minuteController,
          min: 0,
          max: 59,
          label: 'M',
          onSelect: (i) => widget.onChanged(_hourController.selectedItem, i),
        ),
      ],
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int min,
    required int max,
    required String label,
    required Function(int) onSelect,
  }) {
    return SizedBox(
      width: 80,
      height: 140,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 50,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelect,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final value = index.toString().padLeft(2, '0');
            final isSelected = controller.selectedItem == index;
            return Center(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isSelected ? 28 : 20,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.indigo : Colors.grey[600],
                ),
              ),
            );
          },
          childCount: max + 1,
        ),
      ),
    );
  }
}

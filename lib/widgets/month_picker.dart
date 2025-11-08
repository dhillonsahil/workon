import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthPicker extends StatelessWidget {
  final DateTime selectedMonth;
  final Function(DateTime) onMonthChanged;

  const MonthPicker({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showMonthPicker(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(selectedMonth),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.calendar_today, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMonthPicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => _MonthYearPickerDialog(
        initialDate: selectedMonth,
        firstDate: DateTime(2020),
        lastDate: DateTime(now.year, now.month + 1),
      ),
    );
    if (picked != null) {
      onMonthChanged(picked);
    }
  }
}

class _MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _MonthYearPickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Month"),
      content: SizedBox(
        width: 300,
        height: 300,
        child: Column(
          children: [
            // Year Picker
            Expanded(
              child: ListWheelScrollView.useDelegate(
                itemExtent: 40,
                onSelectedItemChanged: (i) =>
                    setState(() => _selectedYear = widget.firstDate.year + i),
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (ctx, i) {
                    final year = widget.firstDate.year + i;
                    final isSelected = year == _selectedYear;
                    return Center(
                      child: Text(
                        year.toString(),
                        style: TextStyle(
                          fontSize: isSelected ? 20 : 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                  childCount: widget.lastDate.year - widget.firstDate.year + 1,
                ),
              ),
            ),
            const Divider(),
            // Month Grid
            Expanded(
              flex: 2,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2,
                ),
                itemCount: 12,
                itemBuilder: (ctx, i) {
                  final month = i + 1;
                  final isSelected = month == _selectedMonth;
                  final isEnabled =
                      !DateTime(
                        _selectedYear,
                        month,
                      ).isAfter(widget.lastDate) &&
                      !DateTime(
                        _selectedYear,
                        month,
                      ).isBefore(widget.firstDate);
                  return InkWell(
                    onTap: isEnabled
                        ? () => setState(() => _selectedMonth = month)
                        : null,
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.indigo : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Colors.indigo
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          DateFormat('MMM').format(DateTime(2020, month)),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isEnabled ? Colors.black87 : Colors.grey),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () =>
              Navigator.pop(context, DateTime(_selectedYear, _selectedMonth)),
          child: const Text("OK"),
        ),
      ],
    );
  }
}

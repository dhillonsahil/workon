import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/entry.dart';
import '../models/work_title.dart';
import '../providers/entry_provider.dart';
import '../providers/title_provider.dart';
import '../widgets/time_picker_lock.dart';

class AddEntryDialog extends StatefulWidget {
  final DateTime? date;

  const AddEntryDialog({super.key, this.date});

  @override
  State<AddEntryDialog> createState() => _AddEntryDialogState();
}

class _AddEntryDialogState extends State<AddEntryDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _hours = 0;
  int _minutes = 0;
  WorkTitle? _selectedTitle;

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final titles = context.watch<TitleProvider>().titles;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("Log Work - ${_formatDate(_selectedDate)}"),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (titles.isNotEmpty)
                DropdownButtonFormField<WorkTitle>(
                  value: _selectedTitle,
                  decoration: const InputDecoration(labelText: "Quick Select"),
                  items: titles
                      .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.name)),
                      )
                      .toList(),
                  onChanged: (t) {
                    setState(() => _selectedTitle = t);
                    if (t != null) _titleCtrl.text = t.name;
                  },
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Title *",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              const Text(
                "Time Studied",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              LockTimePicker(
                onChanged: (h, m) => setState(() {
                  _hours = h;
                  _minutes = m;
                }),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _selectedTitle?.name ?? _titleCtrl.text.trim();
            if (title.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Title is required")),
              );
              return;
            }
            final entry = WorkEntry(
              title: title,
              description: _descCtrl.text,
              hours: _hours,
              minutes: _minutes,
              date: _selectedDate,
            );
            context.read<EntryProvider>().addEntry(entry);
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

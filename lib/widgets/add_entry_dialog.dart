// lib/widgets/add_entry_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/entry.dart';
import '../models/work_title.dart';
import '../providers/entry_provider.dart';
import '../providers/title_provider.dart';
import '../db/database_helper.dart';

class AddEntryDialog extends StatefulWidget {
  final DateTime? date;
  final WorkEntry? entryToEdit;

  const AddEntryDialog({super.key, this.date, this.entryToEdit});

  @override
  State<AddEntryDialog> createState() => _AddEntryDialogState();
}

class _AddEntryDialogState extends State<AddEntryDialog> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late int _hours;
  late int _minutes;
  WorkTitle? _selectedTitle;
  String? _selectedTag;
  late DateTime _selectedDate;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    final entry = widget.entryToEdit;
    _selectedDate = widget.date ?? DateTime.now();

    _titleCtrl = TextEditingController(text: entry?.title ?? '');
    _descCtrl = TextEditingController(text: entry?.description ?? '');
    _hours = entry?.hours ?? 0;
    _minutes = entry?.minutes ?? 0;

    _hourController = FixedExtentScrollController(initialItem: _hours);
    _minuteController = FixedExtentScrollController(initialItem: _minutes);

    // Fixed: Use didChangeDependencies instead of initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (entry != null && mounted) {
        final titleProvider = Provider.of<TitleProvider>(
          context,
          listen: false,
        );
        final foundTitle = titleProvider.getTitleByName(entry.title);
        if (mounted) {
          setState(() {
            _selectedTitle = foundTitle;
            _selectedTag = entry.tag;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titles = context.watch<TitleProvider>().titles;
    // Fixed: tags is Set<String> → convert to List and add "misc"
    final tagList = ["misc", ...context.watch<TitleProvider>().tags.toList()];

    final isEdit = widget.entryToEdit != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(isEdit ? "Edit Entry" : "Log Work"),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quick Select Title
              if (titles.isNotEmpty)
                DropdownButtonFormField<WorkTitle>(
                  value: _selectedTitle,
                  decoration: const InputDecoration(
                    labelText: "Quick Select Title",
                  ),
                  items: titles
                      .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.name)),
                      )
                      .toList(),
                  onChanged: (t) {
                    setState(() {
                      _selectedTitle = t;
                      if (t != null) {
                        _titleCtrl.text = t.name;
                        _selectedTag = t.tag ?? "misc";
                      }
                    });
                  },
                ),
              const SizedBox(height: 12),

              // Title
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Title *",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Description
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // Tag Dropdown with "misc" as default
              DropdownButtonFormField<String>(
                value: _selectedTag,
                decoration: const InputDecoration(labelText: "Tag"),
                items: tagList
                    .map(
                      (tag) => DropdownMenuItem(
                        value: tag,
                        child: Text(tag == "misc" ? "misc (default)" : "#$tag"),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedTag = value),
              ),
              const SizedBox(height: 20),

              // Time Picker
              const Text(
                "Time Spent *",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildWheel(
                      "Hours",
                      _hourController,
                      0,
                      23,
                      (h) => _hours = h,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildWheel(
                      "Minutes",
                      _minuteController,
                      0,
                      59,
                      (m) => _minutes = m,
                    ),
                  ),
                ],
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
          onPressed: _canSave() ? _saveEntry : null,
          child: Text(isEdit ? "Update" : "Save"),
        ),
      ],
    );
  }

  Widget _buildWheel(
    String label,
    FixedExtentScrollController controller,
    int min,
    int max,
    Function(int) onChange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        SizedBox(
          height: 100,
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 40,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (i) => setState(() => onChange(i)),
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (ctx, i) {
                final val = i.toString().padLeft(2, '0');
                final selected =
                    controller.hasClients && controller.selectedItem == i;
                return Center(
                  child: Text(
                    val,
                    style: TextStyle(
                      fontSize: selected ? 24 : 18,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: selected ? Colors.indigo : Colors.grey[600],
                    ),
                  ),
                );
              },
              childCount: max + 1,
            ),
          ),
        ),
      ],
    );
  }

  bool _canSave() {
    final title = _selectedTitle?.name ?? _titleCtrl.text.trim();
    return title.isNotEmpty && (_hours > 0 || _minutes > 0);
  }

  void _saveEntry() async {
    final title = _selectedTitle?.name ?? _titleCtrl.text.trim();
    if (title.isEmpty || (_hours == 0 && _minutes == 0)) return;

    final tagToSave = _selectedTag == "misc" || _selectedTag == null
        ? null
        : _selectedTag;
    final descriptionToSave = _descCtrl.text.trim().isEmpty
        ? null
        : _descCtrl.text.trim();

    final entry = WorkEntry(
      id: widget.entryToEdit?.id,
      title: title,
      description: descriptionToSave, // ← Now safely String?
      tag: tagToSave,
      date: _selectedDate,
      hours: _hours,
      minutes: _minutes,
    );

    try {
      if (widget.entryToEdit != null) {
        await DatabaseHelper.instance.updateEntry(entry);
      } else {
        await DatabaseHelper.instance.insertEntry(entry);
      }

      if (mounted) {
        context.read<EntryProvider>().loadEntries();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Save failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

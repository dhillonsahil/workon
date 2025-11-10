// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/entry.dart';
// import '../models/work_title.dart';
// import '../providers/entry_provider.dart';
// import '../providers/title_provider.dart';
// import '../db/database_helper.dart';

// class AddEntryDialog extends StatefulWidget {
//   final DateTime? date;
//   final WorkEntry? entryToEdit;

//   const AddEntryDialog({super.key, this.date, this.entryToEdit});

//   @override
//   State<AddEntryDialog> createState() => _AddEntryDialogState();
// }

// class _AddEntryDialogState extends State<AddEntryDialog> {
//   final _titleCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   int _hours = 0;
//   int _minutes = 0;
//   WorkTitle? _selectedTitle;
//   String? _selectedTag;

//   late DateTime _selectedDate;
//   late FixedExtentScrollController _hourController;
//   late FixedExtentScrollController _minuteController;

//   @override
//   void initState() {
//     super.initState();
//     _selectedDate = widget.date ?? DateTime.now();
//     _hourController = FixedExtentScrollController(initialItem: _hours);
//     _minuteController = FixedExtentScrollController(initialItem: _minutes);

//     if (widget.entryToEdit != null) {
//       final e = widget.entryToEdit!;
//       _titleCtrl.text = e.title;
//       _descCtrl.text = e.description;
//       _hours = e.hours;
//       _minutes = e.minutes;
//       _selectedTitle = context.read<TitleProvider>().getTitleByName(e.title);
//       _selectedTag = e.tag; // NOW VALID
//       _hourController.jumpToItem(_hours);
//       _minuteController.jumpToItem(_minutes);
//     }
//   }

//   @override
//   void dispose() {
//     _hourController.dispose();
//     _minuteController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final titles = context.watch<TitleProvider>().titles;
//     final tags = context.watch<TitleProvider>().tags;
//     final isEdit = widget.entryToEdit != null;

//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: Text(
//         isEdit ? "Edit Entry" : "Log Work - ${_formatDate(_selectedDate)}",
//       ),
//       content: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 400),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // QUICK SELECT TITLE
//               if (titles.isNotEmpty)
//                 DropdownButtonFormField<WorkTitle>(
//                   value: _selectedTitle,
//                   decoration: const InputDecoration(labelText: "Quick Select"),
//                   items: titles
//                       .map(
//                         (t) => DropdownMenuItem(value: t, child: Text(t.name)),
//                       )
//                       .toList(),
//                   onChanged: (t) {
//                     setState(() {
//                       _selectedTitle = t;
//                       if (t != null) {
//                         _titleCtrl.text = t.name;
//                         _selectedTag = t.tag;
//                       }
//                     });
//                   },
//                 ),
//               const SizedBox(height: 12),

//               // TITLE
//               TextField(
//                 controller: _titleCtrl,
//                 decoration: const InputDecoration(
//                   labelText: "Title *",
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 12),

//               // DESCRIPTION
//               TextField(
//                 controller: _descCtrl,
//                 decoration: const InputDecoration(
//                   labelText: "Description",
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//               const SizedBox(height: 12),

//               // TAG DROPDOWN
//               DropdownButtonFormField<String>(
//                 value: _selectedTag,
//                 decoration: const InputDecoration(labelText: "Tag"),
//                 items:
//                     tags
//                         .map(
//                           (t) => DropdownMenuItem(value: t, child: Text("#$t")),
//                         )
//                         .toList()
//                       ..add(
//                         const DropdownMenuItem(
//                           value: null,
//                           child: Text("None"),
//                         ),
//                       ),
//                 onChanged: (t) => setState(() => _selectedTag = t),
//               ),
//               const SizedBox(height: 20),

//               // TIME PICKER
//               const Text(
//                 "Time Studied *",
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildWheel(
//                       "Hours",
//                       _hourController,
//                       0,
//                       23,
//                       (h) => _hours = h,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: _buildWheel(
//                       "Minutes",
//                       _minuteController,
//                       0,
//                       59,
//                       (m) => _minutes = m,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text("Cancel"),
//         ),
//         ElevatedButton(
//           onPressed: _canSave() ? _saveEntry : null,
//           child: Text(isEdit ? "Update" : "Save"),
//         ),
//       ],
//     );
//   }

//   Widget _buildWheel(
//     String label,
//     FixedExtentScrollController controller,
//     int min,
//     int max,
//     Function(int) onChange,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//         const SizedBox(height: 4),
//         SizedBox(
//           height: 100,
//           child: ListWheelScrollView.useDelegate(
//             controller: controller,
//             itemExtent: 40,
//             physics: const FixedExtentScrollPhysics(),
//             onSelectedItemChanged: (i) {
//               onChange(i);
//               setState(() {});
//             },
//             childDelegate: ListWheelChildBuilderDelegate(
//               builder: (ctx, i) {
//                 final val = i.toString().padLeft(2, '0');
//                 final selected =
//                     controller.hasClients && controller.selectedItem == i;
//                 return Center(
//                   child: Text(
//                     val,
//                     style: TextStyle(
//                       fontSize: selected ? 24 : 18,
//                       fontWeight: selected
//                           ? FontWeight.bold
//                           : FontWeight.normal,
//                       color: selected ? Colors.indigo : Colors.grey[600],
//                     ),
//                   ),
//                 );
//               },
//               childCount: max + 1,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   bool _canSave() {
//     final title = _selectedTitle?.name ?? _titleCtrl.text.trim();
//     final totalMinutes = _hours * 60 + _minutes;
//     return title.isNotEmpty && totalMinutes > 0;
//   }

//   void _saveEntry() async {
//     final title = _selectedTitle?.name ?? _titleCtrl.text.trim();
//     final totalMinutes = _hours * 60 + _minutes;

//     if (title.isEmpty || totalMinutes == 0) return;

//     final entry = WorkEntry(
//       id: widget.entryToEdit?.id,
//       title: title,
//       description: _descCtrl.text,
//       hours: _hours,
//       minutes: _minutes,
//       date: _selectedDate,
//       tag: _selectedTag, // NOW VALID
//     );

//     if (widget.entryToEdit != null) {
//       await DatabaseHelper.instance.updateEntry(entry);
//     } else {
//       await DatabaseHelper.instance.insertEntry(entry);
//     }

//     context.read<EntryProvider>().loadEntries();
//     if (mounted) Navigator.pop(context);
//   }

//   String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
// }
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

    if (entry != null) {
      _selectedTitle = context.read<TitleProvider>().getTitleByName(
        entry.title,
      );
      _selectedTag = entry.tag;
    }
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
    final tags = context.watch<TitleProvider>().tags;
    final isEdit = widget.entryToEdit != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        isEdit ? "Edit Entry" : "Log Work - ${_formatDate(_selectedDate)}",
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // QUICK SELECT TITLE
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
                    setState(() {
                      _selectedTitle = t;
                      if (t != null) {
                        _titleCtrl.text = t.name;
                        _selectedTag = t.tag;
                      }
                    });
                  },
                ),
              const SizedBox(height: 12),

              // TITLE
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Title *",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // DESCRIPTION
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // TAG DROPDOWN
              DropdownButtonFormField<String>(
                value: _selectedTag,
                decoration: const InputDecoration(labelText: "Tag"),
                items: [
                  ...tags.map(
                    (t) => DropdownMenuItem(value: t, child: Text("#$t")),
                  ),
                  const DropdownMenuItem(value: null, child: Text("None")),
                ],
                onChanged: (t) => setState(() => _selectedTag = t),
              ),
              const SizedBox(height: 20),

              // TIME PICKER
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
    final totalMinutes = _hours * 60 + _minutes;
    return title.isNotEmpty && totalMinutes > 0;
  }

  void _saveEntry() async {
    final title = _selectedTitle?.name ?? _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final totalMinutes = _hours * 60 + _minutes;

    if (title.isEmpty || totalMinutes == 0) return;

    final original = widget.entryToEdit;

    // ONLY UPDATE CHANGED FIELDS
    final updatedEntry = WorkEntry(
      id: original?.id,
      title: title != original?.title ? title : original!.title,
      description: desc != original?.description ? desc : original!.description,
      hours: _hours != original?.hours ? _hours : original!.hours,
      minutes: _minutes != original?.minutes ? _minutes : original!.minutes,
      date: _selectedDate,
      tag: _selectedTag != original?.tag ? _selectedTag : original!.tag,
    );

    if (original != null) {
      await DatabaseHelper.instance.updateEntry(updatedEntry);
    } else {
      await DatabaseHelper.instance.insertEntry(
        updatedEntry.copyWith(id: null),
      );
    }

    context.read<EntryProvider>().loadEntries();
    if (mounted) Navigator.pop(context);
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

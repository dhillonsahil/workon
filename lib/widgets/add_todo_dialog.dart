// lib/widgets/add_todo_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workon/models/todo.dart';
import 'package:workon/providers/todo_provider.dart';
import 'package:workon/providers/title_provider.dart';

class AddTodoDialog extends StatefulWidget {
  final DateTime? initialDate;

  const AddTodoDialog({super.key, this.initialDate});

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _dueDate = DateTime.now();
  String _priority = 'medium';
  String? _tag;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _dueDate = widget.initialDate!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = context.watch<TitleProvider>().titles;
    final tags = context.watch<TitleProvider>().tags;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("New Todo"),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quick Title Select
              if (titles.isNotEmpty)
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: "Quick Select Title",
                  ),
                  items: titles
                      .map(
                        (t) => DropdownMenuItem(
                          value: t.name,
                          child: Text(t.name),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    _titleCtrl.text = val.toString();
                    final titleObj = titles.firstWhere((t) => t.name == val);
                    _tag = titleObj.tag;
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
              const SizedBox(height: 12),

              // Priority
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(labelText: "Priority"),
                items: [
                  DropdownMenuItem(
                    value: 'high',
                    child: Text("High", style: TextStyle(color: Colors.red)),
                  ),
                  DropdownMenuItem(
                    value: 'medium',
                    child: Text(
                      "Medium",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'low',
                    child: Text("Low", style: TextStyle(color: Colors.green)),
                  ),
                ],
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 12),

              // Tag
              DropdownButtonFormField<String>(
                value: _tag,
                decoration: const InputDecoration(labelText: "Tag"),
                items:
                    tags
                        .map(
                          (t) => DropdownMenuItem(value: t, child: Text("#$t")),
                        )
                        .toList()
                      ..add(
                        const DropdownMenuItem(
                          value: null,
                          child: Text("None"),
                        ),
                      ),
                onChanged: (v) => setState(() => _tag = v),
              ),
              const SizedBox(height: 16),

              // Due Date
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text("Due Date: ${_formatDate(_dueDate)}"),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
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
          onPressed: _canSave() ? _saveTodo : null,
          child: const Text("Add"),
        ),
      ],
    );
  }

  bool _canSave() => _titleCtrl.text.trim().isNotEmpty;

  void _saveTodo() {
    final todo = Todo(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text,
      tag: _tag,
      priority: _priority,
      dueDate: DateTime(_dueDate.year, _dueDate.month, _dueDate.day, 23, 59),
    );
    context.read<TodoProvider>().addTodo(todo);
    Navigator.pop(context);
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

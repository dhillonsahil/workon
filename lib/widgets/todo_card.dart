// lib/widgets/todo_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workon/models/todo.dart';
import 'package:workon/providers/todo_provider.dart';
import 'package:workon/widgets/time_input_dialog.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;

  const TodoCard({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final isOverdue =
        !todo.isCompleted && todo.dueDate.isBefore(DateTime.now());
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => context.read<TodoProvider>().deleteTodo(todo.id!),
      child: Card(
        color: todo.isCompleted ? Colors.grey[100] : null,
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (v) => _toggleComplete(context),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted ? Colors.grey : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.description.isNotEmpty)
                Text(todo.description, maxLines: 2),
              const SizedBox(height: 4),
              Row(
                children: [
                  _priorityChip(todo.priority),
                  const SizedBox(width: 8),
                  if (todo.tag != null)
                    Chip(
                      label: Text("#${todo.tag!}"),
                      backgroundColor: Colors.indigo.shade50,
                    ),
                  if (isOverdue)
                    const Chip(
                      label: Text("OVERDUE"),
                      backgroundColor: Colors.red,
                    ),
                ],
              ),
            ],
          ),
          trailing: Text(
            _formatDate(todo.dueDate),
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  void _toggleComplete(BuildContext context) async {
    if (!todo.isCompleted) {
      final minutes = await showDialog<int>(
        context: context,
        builder: (_) => TimeInputDialog(initialMinutes: 0),
      );
      if (minutes != null) {
        context.read<TodoProvider>().toggleComplete(
          todo,
          timeTakenMinutes: minutes,
        );
      }
    } else {
      context.read<TodoProvider>().toggleComplete(todo);
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete Todo?"),
            content: Text("Remove \"${todo.title}\"?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _priorityChip(String p) {
    Color color = Colors.grey;
    if (p == 'high') color = Colors.red;
    if (p == 'medium') color = Colors.orange;
    if (p == 'low') color = Colors.green;
    return Chip(
      label: Text(p.toUpperCase()),
      backgroundColor: color.withOpacity(0.2),
      padding: EdgeInsets.zero,
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}';
}

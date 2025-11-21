// lib/screens/todos_overview_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workon/providers/todo_provider.dart';
import 'package:workon/widgets/todo_card.dart';

class TodosOverviewScreen extends StatelessWidget {
  const TodosOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Todos",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, _) {
          final overdue = provider.getOverdueTodos();
          final today = provider.getTodayTodos();
          final upcoming = provider.getUpcomingTodos();

          if (provider.todos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No todos yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text("Tap + to create your first task"),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (overdue.isNotEmpty) ...[
                _sectionHeader("Overdue", Colors.red),
                const SizedBox(height: 8),
                ...overdue.map((t) => TodoCard(todo: t)),
                const SizedBox(height: 24),
              ],
              if (today.isNotEmpty) ...[
                _sectionHeader("Today", Colors.orange),
                const SizedBox(height: 8),
                ...today.map((t) => TodoCard(todo: t)),
                const SizedBox(height: 24),
              ],
              if (upcoming.isNotEmpty) ...[
                _sectionHeader("Upcoming", Colors.indigo),
                const SizedBox(height: 8),
                ...upcoming.map((t) => TodoCard(todo: t)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 20, color: color),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

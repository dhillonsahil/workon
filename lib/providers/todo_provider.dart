// lib/providers/todo_provider.dart
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/todo.dart';

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;
  List<Todo> get incompleteTodos =>
      _todos.where((t) => !t.isCompleted).toList();
  List<Todo> get completedTodos => _todos.where((t) => t.isCompleted).toList();

  Future<void> loadTodos() async {
    final todos = await DatabaseHelper.instance.getAllTodos();
    _todos = todos;
    notifyListeners();
  }

  List<Todo> getTodosForDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return _todos.where((t) {
      final tDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      return tDate == normalized;
    }).toList();
  }

  List<Todo> getOverdueTodos() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return incompleteTodos.where((t) => t.dueDate.isBefore(today)).toList();
  }

  List<Todo> getTodayTodos() {
    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);
    return incompleteTodos.where((t) {
      final tDate = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      return tDate == normalized;
    }).toList();
  }

  List<Todo> getUpcomingTodos() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return incompleteTodos.where((t) => t.dueDate.isAfter(tomorrow)).toList();
  }

  Future<void> addTodo(Todo todo) async {
    await DatabaseHelper.instance.insertTodo(todo);
    await loadTodos();
  }

  Future<void> updateTodo(Todo todo) async {
    await DatabaseHelper.instance.updateTodo(todo);
    await loadTodos();
  }

  Future<void> deleteTodo(int id) async {
    await DatabaseHelper.instance.deleteTodo(id);
    await loadTodos();
  }

  Future<void> toggleComplete(Todo todo, {int? timeTakenMinutes}) async {
    final updated = todo.copyWith(
      isCompleted: !todo.isCompleted,
      timeTakenMinutes: timeTakenMinutes ?? todo.timeTakenMinutes,
    );
    await updateTodo(updated);
  }
}

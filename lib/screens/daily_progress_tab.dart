// lib/screens/daily_progress_tab.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workon/models/entry.dart';
import 'package:workon/models/todo.dart';
import 'package:workon/providers/entry_provider.dart';
import 'package:workon/providers/todo_provider.dart';
import 'package:workon/widgets/add_entry_dialog.dart';
import 'package:workon/widgets/add_todo_dialog.dart';
import 'package:workon/widgets/entry_card.dart';
import 'package:workon/widgets/custom_app_bar.dart';

class DailyProgressTab extends StatefulWidget {
  const DailyProgressTab({super.key});

  @override
  State<DailyProgressTab> createState() => DailyProgressTabState(); // ← NOW PUBLIC!
}

// ← REMOVED _ FROM STATE NAME
class DailyProgressTabState extends State<DailyProgressTab> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  // Public method for FAB to call
  void showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Add New",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(
                Icons.work_outline,
                color: Colors.indigo,
                size: 32,
              ),
              title: const Text("Log Work", style: TextStyle(fontSize: 18)),
              subtitle: const Text("Track time spent on tasks"),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AddEntryDialog(date: _selectedDate),
                );
              },
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(
                Icons.check_box_outlined,
                color: Colors.green,
                size: 32,
              ),
              title: const Text("Add Todo", style: TextStyle(fontSize: 18)),
              subtitle: const Text("Create a task with due date"),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AddTodoDialog(initialDate: _selectedDate),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Daily Progress",
        onSettingsTap: () => Navigator.pushNamed(context, '/settings'),
        onTitlesTap: () => Navigator.pushNamed(context, '/titles'),
      ),
      body: Column(
        children: [
          // Calendar
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Consumer2<EntryProvider, TodoProvider>(
              builder: (context, entryProvider, todoProvider, _) {
                return TableCalendar(
                  firstDay: DateTime(2020),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDate,
                  selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                      _focusedDate = focusedDay;
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(color: Colors.red),
                    selectedDecoration: BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.indigoAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildDay(day, entryProvider, todoProvider);
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return _buildDay(
                        day,
                        entryProvider,
                        todoProvider,
                        isSelected: true,
                      );
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildDay(
                        day,
                        entryProvider,
                        todoProvider,
                        isToday: true,
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _statChip("Work Logged", Icons.timer, Colors.indigo),
                const SizedBox(width: 12),
                _statChip("Pending Todos", Icons.pending_actions, Colors.red),
                const SizedBox(width: 12),
                _statChip("Completed", Icons.check_circle, Colors.green),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Entries List
          Expanded(
            child: Consumer<EntryProvider>(
              builder: (context, provider, _) {
                final entries = provider.getEntriesForDate(_selectedDate);
                if (entries.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No work logged",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text("Tap + to start tracking"),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: entries.length,
                  itemBuilder: (context, i) => EntryCard(entry: entries[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDay(
    DateTime day,
    EntryProvider entryProvider,
    TodoProvider todoProvider, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    final hasWork = entryProvider.getEntriesForDate(day).isNotEmpty;
    final pendingTodos = todoProvider
        .getTodosForDate(day)
        .where((t) => !t.isCompleted)
        .toList();
    final hasPendingTodo = pendingTodos.isNotEmpty;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: hasPendingTodo
            ? Colors.red.withOpacity(isSelected ? 0.3 : 0.15)
            : (isToday ? Colors.indigo.withOpacity(0.2) : null),
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: Colors.indigo, width: 2) : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              "${day.day}",
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Colors.indigo : null,
              ),
            ),
          ),
          if (hasWork)
            const Positioned(
              top: 4,
              right: 4,
              child: Icon(Icons.circle, size: 8, color: Colors.indigo),
            ),
          if (hasPendingTodo)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${pendingTodos.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statChip(String label, IconData icon, Color color) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      avatar: Icon(icon, size: 16, color: color),
      backgroundColor: color.withOpacity(0.1),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

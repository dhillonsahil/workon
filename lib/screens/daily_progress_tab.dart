// // lib/screens/daily_progress_tab.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:workon/models/entry.dart';
// import 'package:workon/models/todo.dart';
// import 'package:workon/providers/entry_provider.dart';
// import 'package:workon/providers/todo_provider.dart';
// import 'package:workon/providers/title_provider.dart';
// import 'package:workon/widgets/add_entry_dialog.dart';
// import 'package:workon/widgets/add_todo_dialog.dart';
// import 'package:workon/widgets/entry_card.dart';
// import 'package:workon/widgets/custom_app_bar.dart';

// class DailyProgressTab extends StatefulWidget {
//   const DailyProgressTab({super.key});

//   @override
//   State<DailyProgressTab> createState() => DailyProgressTabState();
// }

// class DailyProgressTabState extends State<DailyProgressTab> {
//   DateTime _selectedDate = DateTime.now();
//   DateTime _focusedDate = DateTime.now();
//   String? selectedFilter; // ← For tag filtering

//   void showAddOptions() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 60,
//               height: 5,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(3),
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               "Add New",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 24),
//             ListTile(
//               leading: const Icon(
//                 Icons.work_outline,
//                 color: Colors.indigo,
//                 size: 32,
//               ),
//               title: const Text("Log Work", style: TextStyle(fontSize: 18)),
//               subtitle: const Text("Track time spent on tasks"),
//               onTap: () {
//                 Navigator.pop(context);
//                 showDialog(
//                   context: context,
//                   builder: (_) => AddEntryDialog(date: _selectedDate),
//                 );
//               },
//             ),
//             const Divider(height: 32),
//             ListTile(
//               leading: const Icon(
//                 Icons.check_box_outlined,
//                 color: Colors.green,
//                 size: 32,
//               ),
//               title: const Text("Add Todo", style: TextStyle(fontSize: 18)),
//               subtitle: const Text("Create a task with due date"),
//               onTap: () {
//                 Navigator.pop(context);
//                 showDialog(
//                   context: context,
//                   builder: (_) => AddTodoDialog(initialDate: _selectedDate),
//                 );
//               },
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: "Daily Progress",
//         onSettingsTap: () => Navigator.pushNamed(context, '/settings'),
//         onTitlesTap: () => Navigator.pushNamed(context, '/titles'),
//       ),
//       body: Column(
//         children: [
//           // Calendar
//           Card(
//             margin: const EdgeInsets.all(16),
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Consumer2<EntryProvider, TodoProvider>(
//               builder: (context, entryProvider, todoProvider, _) {
//                 return TableCalendar(
//                   firstDay: DateTime(2020),
//                   lastDay: DateTime.now().add(const Duration(days: 365)),
//                   focusedDay: _focusedDate,
//                   selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
//                   onDaySelected: (selectedDay, focusedDay) {
//                     setState(() {
//                       _selectedDate = selectedDay;
//                       _focusedDate = focusedDay;
//                       selectedFilter = null; // Reset filter when changing day
//                     });
//                   },
//                   calendarFormat: CalendarFormat.month,
//                   startingDayOfWeek: StartingDayOfWeek.monday,
//                   headerStyle: const HeaderStyle(
//                     formatButtonVisible: false,
//                     titleCentered: true,
//                   ),
//                   calendarStyle: const CalendarStyle(outsideDaysVisible: false),
//                   calendarBuilders: CalendarBuilders(
//                     defaultBuilder: (context, day, focusedDay) =>
//                         _buildDayCell(day, entryProvider, todoProvider),
//                     selectedBuilder: (context, day, focusedDay) =>
//                         _buildDayCell(
//                           day,
//                           entryProvider,
//                           todoProvider,
//                           isSelected: true,
//                         ),
//                     todayBuilder: (context, day, focusedDay) => _buildDayCell(
//                       day,
//                       entryProvider,
//                       todoProvider,
//                       isToday: true,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           // Filter Chips — Horizontal scrollable, no overflow
//           Consumer<TitleProvider>(
//             builder: (context, titleProvider, _) {
//               final tags = titleProvider.tags.toList();
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: [
//                       FilterChip(
//                         label: const Text("All"),
//                         selected: selectedFilter == null,
//                         onSelected: (_) =>
//                             setState(() => selectedFilter = null),
//                       ),
//                       const SizedBox(width: 8),
//                       ...tags.map(
//                         (tag) => Padding(
//                           padding: const EdgeInsets.only(right: 8),
//                           child: FilterChip(
//                             label: Text("#$tag"),
//                             selected: selectedFilter == tag,
//                             onSelected: (_) => setState(
//                               () => selectedFilter = selectedFilter == tag
//                                   ? null
//                                   : tag,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 16),

//           // Entries List
//           Expanded(
//             child: Consumer<EntryProvider>(
//               builder: (context, provider, _) {
//                 var entries = provider.getEntriesForDate(_selectedDate);
//                 if (selectedFilter != null) {
//                   entries = entries
//                       .where((e) => e.tag == selectedFilter)
//                       .toList();
//                 }

//                 return entries.isEmpty
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.work_off,
//                               size: 80,
//                               color: Colors.grey[400],
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               "No work logged${selectedFilter != null ? " for #$selectedFilter" : ""}",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             ElevatedButton.icon(
//                               onPressed: showAddOptions,
//                               icon: const Icon(Icons.add),
//                               label: const Text("Add Something"),
//                             ),
//                           ],
//                         ),
//                       )
//                     : ListView.builder(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         itemCount: entries.length,
//                         itemBuilder: (context, i) => Padding(
//                           padding: const EdgeInsets.only(bottom: 8),
//                           child: EntryCard(entry: entries[i]),
//                         ),
//                       );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDayCell(
//     DateTime day,
//     EntryProvider entryProvider,
//     TodoProvider todoProvider, {
//     bool isSelected = false,
//     bool isToday = false,
//   }) {
//     final hasEntry = entryProvider.getEntriesForDate(day).isNotEmpty;
//     final pendingTodos = todoProvider
//         .getTodosForDate(day)
//         .where((t) => !t.isCompleted)
//         .length;

//     return Container(
//       margin: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: pendingTodos > 0
//             ? Colors.red.withOpacity(isSelected ? 0.3 : 0.15)
//             : (isToday ? Colors.indigo.withOpacity(0.2) : null),
//         borderRadius: BorderRadius.circular(12),
//         border: isSelected ? Border.all(color: Colors.indigo, width: 2) : null,
//       ),
//       child: Stack(
//         children: [
//           Center(
//             child: Text(
//               "${day.day}",
//               style: TextStyle(fontWeight: isToday ? FontWeight.bold : null),
//             ),
//           ),
//           if (hasEntry)
//             const Positioned(
//               top: 4,
//               right: 4,
//               child: Icon(Icons.circle, size: 8, color: Colors.indigo),
//             ),
//           if (pendingTodos > 0)
//             Positioned(
//               bottom: 4,
//               right: 4,
//               child: CircleAvatar(
//                 radius: 10,
//                 backgroundColor: Colors.red,
//                 child: Text(
//                   "$pendingTodos",
//                   style: const TextStyle(fontSize: 10, color: Colors.white),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
// lib/screens/daily_progress_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/entry.dart';
import '../models/todo.dart';
import '../providers/entry_provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/add_entry_dialog.dart';
import '../widgets/add_todo_dialog.dart';
import '../widgets/entry_card.dart';
import '../widgets/todo_card.dart'; // ← MAKE SURE THIS IS IMPORTED
import '../widgets/custom_app_bar.dart';

class DailyProgressTab extends StatefulWidget {
  const DailyProgressTab({super.key});

  @override
  State<DailyProgressTab> createState() => DailyProgressTabState();
}

class DailyProgressTabState extends State<DailyProgressTab> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  int _filterMode = 0; // 0=All, 1=Work, 2=Todo

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
              title: const Text("Log Work"),
              subtitle: const Text("Track time spent"),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AddEntryDialog(date: _selectedDate),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.check_box_outlined,
                color: Colors.green,
                size: 32,
              ),
              title: const Text("Add Todo"),
              subtitle: const Text("Create a task"),
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
          // Calendar (same as before)
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
                  onDaySelected: (sd, fd) => setState(() {
                    _selectedDate = sd;
                    _focusedDate = fd;
                    _filterMode = 0;
                  }),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: const CalendarStyle(outsideDaysVisible: false),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (_, day, __) =>
                        _buildDayCell(day, entryProvider, todoProvider),
                    selectedBuilder: (_, day, __) => _buildDayCell(
                      day,
                      entryProvider,
                      todoProvider,
                      isSelected: true,
                    ),
                    todayBuilder: (_, day, __) => _buildDayCell(
                      day,
                      entryProvider,
                      todoProvider,
                      isToday: true,
                    ),
                  ),
                );
              },
            ),
          ),

          // YOUR FAVORITE 3-CHIP ROW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filterChip("All", 0, Icons.auto_stories_rounded, Colors.grey),
                _filterChip("Work", 1, Icons.work_rounded, Colors.indigo),
                _filterChip("Todo", 2, Icons.checklist_rounded, Colors.green),
              ],
            ),
          ),

          // LIST — FIXED: No more type cast error + LIVE UPDATES
          Expanded(
            child: Consumer2<EntryProvider, TodoProvider>(
              builder: (context, entryProvider, todoProvider, child) {
                final workEntries = entryProvider.getEntriesForDate(
                  _selectedDate,
                );
                final todos = todoProvider.getTodosForDate(_selectedDate);

                // Build list of WIDGETS (not mixed types)
                final List<Widget> items = [];

                if (_filterMode == 0 || _filterMode == 1) {
                  for (var e in workEntries) {
                    items.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: EntryCard(entry: e),
                      ),
                    );
                  }
                }
                if (_filterMode == 0 || _filterMode == 2) {
                  for (var t in todos) {
                    items.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: TodoCard(todo: t),
                      ),
                    );
                  }
                }

                return items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sentiment_dissatisfied,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _filterMode == 1
                                  ? "No work logged"
                                  : _filterMode == 2
                                  ? "No todos"
                                  : "Nothing here yet",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: showAddOptions,
                              icon: const Icon(Icons.add),
                              label: const Text("Add Something"),
                            ),
                          ],
                        ),
                      )
                    : ListView(children: items);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, int mode, IconData icon, Color color) {
    final selected = _filterMode == mode;
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 18, color: selected ? Colors.white : color),
      selected: selected,
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : color,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (_) => setState(() => _filterMode = mode),
    );
  }

  Widget _buildDayCell(
    DateTime day,
    EntryProvider ep,
    TodoProvider tp, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    final hasWork = ep.getEntriesForDate(day).isNotEmpty;
    final pending = tp.getTodosForDate(day).where((t) => !t.isCompleted).length;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: pending > 0
            ? Colors.red.withOpacity(0.15)
            : (isToday ? Colors.indigo.withOpacity(0.1) : null),
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: Colors.indigo, width: 2) : null,
      ),
      child: Stack(
        children: [
          Center(child: Text("${day.day}")),
          if (hasWork)
            const Positioned(
              top: 4,
              right: 4,
              child: Icon(Icons.circle, size: 8, color: Colors.indigo),
            ),
          if (pending > 0)
            Positioned(
              bottom: 4,
              right: 4,
              child: CircleAvatar(
                radius: 9,
                backgroundColor: Colors.red,
                child: Text(
                  "$pending",
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

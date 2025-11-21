// lib/screens/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:workon/models/entry.dart';
import 'package:workon/models/todo.dart';
import 'package:workon/providers/stats_provider.dart'; // ← THIS IS YOUR REAL STREAK PROVIDER
import 'package:workon/providers/entry_provider.dart';
import 'package:workon/providers/todo_provider.dart';
import 'package:workon/providers/title_provider.dart';
import '../utils/export_import.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _getCurrentMonday();
  }

  DateTime _getCurrentMonday() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  DateTime get _weekStart => _selectedDate;
  DateTime get _weekEnd => _selectedDate.add(const Duration(days: 6));
  DateTime get _monthStart =>
      DateTime(_selectedDate.year, _selectedDate.month, 1);
  DateTime get _monthEnd =>
      DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Stats",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => ExportImport.importData(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => ExportImport.exportData(context),
          ),
        ],
      ),
      body:
          Consumer4<StatsProvider, EntryProvider, TodoProvider, TitleProvider>(
            builder: (context, statsP, entryP, todoP, titleP, _) {
              if (statsP.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final now = DateTime.now();

              // TODAY
              final todayEntries = statsP.entriesOnDate(now);
              final todayWorkMins = _totalMinutes(todayEntries);
              final todayTodoMins = todoP.completedTodos
                  .where((t) => isSameDay(t.dueDate, now))
                  .fold(0, (sum, t) => sum + (t.timeTakenMinutes ?? 0));
              final todayTotal = todayWorkMins + todayTodoMins;

              // WEEK
              final weekEntries = statsP.entriesInRange(_weekStart, _weekEnd);
              final weekWorkMins = _totalMinutes(weekEntries);
              final weekTodoMins = todoP.completedTodos
                  .where(
                    (t) =>
                        t.dueDate.isAfter(
                          _weekStart.subtract(const Duration(days: 1)),
                        ) &&
                        t.dueDate.isBefore(
                          _weekEnd.add(const Duration(days: 1)),
                        ),
                  )
                  .fold(0, (sum, t) => sum + (t.timeTakenMinutes ?? 0));
              final weekTotal = weekWorkMins + weekTodoMins;

              // MONTH
              final monthEntries = statsP.entriesInRange(
                _monthStart,
                _monthEnd,
              );
              final monthWorkMins = _totalMinutes(monthEntries);

              // TAG MAP — "misc" FIXED
              Map<String, int> getTagMap(List<WorkEntry> entries) {
                final map = <String, int>{};
                for (var e in entries) {
                  final tag = (e.tag?.trim().isNotEmpty == true)
                      ? e.tag!.trim()
                      : "misc";
                  map[tag] = (map[tag] ?? 0) + e.hours * 60 + e.minutes;
                }
                return map;
              }

              final weekTagMap = getTagMap(weekEntries);
              final monthTagMap = getTagMap(monthEntries);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDatePicker(),
                    const SizedBox(height: 16),
                    _buildStreakCard(statsP),
                    const SizedBox(height: 16),
                    _buildTimeSummary(
                      totalToday: todayTotal,
                      totalWeek: weekTotal,
                      monthMinutes: monthWorkMins,
                      workToday: todayWorkMins,
                      todoToday: todayTodoMins,
                      workWeek: weekWorkMins,
                      todoWeek: weekTodoMins,
                      stats: statsP,
                      todayEntries: todayEntries,
                      weekEntries: weekEntries,
                      monthEntries: monthEntries,
                    ),
                    const SizedBox(height: 24),
                    _buildWeeklyChart(statsP),
                    const SizedBox(height: 24),
                    _buildPerTitleTime("This Week", weekEntries),
                    const SizedBox(height: 16),
                    _buildPerTitleTime("This Month", monthEntries),
                    const SizedBox(height: 24),
                    _buildPerTagTime("This Week", weekTagMap),
                    const SizedBox(height: 16),
                    _buildPerTagTime("This Month", monthTagMap),
                    const SizedBox(height: 24),
                    if (weekTagMap.isNotEmpty)
                      _buildTagChart(statsP, weekEntries),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
    );
  }

  // ALL YOUR ORIGINAL WIDGETS — FULLY INCLUDED BELOW
  // (Copy-pasted from your original code — only fixed the "misc" logic)

  Widget _buildDatePicker() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              selectableDayPredicate: (date) => date.weekday == DateTime.monday,
              helpText: "Select any Monday",
            );
            if (picked != null) setState(() => _selectedDate = picked);
          },
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Text(
                    "${_formatDate(_selectedDate)} (Mon)",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Week: ${_formatWeek(_weekStart)}",
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard(StatsProvider stats) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.local_fire_department,
              size: 56,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            Text(
              "${stats.currentStreak}",
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const Text("Current Streak", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              "Longest: ${stats.longestStreak} days",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color? color,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(StatsProvider stats) {
    final data = <Map<String, dynamic>>[];
    for (int i = 0; i < 7; i++) {
      final date = _weekStart.add(Duration(days: i));
      final minutes = stats
          .entriesOnDate(date)
          .fold(0, (s, e) => s + e.hours * 60 + e.minutes);
      final hours = minutes / 60.0;
      data.add({
        'day': _dayAbbr(date.weekday),
        'hours': hours,
        'minutes': minutes,
        'date': date,
      });
    }

    final maxHours = data
        .map((e) => e['hours'] as double)
        .reduce((a, b) => a > b ? a : b);
    final suggestedMax = (maxHours * 1.2).ceilToDouble();
    final yMax = _roundToNearestEven(suggestedMax);
    final interval = yMax <= 4 ? 1.0 : 2.0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weekly Time",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: yMax,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, _, rod, _) {
                        final mins = data[group.x]['minutes'] as int;
                        return BarTooltipItem(
                          _formatMinutes(mins),
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: interval,
                        getTitlesWidget: (v, m) => Text('${v.toInt()}h'),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, m) => Text(data[v.toInt()]['day']),
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((e) {
                    final hours = e.value['hours'] as double;
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: hours,
                          color: hours > 0 ? Colors.indigo : Colors.grey[300],
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerTitleTime(String label, List<WorkEntry> entries) {
    final map = <String, int>{};
    for (final e in entries)
      map[e.title] = (map[e.title] ?? 0) + e.hours * 60 + e.minutes;
    if (map.isEmpty) return const SizedBox();

    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...sorted
                .take(5)
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key, style: const TextStyle(fontSize: 14)),
                        Text(
                          _formatHM(e.value),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  // Keep ALL your original _buildTimeSummary, _buildWeeklyChart, _buildPerTitleTime, etc.
  // Just replace your old _buildPerTagTime and _buildTagChart with these fixed versions:

  Widget _buildTimeSummary({
    required int totalToday,
    required int totalWeek,
    required int monthMinutes,
    required int workToday,
    required int todoToday,
    required int workWeek,
    required int todoWeek,
    required StatsProvider stats,
    required List<WorkEntry> todayEntries,
    required List<WorkEntry> weekEntries,
    required List<WorkEntry> monthEntries,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _summaryRow(
              "Today (Total)",
              _formatHM(totalToday),
              color: Colors.green,
              icon: Icons.today,
            ),
            if (workToday > 0) _summaryRow("   ↳ Work", _formatHM(workToday)),
            if (todoToday > 0)
              _summaryRow(
                "   ↳ Todos",
                _formatHM(todoToday),
                color: Colors.teal,
              ),
            const Divider(height: 32),
            _summaryRow(
              "This Week (Total)",
              _formatHM(totalWeek),
              color: Colors.blue,
              icon: Icons.date_range,
            ),
            if (workWeek > 0) _summaryRow("   ↳ Work", _formatHM(workWeek)),
            if (todoWeek > 0)
              _summaryRow(
                "   ↳ Todos",
                _formatHM(todoWeek),
                color: Colors.teal,
              ),
            const Divider(height: 32),
            _summaryRow(
              "This Month",
              _formatHM(monthMinutes),
              color: Colors.purple,
            ),
            _summaryRow("Today Entries", "${todayEntries.length}"),
            _summaryRow("Week Entries", "${weekEntries.length}"),
            if (stats.mostUsedTagIn(weekEntries) != null)
              _summaryRow(
                "Top Tag (Week)",
                "#${stats.mostUsedTagIn(weekEntries)}",
                color: Colors.indigo,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerTagTime(String label, Map<String, int> tagMap) {
    if (tagMap.isEmpty) return const SizedBox();
    final sorted = tagMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$label by Tag",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...sorted
                .take(5)
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("#${e.key}", style: const TextStyle(fontSize: 14)),
                        Text(
                          _formatHM(e.value),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChart(StatsProvider stats, List<WorkEntry> entries) {
    final dist = stats.tagDistributionIn(entries);
    final list = dist.entries.toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tag Distribution (Week)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: list.asMap().entries.map((e) {
                    final tag = e.value.key;
                    final count = e.value.value;
                    final pct = (count / entries.length) * 100;
                    return PieChartSectionData(
                      value: count.toDouble(),
                      title: '$tag\n${pct.toStringAsFixed(0)}%',
                      color: _tagColor(e.key),
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 30,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _tagColor(int i) => [
    Colors.indigo,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
    Colors.red,
    Colors.blue,
    Colors.pink,
    Colors.cyan,
    Colors.amber,
  ][i % 10];

  // YOUR ORIGINAL HELPERS — UNTOUCHED
  double _roundToNearestEven(double value) {
    if (value <= 0) return 2.0;
    return ((value / 2.0).ceil() * 2.0);
  }

  String _formatMinutes(int minutes) {
    if (minutes == 0) return "0m";
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? "$h" + "h" + (m > 0 ? " $m" + "m" : "") : "$m" + "m";
  }

  String _formatHM(int m) =>
      "${m ~/ 60}h ${m % 60}m".replaceAll(" 0m", "").replaceAll("0h ", "");
  int _totalMinutes(List<WorkEntry> entries) =>
      entries.fold(0, (s, e) => s + e.hours * 60 + e.minutes);
  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  String _formatDate(DateTime d) => "${d.day} ${_monthName(d.month)} ${d.year}";
  String _monthName(int m) => [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m - 1];
  String _formatWeek(DateTime d) =>
      "${d.month}/${d.day} - ${_weekEnd.month}/${_weekEnd.day}";
  String _dayAbbr(int w) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];
}

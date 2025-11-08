// // lib/screens/stats_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:workon/models/entry.dart';
// import '../providers/stats_provider.dart';
// import '../utils/export_import.dart';

// class StatsScreen extends StatefulWidget {
//   const StatsScreen({super.key});

//   @override
//   State<StatsScreen> createState() => _StatsScreenState();
// }

// class _StatsScreenState extends State<StatsScreen> {
//   // DateTime _selectedDate = DateTime.now();
//   late DateTime _selectedDate;

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   Future.microtask(() => context.read<StatsProvider>().loadStats());
//   // }
//   DateTime _getCurrentMonday() {
//     final now = DateTime.now();
//     return now.subtract(Duration(days: now.weekday - 1));
//   }

//   @override
//   void initState() {
//     super.initState();

//     // SET DEFAULT TO MONDAY
//     _selectedDate = _getCurrentMonday();

//     // LOAD DATA
//     Future.microtask(() {
//       context.read<StatsProvider>().loadStats();
//     });
//   }

//   // DateTime get _weekStart =>
//   //     _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
//   // DateTime get _weekEnd => _weekStart.add(const Duration(days: 6));
//   DateTime get _weekStart =>
//       _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
//   DateTime get _weekEnd => _weekStart.add(const Duration(days: 6));
//   DateTime get _monthStart =>
//       DateTime(_selectedDate.year, _selectedDate.month, 1);
//   DateTime get _monthEnd =>
//       DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Stats",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.upload_file),
//             onPressed: () => ExportImport.importData(context),
//           ),
//           IconButton(
//             icon: const Icon(Icons.download),
//             onPressed: () => ExportImport.exportData(context),
//           ),
//         ],
//       ),
//       body: Consumer<StatsProvider>(
//         builder: (context, stats, child) {
//           if (stats.isLoading)
//             return const Center(child: CircularProgressIndicator());

//           // final weekEntries = stats.entriesInRange(_weekStart, _weekEnd);
//           // final monthEntries = stats.entriesInRange(_monthStart, _monthEnd);
//           // final todayEntries = stats.entriesOnDate(_selectedDate);
//           // final isToday = _isSameDay(_selectedDate, DateTime.now());

//           // final weekMinutes = _totalMinutes(weekEntries);
//           // final monthMinutes = _totalMinutes(monthEntries);
//           // final todayMinutes = _totalMinutes(todayEntries);
//           final weekEntries = stats.entriesInRange(_weekStart, _weekEnd);
//           final monthEntries = stats.entriesInRange(_monthStart, _monthEnd);
//           final todayEntries = stats.entriesOnDate(_selectedDate);
//           final isToday = _isSameDay(_selectedDate, DateTime.now());

//           final todayMinutes = _totalMinutes(todayEntries);
//           final weekMinutes = _totalMinutes(weekEntries);
//           final monthMinutes = _totalMinutes(monthEntries);

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // DATE PICKER + INFO
//                 _buildDatePicker(stats),

//                 const SizedBox(height: 16),

//                 // STREAK
//                 _buildStreakCard(stats),

//                 const SizedBox(height: 16),

//                 // TIME SUMMARY
//                 _buildTimeSummary(
//                   todayMinutes: todayMinutes,
//                   weekMinutes: weekMinutes,
//                   monthMinutes: monthMinutes,
//                   stats: stats,
//                   todayEntries: todayEntries,
//                   weekEntries: weekEntries,
//                   monthEntries: monthEntries,
//                 ),

//                 const SizedBox(height: 24),

//                 // WEEKLY BAR CHART (HOURS)
//                 _buildWeeklyChart(stats),

//                 const SizedBox(height: 24),

//                 // PER-TITLE TIME
//                 _buildPerTitleTime("This Week", weekEntries),
//                 const SizedBox(height: 16),
//                 _buildPerTitleTime("This Month", monthEntries),
//                 if (isToday) ...[
//                   const SizedBox(height: 16),
//                   _buildPerTitleTime("Today", todayEntries),
//                 ],

//                 const SizedBox(height: 24),

//                 // PER-TAG TIME
//                 _buildPerTagTime("This Week", weekEntries),
//                 const SizedBox(height: 16),
//                 _buildPerTagTime("This Month", monthEntries),
//                 if (isToday) ...[
//                   const SizedBox(height: 16),
//                   _buildPerTagTime("Today", todayEntries),
//                 ],

//                 const SizedBox(height: 24),

//                 // TAG PIE CHART
//                 if (stats.tagDistributionIn(weekEntries).isNotEmpty)
//                   _buildTagChart(stats, weekEntries),

//                 const SizedBox(height: 16),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDatePicker(StatsProvider stats) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             InkWell(
//               // onTap: () async {
//               //   final picked = await showDatePicker(
//               //     context: context,
//               //     initialDate: _weekStart, // Force Monday
//               //     firstDate: DateTime(2020),
//               //     lastDate: DateTime.now(),
//               //     selectableDayPredicate: (date) =>
//               //         date.weekday == DateTime.monday,
//               //     helpText: "Select Monday to view full week",
//               //   );
//               //   if (picked != null) {
//               //     setState(() {
//               //       _selectedDate = picked;
//               //       // _weekStart is auto-calculated from picked Monday
//               //     });
//               //   }
//               // },
//               onTap: () async {
//                 final picked = await showDatePicker(
//                   context: context,
//                   initialDate: _selectedDate,
//                   firstDate: DateTime(2020),
//                   lastDate: DateTime.now(),
//                   selectableDayPredicate: (date) =>
//                       date.weekday == DateTime.monday,
//                   helpText: "Select Monday to view full week",
//                 );
//                 if (picked != null) {
//                   setState(() => _selectedDate = picked); // picked is Monday
//                 }
//               },
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.calendar_today, color: Colors.indigo),
//                   const SizedBox(width: 8),
//                   Text(
//                     "${_formatDate(_selectedDate)}",
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               "Week: ${_formatWeek(_weekStart)} (Mon–Sun)",
//               style: const TextStyle(fontSize: 13, color: Colors.grey),
//             ),
//             const Text(
//               "Select any date → shows full week starting Monday",
//               style: TextStyle(fontSize: 11, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStreakCard(StatsProvider stats) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const Icon(
//               Icons.local_fire_department,
//               size: 48,
//               color: Colors.orange,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               "${stats.currentStreak}",
//               style: const TextStyle(
//                 fontSize: 48,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.orange,
//               ),
//             ),
//             const Text(
//               "Current Streak",
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "Longest: ${stats.longestStreak} days",
//               style: const TextStyle(fontSize: 14, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   double _roundToNearestEven(double value) {
//     final rounded = ((value / 2).ceil() * 2).toDouble(); // FORCE DOUBLE
//     return rounded > 0 ? rounded : 2.0;
//   }

//   // double _roundToNearestEven(double value) {
//   //   final half = value / 2.0;
//   //   final roundedHalf = half.ceil();
//   //   final result = roundedHalf * 2.0;
//   //   return result > 0 ? result : 2.0;
//   // }

//   String _formatMinutes(int minutes) {
//     if (minutes == 0) return "0m";
//     final h = minutes ~/ 60;
//     final m = minutes % 60;
//     return h > 0 ? "$h" + "h" + (m > 0 ? " $m" + "m" : "") : "$m" + "m";
//   }

//   // Widget _buildTimeSummary({
//   //   required bool isToday,
//   //   required int todayMinutes,
//   //   required int weekMinutes,
//   //   required int monthMinutes,
//   //   required StatsProvider stats,
//   //   required List<WorkEntry> todayEntries,
//   //   required List<WorkEntry> weekEntries,
//   //   required List<WorkEntry> monthEntries,
//   // }) {
//   //   // CORRECT ENTRY COUNTS — NO OVERLAP
//   //   final todayCount = isToday ? todayEntries.length : 0;
//   //   final weekCount = weekEntries.length;
//   //   final monthCount = monthEntries.length;

//   //   return Card(
//   //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//   //     child: Padding(
//   //       padding: const EdgeInsets.all(16),
//   //       child: Column(
//   //         children: [
//   //           // TODAY
//   //           if (isToday)
//   //             _summaryRow(
//   //               "Today",
//   //               _formatHM(todayMinutes),
//   //               color: Colors.green,
//   //             ),

//   //           // THIS WEEK
//   //           _summaryRow(
//   //             "This Week",
//   //             _formatHM(weekMinutes),
//   //             color: Colors.blue,
//   //           ),

//   //           // THIS MONTH
//   //           _summaryRow(
//   //             "This Month",
//   //             _formatHM(monthMinutes),
//   //             color: Colors.purple,
//   //           ),

//   //           const Divider(height: 20),

//   //           // CORRECT ENTRY COUNTS
//   //           if (isToday) _summaryRow("Today Entries", "$todayCount"),
//   //           _summaryRow("Week Entries", "$weekCount"),
//   //           _summaryRow("Month Entries", "$monthCount"),

//   //           // TOP TAG
//   //           if (stats.mostUsedTagIn(weekEntries) != null)
//   //             _summaryRow(
//   //               "Top Tag (Week)",
//   //               "#${stats.mostUsedTagIn(weekEntries)}",
//   //               color: Colors.indigo,
//   //             ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   Widget _buildTimeSummary({
//     required int todayMinutes,
//     required int weekMinutes,
//     required int monthMinutes,
//     required StatsProvider stats,
//     required List<WorkEntry> todayEntries,
//     required List<WorkEntry> weekEntries,
//     required List<WorkEntry> monthEntries,
//   }) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // TODAY = ALWAYS DateTime.now()
//             _summaryRow("Today", _formatHM(todayMinutes), color: Colors.green),

//             // THIS WEEK (based on selected Monday)
//             _summaryRow(
//               "This Week",
//               _formatHM(weekMinutes),
//               color: Colors.blue,
//             ),

//             // THIS MONTH
//             _summaryRow(
//               "This Month",
//               _formatHM(monthMinutes),
//               color: Colors.purple,
//             ),

//             const Divider(height: 20),

//             // ENTRIES
//             _summaryRow("Today Entries", "${todayEntries.length}"),
//             _summaryRow("Week Entries", "${weekEntries.length}"),
//             _summaryRow("Month Entries", "${monthEntries.length}"),

//             // TOP TAG (Week)
//             if (stats.mostUsedTagIn(weekEntries) != null)
//               _summaryRow(
//                 "Top Tag (Week)",
//                 "#${stats.mostUsedTagIn(weekEntries)}",
//                 color: Colors.indigo,
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWeeklyChart(StatsProvider stats) {
//     final data = <Map<String, dynamic>>[];
//     for (int i = 0; i < 7; i++) {
//       final date = _weekStart.add(Duration(days: i));
//       final minutes = stats
//           .entriesOnDate(date)
//           .fold(0, (s, e) => s + e.hours * 60 + e.minutes);
//       final hours = minutes / 60.0; // EXACT HOURS (0.1 for 6 mins)
//       data.add({
//         'day': _dayAbbr(date.weekday),
//         'hours': hours,
//         'minutes': minutes,
//         'date': date,
//       });
//     }

//     // Find max hours for scaling
//     final maxHours = data
//         .map((e) => e['hours'] as double)
//         .reduce((a, b) => a > b ? a : b);
//     final suggestedMax = (maxHours * 1.2).ceilToDouble(); // 20% padding
//     final yMax = _roundToNearestEven(suggestedMax); // 2, 4, 6, 8...
//     final interval = yMax <= 4 ? 1.0 : 2.0;

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Weekly Time",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               height: 200,
//               child: BarChart(
//                 BarChartData(
//                   alignment: BarChartAlignment.spaceAround,
//                   maxY: yMax,
//                   barTouchData: BarTouchData(
//                     touchTooltipData: BarTouchTooltipData(
//                       getTooltipItem: (group, _, rod, _) {
//                         final mins = data[group.x]['minutes'] as int;
//                         return BarTooltipItem(
//                           _formatMinutes(mins),
//                           const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   titlesData: FlTitlesData(
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         interval: interval,
//                         getTitlesWidget: (value, meta) => Text(
//                           '${value.toInt()}h',
//                           style: const TextStyle(fontSize: 11),
//                         ),
//                       ),
//                     ),
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         getTitlesWidget: (value, meta) => Text(
//                           data[value.toInt()]['day'],
//                           style: const TextStyle(fontSize: 12),
//                         ),
//                       ),
//                     ),
//                     topTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                     rightTitles: const AxisTitles(
//                       sideTitles: SideTitles(showTitles: false),
//                     ),
//                   ),
//                   gridData: const FlGridData(show: true),
//                   borderData: FlBorderData(show: false),
//                   barGroups: data.asMap().entries.map((e) {
//                     final hours = e.value['hours'] as double;
//                     return BarChartGroupData(
//                       x: e.key,
//                       barRods: [
//                         BarChartRodData(
//                           toY: hours,
//                           color: hours > 0 ? Colors.indigo : Colors.grey[300],
//                           width: 16,
//                           borderRadius: const BorderRadius.vertical(
//                             top: Radius.circular(6),
//                           ),
//                         ),
//                       ],
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPerTitleTime(String label, List<WorkEntry> entries) {
//     final map = <String, int>{};
//     for (final e in entries) {
//       map[e.title] = (map[e.title] ?? 0) + e.hours * 60 + e.minutes;
//     }
//     if (map.isEmpty) return const SizedBox();

//     final sorted = map.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             ...sorted
//                 .take(5)
//                 .map(
//                   (e) => Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 2),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(e.key, style: const TextStyle(fontSize: 14)),
//                         Text(
//                           _formatHM(e.value),
//                           style: const TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPerTagTime(String label, List<WorkEntry> entries) {
//     final map = <String, int>{};
//     for (final e in entries) {
//       if (e.tag != null) {
//         map[e.tag!] = (map[e.tag!] ?? 0) + e.hours * 60 + e.minutes;
//       }
//     }
//     if (map.isEmpty) return const SizedBox();

//     final sorted = map.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "$label by Tag",
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             ...sorted
//                 .take(5)
//                 .map(
//                   (e) => Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 2),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("#${e.key}", style: const TextStyle(fontSize: 14)),
//                         Text(
//                           _formatHM(e.value),
//                           style: const TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTagChart(StatsProvider stats, List<WorkEntry> entries) {
//     final dist = stats.tagDistributionIn(entries);
//     final list = dist.entries.toList();

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Tag Distribution (Week)",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               height: 200,
//               child: PieChart(
//                 PieChartData(
//                   sections: list.asMap().entries.map((e) {
//                     final tag = e.value.key;
//                     final count = e.value.value;
//                     final pct = (count / entries.length) * 100;
//                     return PieChartSectionData(
//                       value: count.toDouble(),
//                       title: '$tag\n${pct.toStringAsFixed(0)}%',
//                       color: _tagColor(e.key),
//                       radius: 60,
//                       titleStyle: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     );
//                   }).toList(),
//                   centerSpaceRadius: 30,
//                   sectionsSpace: 2,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _tagColor(int i) => [
//     Colors.indigo,
//     Colors.orange,
//     Colors.green,
//     Colors.purple,
//     Colors.teal,
//   ][i % 5];

//   String _formatDate(DateTime d) => "${d.day} ${_monthName(d.month)} ${d.year}";
//   String _monthName(int m) => [
//     'Jan',
//     'Feb',
//     'Mar',
//     'Apr',
//     'May',
//     'Jun',
//     'Jul',
//     'Aug',
//     'Sep',
//     'Oct',
//     'Nov',
//     'Dec',
//   ][m - 1];
//   String _dayAbbr(int w) =>
//       ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];
//   String _formatWeek(DateTime d) =>
//       "${d.month}/${d.day} - ${_weekEnd.month}/${_weekEnd.day}";
//   String _formatHM(int m) =>
//       "${m ~/ 60}h ${m % 60}m".replaceAll(" 0m", "").replaceAll("0h ", "");
//   // int _totalMinutes(List<WorkEntry> e) =>
//   //     e.fold(0, (s, x) => s + x.hours * 60 + x.minutes);
//   int _totalMinutes(List<WorkEntry> entries) {
//     return entries.fold(0, (sum, e) => sum + e.hours * 60 + e.minutes);
//   }

//   bool _isSameDay(DateTime a, DateTime b) =>
//       a.year == b.year && a.month == b.month && a.day == b.day;

//   Widget _summaryRow(String label, String value, {Color? color}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(fontSize: 15)),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// lib/screens/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:workon/models/entry.dart';
import '../providers/stats_provider.dart';
import '../utils/export_import.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late DateTime _selectedDate; // Always a MONDAY

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
    // FORCE RELOAD DATA EVERY BUILD
    Future.microtask(() => context.read<StatsProvider>().loadStats());

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
      body: Consumer<StatsProvider>(
        builder: (context, stats, child) {
          if (stats.isLoading)
            return const Center(child: CircularProgressIndicator());

          final now = DateTime.now();
          final todayEntries = stats.entriesOnDate(now); // TODAY = NOW
          final todayMinutes = _totalMinutes(todayEntries);

          final weekEntries = stats.entriesInRange(_weekStart, _weekEnd);
          final monthEntries = stats.entriesInRange(_monthStart, _monthEnd);

          final weekMinutes = _totalMinutes(weekEntries);
          final monthMinutes = _totalMinutes(monthEntries);

          final isToday = _isSameDay(
            _selectedDate,
            now,
          ); // For per-title/tag "Today"

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDatePicker(stats),
                const SizedBox(height: 16),
                _buildStreakCard(stats),
                const SizedBox(height: 16),
                _buildTimeSummary(
                  todayMinutes: todayMinutes,
                  weekMinutes: weekMinutes,
                  monthMinutes: monthMinutes,
                  stats: stats,
                  todayEntries: todayEntries,
                  weekEntries: weekEntries,
                  monthEntries: monthEntries,
                ),
                const SizedBox(height: 24),
                _buildWeeklyChart(stats),
                const SizedBox(height: 24),
                _buildPerTitleTime("This Week", weekEntries),
                const SizedBox(height: 16),
                _buildPerTitleTime("This Month", monthEntries),
                if (isToday) ...[
                  const SizedBox(height: 16),
                  _buildPerTitleTime("Today", todayEntries),
                ],
                const SizedBox(height: 24),
                _buildPerTagTime("This Week", weekEntries),
                const SizedBox(height: 16),
                _buildPerTagTime("This Month", monthEntries),
                if (isToday) ...[
                  const SizedBox(height: 16),
                  _buildPerTagTime("Today", todayEntries),
                ],
                const SizedBox(height: 24),
                if (stats.tagDistributionIn(weekEntries).isNotEmpty)
                  _buildTagChart(stats, weekEntries),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDatePicker(StatsProvider stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  selectableDayPredicate: (date) =>
                      date.weekday == DateTime.monday,
                  helpText: "Select Monday to view full week",
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Row(
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
            ),
            const SizedBox(height: 4),
            Text(
              "Week: ${_formatWeek(_weekStart)}",
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const Text(
              "Select any date → shows full week starting Monday",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(StatsProvider stats) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.local_fire_department,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            Text(
              "${stats.currentStreak}",
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const Text(
              "Current Streak",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              "Longest: ${stats.longestStreak} days",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSummary({
    required int todayMinutes,
    required int weekMinutes,
    required int monthMinutes,
    required StatsProvider stats,
    required List<WorkEntry> todayEntries,
    required List<WorkEntry> weekEntries,
    required List<WorkEntry> monthEntries,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _summaryRow("Today", _formatHM(todayMinutes), color: Colors.green),
            _summaryRow(
              "This Week",
              _formatHM(weekMinutes),
              color: Colors.blue,
            ),
            _summaryRow(
              "This Month",
              _formatHM(monthMinutes),
              color: Colors.purple,
            ),
            const Divider(height: 20),
            _summaryRow("Today Entries", "${todayEntries.length}"),
            _summaryRow("Week Entries", "${weekEntries.length}"),
            _summaryRow("Month Entries", "${monthEntries.length}"),
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

  Widget _buildPerTagTime(String label, List<WorkEntry> entries) {
    final map = <String, int>{};
    for (final e in entries)
      if (e.tag != null)
        map[e.tag!] = (map[e.tag!] ?? 0) + e.hours * 60 + e.minutes;
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

  Color _tagColor(int i) => [
    Colors.indigo,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
  ][i % 5];

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
  String _dayAbbr(int w) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];
  String _formatWeek(DateTime d) =>
      "${d.month}/${d.day} - ${_weekEnd.month}/${_weekEnd.day}";
  String _formatHM(int m) =>
      "${m ~/ 60}h ${m % 60}m".replaceAll(" 0m", "").replaceAll("0h ", "");
  int _totalMinutes(List<WorkEntry> entries) =>
      entries.fold(0, (s, e) => s + e.hours * 60 + e.minutes);
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
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
}

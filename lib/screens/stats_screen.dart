import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import '../providers/stats_provider.dart';
import '../utils/time_utils.dart';
import '../widgets/month_picker.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          StatsProvider(Provider.of<EntryProvider>(context, listen: false)),
      child: const _StatsScreenContent(),
    );
  }
}

class _StatsScreenContent extends StatelessWidget {
  const _StatsScreenContent();

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonthPicker(
            selectedMonth: stats.selectedMonth,
            onMonthChanged: (m) => context.read<StatsProvider>().setMonth(m),
          ),
          const SizedBox(height: 20),

          _buildSummaryCard(stats),
          const SizedBox(height: 16),

          _buildBarChart(context, stats), // Pass context
          const SizedBox(height: 16),

          _buildPerTitleCard(stats.perTitleMinutes),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(StatsProvider stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Monthly Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            _statRow("Total Time", formatMinutes(stats.totalMinutes)),
            _statRow("Daily Average", formatMinutes(stats.dailyAverage)),
            _statRow("Longest Streak", "${stats.longestStreak} days"),
            _statRow("Current Streak", "${stats.currentStreak} days"),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, StatsProvider stats) {
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);
    final year = stats.selectedMonth.year;
    final month = stats.selectedMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final data = List.generate(daysInMonth, (day) {
      final date = DateTime(year, month, day + 1);
      final minutes = entryProvider.totalMinutesForDate(date);
      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: minutes / 60.0,
            color: minutes > 0 ? Colors.indigo : Colors.grey[300],
            width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Daily Progress",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) =>
                            Text('${value.toInt()}h'),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) =>
                            Text('${value.toInt() + 1}'),
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),
                  barGroups: data,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerTitleCard(Map<String, int> titleMinutes) {
    if (titleMinutes.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("No data for this month."),
        ),
      );
    }

    final sorted = titleMinutes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Per Title",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...sorted.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      formatMinutes(e.value),
                      style: const TextStyle(color: Colors.indigo),
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
}

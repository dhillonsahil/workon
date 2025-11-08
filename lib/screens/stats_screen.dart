import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/stats_provider.dart';
import '../utils/export_import.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<StatsProvider>().loadStats());
  }

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
            tooltip: "Import",
            onPressed: () => ExportImport.importData(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Export",
            onPressed: () => ExportImport.exportData(context),
          ),
        ],
      ),
      body: Consumer<StatsProvider>(
        builder: (context, stats, child) {
          if (stats.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (stats.totalEntries == 0) {
            return const Center(
              child: Text(
                "No data yet.\nStart logging to see stats!",
                textAlign: TextAlign.center,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // STREAK CARD
                _buildStreakCard(stats),

                const SizedBox(height: 16),

                // TIME SUMMARY
                _buildTimeSummary(stats),

                const SizedBox(height: 24),

                // WEEKLY CHART
                _buildWeeklyChart(stats),

                const SizedBox(height: 24),

                // TAG PIE CHART
                if (stats.tagDistribution.isNotEmpty) _buildTagChart(stats),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
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

  Widget _buildTimeSummary(StatsProvider stats) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _summaryRow(
              "Total Time",
              "${stats.totalTimeInHours.toStringAsFixed(1)}h",
            ),
            const Divider(height: 20),
            _summaryRow("Today", _formatMinutes(stats.todayMinutes)),
            _summaryRow("This Week", _formatMinutes(stats.thisWeekMinutes)),
            _summaryRow("This Month", _formatMinutes(stats.thisMonthMinutes)),
            if (stats.mostUsedTag != null) ...[
              const Divider(height: 20),
              _summaryRow(
                "Top Tag",
                "#${stats.mostUsedTag}",
                color: Colors.indigo,
              ),
            ],
          ],
        ),
      ),
    );
  }

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

  Widget _buildWeeklyChart(StatsProvider stats) {
    final data = stats.weeklyData;
    final maxY = data
        .map((e) => e['minutes'] as int)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final interval = maxY > 60 ? (maxY / 5).ceilToDouble() : 15.0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This Week",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY + interval,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final minutes = data[group.x]['minutes'] as int;
                        return BarTooltipItem(
                          _formatMinutes(minutes),
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
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}m',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < data.length) {
                            return Text(
                              data[index]['day'],
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const Text('');
                        },
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
                    final index = e.key;
                    final minutes = e.value['minutes'] as int;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: minutes.toDouble(),
                          color: Colors.indigo,
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

  Widget _buildTagChart(StatsProvider stats) {
    final distribution = stats.tagDistribution;
    final entries = distribution.entries.toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tag Distribution",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: entries.asMap().entries.map((e) {
                    final index = e.key;
                    final tag = e.value.key;
                    final count = e.value.value;
                    final percentage = (count / stats.totalEntries) * 100;
                    return PieChartSectionData(
                      value: count.toDouble(),
                      title: '$tag\n${percentage.toStringAsFixed(0)}%',
                      color: _tagColor(index),
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

  Color _tagColor(int index) {
    const colors = [
      Colors.indigo,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.blue,
    ];
    return colors[index % colors.length];
  }

  String _formatMinutes(int minutes) {
    if (minutes == 0) return "0m";
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return "${h > 0 ? '${h}h ' : ''}${m}m";
  }
}

import 'package:flutter/material.dart';
import '../models/entry.dart';
import 'entry_provider.dart';

class StatsProvider with ChangeNotifier {
  final EntryProvider entryProvider;

  DateTime _selectedMonth = DateTime.now();
  DateTime get selectedMonth => _selectedMonth;

  StatsProvider(this.entryProvider) {
    entryProvider.addListener(_onEntriesChanged);
  }

  void _onEntriesChanged() => notifyListeners();

  void setMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  // === STATS GETTERS ===
  int get totalMinutes => entryProvider.totalMinutesForMonth(
    _selectedMonth.year,
    _selectedMonth.month,
  );

  int get dailyAverage {
    final daysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;
    final activeDays = _activeStudyDays().length;
    return activeDays == 0 ? 0 : totalMinutes ~/ activeDays;
  }

  int get longestStreak => _calculateLongestStreak();

  int get currentStreak {
    final today = DateTime.now();
    final studyDates = _getStudyDates();
    int streak = 0;
    var checkDate = today;

    while (studyDates.contains(_formatDate(checkDate))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Map<String, int> get perTitleMinutes => entryProvider.getTitleMinutesForMonth(
    _selectedMonth.year,
    _selectedMonth.month,
  );

  List<DateTime> _activeStudyDays() {
    final Set<String> dates = {};
    for (final e in entryProvider.entries) {
      if (e.date.year == _selectedMonth.year &&
          e.date.month == _selectedMonth.month) {
        dates.add(_formatDate(e.date));
      }
    }
    return dates.map(DateTime.parse).toList()..sort();
  }

  Set<String> _getStudyDates() {
    return entryProvider.entries.map((e) => _formatDate(e.date)).toSet();
  }

  int _calculateLongestStreak() {
    final dates = _getStudyDates();
    if (dates.isEmpty) return 0;

    final sorted = dates.map(DateTime.parse).toList()..sort();
    int maxStreak = 1;
    int current = 1;

    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      if (diff == 1) {
        current++;
        maxStreak = current > maxStreak ? current : maxStreak;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return maxStreak;
  }

  String _formatDate(DateTime d) => d.toIso8601String().split('T')[0];

  @override
  void dispose() {
    entryProvider.removeListener(_onEntriesChanged);
    super.dispose();
  }
}

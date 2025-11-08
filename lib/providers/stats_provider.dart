// class WorkEntry {
//   final int? id;
//   final String title;
//   final String description;
//   final int hours;
//   final int minutes;
//   final DateTime date;
//   final String? tag;

//   WorkEntry({
//     this.id,
//     required this.title,
//     this.description = '',
//     required this.hours,
//     required this.minutes,
//     required this.date,
//     this.tag,
//   });

//   // ... toMap(), fromMap(), copyWith(), formattedTime
// }
// lib/providers/stats_provider.dart
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/entry.dart';

class StatsProvider extends ChangeNotifier {
  List<WorkEntry> _allEntries = [];
  bool _isLoading = true;

  List<WorkEntry> get allEntries => _allEntries;
  bool get isLoading => _isLoading;

  int get totalEntries => _allEntries.length;
  int get totalHours => _allEntries.fold(0, (sum, e) => sum + e.hours);
  int get totalMinutes => _allEntries.fold(0, (sum, e) => sum + e.minutes);
  double get totalTimeInHours => totalHours + (totalMinutes / 60);

  int get todayMinutes {
    final today = DateTime.now();
    return _entriesOnDate(
      today,
    ).fold(0, (sum, e) => sum + e.hours * 60 + e.minutes);
  }

  int get thisWeekMinutes {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    return _entriesInRange(
      start,
      now,
    ).fold(0, (sum, e) => sum + e.hours * 60 + e.minutes);
  }

  int get currentStreak {
    if (_allEntries.isEmpty) return 0;
    final sortedDates = _getUniqueDatesDescending();
    int streak = 0;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    for (final date in sortedDates) {
      final normalized = DateTime(date.year, date.month, date.day);
      final expected = today.subtract(Duration(days: streak));
      if (normalized == expected) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int get longestStreak {
    if (_allEntries.isEmpty) return 0;
    final dates = _getUniqueDatesAscending();
    if (dates.length <= 1) return dates.length;

    int maxStreak = 1;
    int current = 1;
    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        current++;
        maxStreak = current > maxStreak ? current : maxStreak;
      } else {
        current = 1;
      }
    }
    return maxStreak;
  }

  String? get mostUsedTag {
    final map = <String, int>{};
    for (final e in _allEntries) {
      if (e.tag != null) map[e.tag!] = (map[e.tag!] ?? 0) + 1;
    }
    if (map.isEmpty) return null;
    return map.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      final entries = await DatabaseHelper.instance.getAllEntries();
      _allEntries = entries;
    } catch (e) {
      debugPrint("Stats load error: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  // FIXED: Use 'end' instead of 'e'
  List<WorkEntry> _entriesInRange(DateTime start, DateTime end) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(
      end.year,
      end.month,
      end.day,
    ).add(const Duration(days: 1));
    return _allEntries
        .where((entry) => entry.date.isAfter(s) && entry.date.isBefore(e))
        .toList();
  }

  List<WorkEntry> _entriesOnDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return _allEntries
        .where((e) => DateTime(e.date.year, e.date.month, e.date.day) == d)
        .toList();
  }

  List<DateTime> _getUniqueDatesAscending() {
    final set = <DateTime>{};
    for (final e in _allEntries) {
      set.add(DateTime(e.date.year, e.date.month, e.date.day));
    }
    final list = set.toList()..sort();
    return list;
  }

  List<DateTime> _getUniqueDatesDescending() {
    return _getUniqueDatesAscending().reversed.toList();
  }

  Map<String, int> get tagDistribution {
    final map = <String, int>{};
    for (final e in _allEntries) {
      final tag = e.tag ?? 'None';
      map[tag] = (map[tag] ?? 0) + 1;
    }
    return map;
  }

  List<Map<String, dynamic>> get weeklyData {
    final now = DateTime.now();
    final data = <Map<String, dynamic>>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final minutes = _entriesOnDate(
        date,
      ).fold(0, (sum, e) => sum + e.hours * 60 + e.minutes);
      data.add({'day': _dayAbbr(date.weekday), 'minutes': minutes});
    }
    return data;
  }

  List<WorkEntry> entriesInRange(DateTime start, DateTime end) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(
      end.year,
      end.month,
      end.day,
    ).add(const Duration(days: 1));

    return _allEntries.where((entry) {
      final entryDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      return entryDate.isAfter(s) && entryDate.isBefore(e);
    }).toList();
  }

  // ADD THESE TO StatsProvider
  // List<WorkEntry> entriesOnDate(DateTime date) {
  //   final d = DateTime(date.year, date.month, date.day);
  //   return _allEntries
  //       .where((e) => DateTime(e.date.year, e.date.month, e.date.day) == d)
  //       .toList();
  // }
  List<WorkEntry> entriesOnDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return _allEntries
        .where((e) => DateTime(e.date.year, e.date.month, e.date.day) == d)
        .toList();
  }

  // String? mostUsedTagIn(List<WorkEntry> entries) {
  //   final map = <String, int>{};
  //   for (final e in entries) {
  //     if (e.tag != null) map[e.tag!] = (map[e.tag!] ?? 0) + 1;
  //   }
  //   if (map.isEmpty) return null;
  //   return map.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  // }
  String? mostUsedTagIn(List<WorkEntry> entries) {
    final map = <String, int>{};
    for (final e in entries)
      if (e.tag != null) map[e.tag!] = (map[e.tag!] ?? 0) + 1;
    return map.isEmpty
        ? null
        : map.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // Map<String, int> tagDistributionIn(List<WorkEntry> entries) {
  //   final map = <String, int>{};
  //   for (final e in entries) {
  //     final tag = e.tag ?? 'None';
  //     map[tag] = (map[tag] ?? 0) + 1;
  //   }
  //   return map;
  // }
  Map<String, int> tagDistributionIn(List<WorkEntry> entries) {
    final map = <String, int>{};
    for (final e in entries) {
      final tag = e.tag ?? 'None';
      map[tag] = (map[tag] ?? 0) + 1;
    }
    return map;
  }

  // THIS MONTH ← MISSING BEFORE!
  int get thisMonthMinutes {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return _entriesInRange(
      start,
      now,
    ).fold(0, (sum, e) => sum + e.hours * 60 + e.minutes);
  }

  String _dayAbbr(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  // added lately
}

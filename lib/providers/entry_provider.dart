import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/entry.dart';

class EntryProvider with ChangeNotifier {
  List<WorkEntry> _entries = [];
  List<WorkEntry> get entries => List.unmodifiable(_entries);

  Future<void> loadEntries() async {
    _entries = await DatabaseHelper.instance.getAllEntries();
    notifyListeners();
  }

  Future<void> addEntry(WorkEntry entry) async {
    await DatabaseHelper.instance.insertEntry(entry);
    await loadEntries();
  }

  List<WorkEntry> getEntriesForDate(DateTime date) {
    final dateStr = _formatDate(date);
    return _entries.where((e) => _formatDate(e.date) == dateStr).toList();
  }

  int totalMinutesForDate(DateTime date) {
    return getEntriesForDate(date).fold(0, (sum, e) => sum + e.totalMinutes);
  }

  int totalMinutesForMonth(int year, int month) {
    return _entries
        .where((e) => e.date.year == year && e.date.month == month)
        .fold(0, (sum, e) => sum + e.totalMinutes);
  }

  Map<String, int> getTitleMinutesForMonth(int year, int month) {
    final Map<String, int> result = {};
    for (final entry in _entries) {
      if (entry.date.year == year && entry.date.month == month) {
        result.update(
          entry.title,
          (v) => v + entry.totalMinutes,
          ifAbsent: () => entry.totalMinutes,
        );
      }
    }
    return result;
  }

  String _formatDate(DateTime d) => d.toIso8601String().split('T')[0];
}

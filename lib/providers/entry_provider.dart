import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/entry.dart';

class EntryProvider extends ChangeNotifier {
  List<WorkEntry> _entries = [];

  List<WorkEntry> get entries => _entries;

  Future<void> loadEntries() async {
    final dbEntries = await DatabaseHelper.instance.getAllEntries();
    _entries = dbEntries;
    notifyListeners();
  }

  List<WorkEntry> getEntriesForDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return _entries.where((e) {
      final eDate = DateTime(e.date.year, e.date.month, e.date.day);
      return eDate == normalized;
    }).toList();
  }

  // Optional: Get entries by tag
  List<WorkEntry> getEntriesByTag(String tag) {
    return _entries.where((e) => e.tag == tag).toList();
  }

  // Optional: Get total time today
  int getTodayTotalMinutes() {
    final today = DateTime.now();
    final todayEntries = getEntriesForDate(today);
    return todayEntries.fold(0, (sum, e) => sum + e.hours * 60 + e.minutes);
  }

  // Optional: Add entry (if you want direct control)
  Future<void> addEntry(WorkEntry entry) async {
    await DatabaseHelper.instance.insertEntry(entry);
    await loadEntries();
  }

  // Optional: Update entry
  Future<void> updateEntry(WorkEntry entry) async {
    await DatabaseHelper.instance.updateEntry(entry);
    await loadEntries();
  }

  // Optional: Delete entry
  Future<void> deleteEntry(int id) async {
    await DatabaseHelper.instance.deleteEntry(id);
    await loadEntries();
  }
}

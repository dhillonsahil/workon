import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/work_title.dart';

class TitleProvider with ChangeNotifier {
  List<WorkTitle> _titles = [];
  List<WorkTitle> get titles => List.unmodifiable(_titles);

  Future<void> loadTitles() async {
    _titles = await DatabaseHelper.instance.getAllWorkTitles();
    notifyListeners();
  }

  Future<void> addTitle(WorkTitle title) async {
    await DatabaseHelper.instance.insertWorkTitle(title);
    await loadTitles();
  }

  Future<void> deleteTitle(int id) async {
    await DatabaseHelper.instance.deleteWorkTitle(id);
    await loadTitles();
  }

  WorkTitle? getTitleByName(String name) {
    try {
      return _titles.firstWhere((t) => t.name == name);
    } catch (_) {
      return null;
    }
  }
}

import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/work_title.dart';

class TitleProvider extends ChangeNotifier {
  List<WorkTitle> _titles = [];
  Set<String> _tags = {};

  List<WorkTitle> get titles => _titles;
  Set<String> get tags => _tags;

  Future<void> loadTitles() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('work_titles');
    _titles = maps.map((m) => WorkTitle.fromMap(m)).toList();

    final tagMaps = await db.query('tags');
    _tags = tagMaps.map((m) => m['name'] as String).toSet();

    notifyListeners();
  }

  Future<void> updateTag(String oldTag, String newTag) async {
    final db = await DatabaseHelper.instance.database;

    // Update in entries
    await db.rawUpdate('UPDATE entries SET tag = ? WHERE tag = ?', [
      newTag,
      oldTag,
    ]);

    // Update in titles
    await db.rawUpdate('UPDATE work_titles SET tag = ? WHERE tag = ?', [
      newTag,
      oldTag,
    ]);

    // Update in-memory tags
    if (_tags.remove(oldTag)) {
      _tags.add(newTag);
    }

    // Update titles in memory
    _titles = _titles.map((t) {
      if (t.tag == oldTag) return t.copyWith(tag: newTag);
      return t;
    }).toList();

    notifyListeners();
  }

  void addTitle(WorkTitle title) async {
    final db = await DatabaseHelper.instance.database;
    final id = await db.insert('work_titles', title.toMap());
    _titles.add(title.copyWith(id: id));
    notifyListeners();
  }

  void updateTitle(WorkTitle title) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'work_titles',
      title.toMap(),
      where: 'id = ?',
      whereArgs: [title.id],
    );
    final i = _titles.indexWhere((t) => t.id == title.id);
    if (i != -1) _titles[i] = title;
    notifyListeners();
  }

  void deleteTitle(WorkTitle title) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('work_titles', where: 'id = ?', whereArgs: [title.id]);
    _titles.removeWhere((t) => t.id == title.id);
    notifyListeners();
  }

  void addTag(String tag) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('tags', {'name': tag});
    _tags.add(tag);
    notifyListeners();
  }

  void removeTag(String tag) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('tags', where: 'name = ?', whereArgs: [tag]);
    _tags.remove(tag);
    notifyListeners();
  }

  WorkTitle? getTitleByName(String name) {
    try {
      return _titles.firstWhere((t) => t.name == name);
    } catch (_) {
      return null;
    }
  }
}

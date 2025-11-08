import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/entry.dart';
import '../models/work_title.dart';
import '../models/tag.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'workon.db');
    _database = await openDatabase(path, version: 1, onCreate: _createTables);
    return _database!;
  }

  Future<void> _createTables(Database db, int version) async {
    // Entries table
    await db.execute('''
      CREATE TABLE entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        hours INTEGER NOT NULL,
        minutes INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    // Work titles table
    await db.execute('''
      CREATE TABLE work_titles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        tag TEXT
      )
    ''');

    // Tags table (optional, for future use)
    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        color TEXT DEFAULT 'indigo'
      )
    ''');
  }

  // === ENTRY CRUD ===
  Future<int> insertEntry(WorkEntry entry) async {
    final db = await database;
    return await db.insert('entries', entry.toMap());
  }

  Future<List<WorkEntry>> getAllEntries() async {
    final db = await database;
    final maps = await db.query('entries', orderBy: 'date DESC');
    return maps.map((m) => WorkEntry.fromMap(m)).toList();
  }

  Future<List<WorkEntry>> getEntriesByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final maps = await db.query(
      'entries',
      where: 'date = ?',
      whereArgs: [dateStr],
      orderBy: 'id DESC',
    );
    return maps.map((m) => WorkEntry.fromMap(m)).toList();
  }

  // === WORK TITLE CRUD ===
  Future<int> insertWorkTitle(WorkTitle title) async {
    final db = await database;
    return await db.insert('work_titles', title.toMap());
  }

  Future<List<WorkTitle>> getAllWorkTitles() async {
    final db = await database;
    final maps = await db.query('work_titles');
    return maps.map((m) => WorkTitle.fromMap(m)).toList();
  }

  Future<int> deleteWorkTitle(int id) async {
    final db = await database;
    return await db.delete('work_titles', where: 'id = ?', whereArgs: [id]);
  }

  // === TAG CRUD ===
  Future<int> insertTag(Tag tag) async {
    final db = await database;
    return await db.insert('tags', tag.toMap());
  }

  Future<List<Tag>> getAllTags() async {
    final db = await database;
    final maps = await db.query('tags');
    return maps.map((m) => Tag.fromMap(m)).toList();
  }

  Future<int> deleteTag(int id) async {
    final db = await database;
    return await db.delete('tags', where: 'id = ?', whereArgs: [id]);
  }

  // === UTILITY ===
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('entries');
    await db.delete('work_titles');
    await db.delete('tags');
  }
}

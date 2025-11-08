import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workon/models/entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('workon.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2, // BUMP TO 2
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        hours INTEGER NOT NULL,
        minutes INTEGER NOT NULL,
        date INTEGER NOT NULL,
        tag TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE work_titles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        tag TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');
  }

  // MIGRATION: Add 'tag' column to existing tables
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE entries ADD COLUMN tag TEXT');
      await db.execute('ALTER TABLE work_titles ADD COLUMN tag TEXT');
    }
  }

  // === ENTRIES ===
  Future<int> insertEntry(WorkEntry entry) async {
    final db = await database;
    return await db.insert('entries', entry.toMap());
  }

  Future<int> updateEntry(WorkEntry entry) async {
    final db = await database;
    return await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<WorkEntry>> getAllEntries() async {
    final db = await database;
    final maps = await db.query('entries', orderBy: 'date DESC');
    return maps.map((m) => WorkEntry.fromMap(m)).toList();
  }

  // === TITLES ===
  Future<int> insertTitle(Map<String, dynamic> title) async {
    final db = await database;
    return await db.insert('work_titles', title);
  }

  Future<int> updateTitle(Map<String, dynamic> title) async {
    final db = await database;
    return await db.update(
      'work_titles',
      title,
      where: 'id = ?',
      whereArgs: [title['id']],
    );
  }

  Future<int> deleteTitle(int id) async {
    final db = await database;
    return await db.delete('work_titles', where: 'id = ?', whereArgs: [id]);
  }

  // === TAGS ===
  Future<int> insertTag(String tag) async {
    final db = await database;
    return await db.insert('tags', {'name': tag});
  }

  Future<int> deleteTag(String tag) async {
    final db = await database;
    return await db.delete('tags', where: 'name = ?', whereArgs: [tag]);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

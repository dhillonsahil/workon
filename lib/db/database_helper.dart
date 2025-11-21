// // lib/db/database_helper.dart
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import '../models/entry.dart';
// import '../models/todo.dart'; // ← NEW IMPORT

// class DatabaseHelper {
//   static final DatabaseHelper instance = DatabaseHelper._init();
//   static Database? _database;

//   DatabaseHelper._init();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('workon.db');
//     return _database!;
//   }

//   Future<Database> _initDB(String fileName) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, fileName);

//     return await openDatabase(
//       path,
//       version: 3, // ← Now version 3 with Todos
//       onCreate: _createDB,
//     );
//   }

//   Future _createDB(Database db, int version) async {
//     // Existing tables
//     await db.execute('''
//       CREATE TABLE entries (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         title TEXT NOT NULL,
//         description TEXT,
//         hours INTEGER NOT NULL,
//         minutes INTEGER NOT NULL,
//         date INTEGER NOT NULL,
//         tag TEXT
//       )
//     ''');

//     await db.execute('''
//       CREATE TABLE work_titles (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT NOT NULL,
//         tag TEXT
//       )
//     ''');

//     await db.execute('''
//       CREATE TABLE tags (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT NOT NULL UNIQUE
//       )
//     ''');

//     // NEW: Todos table
//     await db.execute('''
//       CREATE TABLE todos (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         title TEXT NOT NULL,
//         description TEXT,
//         tag TEXT,
//         priority TEXT NOT NULL,
//         dueDate INTEGER NOT NULL,
//         isCompleted INTEGER NOT NULL DEFAULT 0,
//         timeTakenMinutes INTEGER,
//         createdAt INTEGER NOT NULL
//       )
//     ''');
//   }

//   // === ENTRIES (unchanged) ===
//   Future<int> insertEntry(WorkEntry entry) async {
//     final db = await database;
//     return await db.insert('entries', entry.toMap());
//   }

//   Future<int> updateEntry(WorkEntry entry) async {
//     final db = await database;
//     return await db.update(
//       'entries',
//       entry.toMap(),
//       where: 'id = ?',
//       whereArgs: [entry.id],
//     );
//   }

//   Future<int> deleteEntry(int id) async {
//     final db = await database;
//     return await db.delete('entries', where: 'id = ?', whereArgs: [id]);
//   }

//   Future<List<WorkEntry>> getAllEntries() async {
//     final db = await database;
//     final maps = await db.query('entries', orderBy: 'date DESC');
//     return maps.map((m) => WorkEntry.fromMap(m)).toList();
//   }

//   // === TODOS (NEW) ===
//   Future<int> insertTodo(Todo todo) async {
//     final db = await database;
//     return await db.insert('todos', todo.toMap());
//   }

//   Future<int> updateTodo(Todo todo) async {
//     final db = await database;
//     return await db.update(
//       'todos',
//       todo.toMap(),
//       where: 'id = ?',
//       whereArgs: [todo.id],
//     );
//   }

//   Future<int> deleteTodo(int id) async {
//     final db = await database;
//     return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
//   }

//   Future<List<Todo>> getAllTodos() async {
//     final db = await database;
//     final maps = await db.query(
//       'todos',
//       orderBy: 'dueDate ASC, createdAt DESC',
//     );
//     return maps.map((m) => Todo.fromMap(m)).toList();
//   }

//   Future<List<Todo>> getTodosForDate(DateTime date) async {
//     final db = await database;
//     final start = DateTime(date.year, date.month, date.day);
//     final end = start.add(const Duration(days: 1));
//     final maps = await db.rawQuery(
//       '''
//       SELECT * FROM todos
//       WHERE dueDate >= ? AND dueDate < ?
//       ORDER BY dueDate ASC
//     ''',
//       [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
//     );
//     return maps.map((m) => Todo.fromMap(m)).toList();
//   }

//   // Optional: Get overdue + today todos
//   Future<List<Todo>> getOverdueAndTodayTodos() async {
//     final db = await database;
//     final now = DateTime.now();
//     final todayEnd = DateTime(now.year, now.month, now.day + 1);
//     final maps = await db.rawQuery(
//       '''
//       SELECT * FROM todos
//       WHERE dueDate < ? AND isCompleted = 0
//       ORDER BY dueDate ASC
//     ''',
//       [todayEnd.millisecondsSinceEpoch],
//     );
//     return maps.map((m) => Todo.fromMap(m)).toList();
//   }

//   // === TITLES & TAGS (unchanged) ===
//   Future<int> insertTitle(Map<String, dynamic> title) async {
//     final db = await database;
//     return await db.insert('work_titles', title);
//   }

//   Future<int> updateTitle(Map<String, dynamic> title) async {
//     final db = await database;
//     return await db.update(
//       'work_titles',
//       title,
//       where: 'id = ?',
//       whereArgs: [title['id']],
//     );
//   }

//   Future<int> deleteTitle(int id) async {
//     final db = await database;
//     return await db.delete('work_titles', where: 'id = ?', whereArgs: [id]);
//   }

//   Future<int> insertTag(String tag) async {
//     final db = await database;
//     return await db.insert('tags', {'name': tag});
//   }

//   Future<int> deleteTag(String tag) async {
//     final db = await database;
//     return await db.delete('tags', where: 'name = ?', whereArgs: [tag]);
//   }

//   Future<void> close() async {
//     final db = await database;
//     await db.close();
//   }
// }
// lib/db/database_helper.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/entry.dart';
import '../models/todo.dart'; // ← NEW IMPORT

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
      version: 3, // ← Now version 3 with Todos
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Existing tables
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

    // NEW: Todos table
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        tag TEXT,
        priority TEXT NOT NULL,
        dueDate INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        timeTakenMinutes INTEGER,
        createdAt INTEGER NOT NULL
      )
    ''');
  }

  // === ENTRIES (unchanged) ===
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

  // === TODOS (NEW) ===
  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert('todos', todo.toMap());
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Todo>> getAllTodos() async {
    final db = await database;
    final maps = await db.query(
      'todos',
      orderBy: 'dueDate ASC, createdAt DESC',
    );
    return maps.map((m) => Todo.fromMap(m)).toList();
  }

  Future<List<Todo>> getTodosForDate(DateTime date) async {
    final db = await database;
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final maps = await db.rawQuery(
      '''
      SELECT * FROM todos 
      WHERE dueDate >= ? AND dueDate < ?
      ORDER BY dueDate ASC
    ''',
      [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
    return maps.map((m) => Todo.fromMap(m)).toList();
  }

  // Optional: Get overdue + today todos
  Future<List<Todo>> getOverdueAndTodayTodos() async {
    final db = await database;
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day + 1);
    final maps = await db.rawQuery(
      '''
      SELECT * FROM todos 
      WHERE dueDate < ? AND isCompleted = 0
      ORDER BY dueDate ASC
    ''',
      [todayEnd.millisecondsSinceEpoch],
    );
    return maps.map((m) => Todo.fromMap(m)).toList();
  }

  // === TITLES & TAGS (unchanged) ===
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
    await db.close();
  }
}

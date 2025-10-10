import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chetegram.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await _createTables(db);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      var tableInfo = await db.rawQuery('PRAGMA table_info(tasks)');
      List<String> columnNames = tableInfo.map((row) => row['name'] as String).toList();
      
      if (!columnNames.contains('readingStage')) {
        await db.execute("ALTER TABLE tasks ADD COLUMN readingStage INTEGER DEFAULT 1");
      }
      if (!columnNames.contains('nextRevisionDate')) {
        await db.execute("ALTER TABLE tasks ADD COLUMN nextRevisionDate TEXT");
      }
      if (!columnNames.contains('status')) {
         await db.execute("ALTER TABLE tasks ADD COLUMN status TEXT DEFAULT 'pending'");
      }
    }
  }

  Future _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        topic TEXT NOT NULL,
        readingStage INTEGER NOT NULL DEFAULT 1,
        nextRevisionDate TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE flashcards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        topic TEXT NOT NULL,
        frontText TEXT NOT NULL,
        backText TEXT NOT NULL,
        colorHex TEXT NOT NULL
      )
    ''');
  }

  // --- Task Methods ---
  Future<int> insertTask(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('tasks', row);
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    Database db = await instance.database;
    return await db.query('tasks', orderBy: 'id DESC');
  }

  Future<int> updateTask(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update('tasks', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTask(int id) async {
    Database db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
  
  Future<List<Map<String, dynamic>>> getTodaysTasks() async {
    Database db = await instance.database;
    DateTime now = DateTime.now();
    String today = DateTime(now.year, now.month, now.day).toIso8601String();
    
    return await db.query(
      'tasks',
      where: "nextRevisionDate <= ? AND status = 'pending'",
      whereArgs: [today],
      orderBy: 'nextRevisionDate ASC',
    );
  }
  
  // --- Analytics Methods ---
  Future<int> getTasksCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM tasks');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getTasksByStage(int stage) async {
    final db = await instance.database;
    return await db.query('tasks', where: 'readingStage = ?', whereArgs: [stage]);
  }

  Future<List<Map<String, dynamic>>> getCompletedTasks() async {
    final db = await instance.database;
    return await db.query('tasks', where: 'status = ?', whereArgs: ['completed']);
  }

  // --- Flashcard Methods ---
  Future<int> insertFlashcard(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('flashcards', row);
  }

  Future<List<Map<String, dynamic>>> getAllFlashcards() async {
    Database db = await instance.database;
    return await db.query('flashcards', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getFilteredFlashcards({String? subject}) async {
    final db = await instance.database;
    if (subject == null || subject == 'All') {
      return getAllFlashcards();
    }
    return await db.query('flashcards', where: 'subject = ?', whereArgs: [subject]);
  }

  Future<List<String>> getUniqueSubjects() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query('flashcards', distinct: true, columns: ['subject']);
    return result.map((map) => map['subject'] as String).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

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

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // --- Tasks Table ---
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        topic TEXT NOT NULL,
        revision TEXT NOT NULL,
        nextRevisionDate TEXT NOT NULL,
        isDone INTEGER NOT NULL
      )
    ''');

    // --- NEW: Flashcards Table ---
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

  // --- NEW: Flashcard Methods ---
  Future<int> insertFlashcard(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('flashcards', row);
  }

  Future<List<Map<String, dynamic>>> getAllFlashcards() async {
    Database db = await instance.database;
    return await db.query('flashcards', orderBy: 'id DESC');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

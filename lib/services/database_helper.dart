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

    // वर्जन 1 से 2 कर दिया गया है और onUpgrade जोड़ा गया है
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  // यह फंक्शन सिर्फ तब चलेगा जब ऐप पहली बार इंस्टॉल होगा
  Future _createDB(Database db, int version) async {
    await _createTables(db);
  }

  // यह फंक्शन तब चलेगा जब हम DB का वर्जन बढ़ाएंगे
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // वर्जन 2 के बदलाव: tasks टेबल में नए कॉलम जोड़ना
      await db.execute("ALTER TABLE tasks ADD COLUMN readingStage INTEGER DEFAULT 1");
      await db.execute("ALTER TABLE tasks ADD COLUMN lastReadDate TEXT");
      // पुराने 'nextRevisionDate' कॉलम का नाम बदलें और नया बनाएं
      await db.execute("ALTER TABLE tasks RENAME COLUMN nextRevisionDate TO old_nextRevisionDate");
      await db.execute("ALTER TABLE tasks ADD COLUMN nextRevisionDate TEXT");
      await db.execute("ALTER TABLE tasks ADD COLUMN status TEXT DEFAULT 'pending'");
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

  // नया मेथड: किसी टास्क को अपडेट करने के लिए
  Future<int> updateTask(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update('tasks', row, where: 'id = ?', whereArgs: [id]);
  }
  
  // नया मेथड: सिर्फ आज के रिविजन वाले टास्क लाने के लिए
  Future<List<Map<String, dynamic>>> getTodaysTasks() async {
    Database db = await instance.database;
    // आज की तारीख (बिना टाइम के)
    DateTime now = DateTime.now();
    String today = DateTime(now.year, now.month, now.day).toIso8601String();
    
    // सिर्फ वो टास्क लाओ जिनकी रिविजन डेट आज या उससे पहले की है और स्टेटस pending है
    return await db.query(
      'tasks',
      where: "nextRevisionDate <= ? AND status = 'pending'",
      whereArgs: [today],
      orderBy: 'nextRevisionDate ASC',
    );
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

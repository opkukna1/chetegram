import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart'; // गलत इम्पोर्ट को ठीक कर दिया गया है

// नए मॉडल इम्पोर्ट किए गए हैं
import 'package:chetegram/models/timetable_model.dart';
import 'package:chetegram/models/time_slot_model.dart';

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

    return await openDatabase(path, version: 3, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE timetables (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL
      )
    ''');
      
    await db.execute('''
      CREATE TABLE time_slots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timetableId INTEGER NOT NULL,
        subject TEXT NOT NULL,
        startTimeMinutes INTEGER NOT NULL,
        endTimeMinutes INTEGER NOT NULL,
        frequency TEXT NOT NULL,
        FOREIGN KEY (timetableId) REFERENCES timetables (id) ON DELETE CASCADE
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE tasks ADD COLUMN readingStage INTEGER DEFAULT 1");
      await db.execute("ALTER TABLE tasks ADD COLUMN nextRevisionDate TEXT");
      await db.execute("ALTER TABLE tasks ADD COLUMN status TEXT DEFAULT 'pending'");
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE timetables (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE time_slots (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timetableId INTEGER NOT NULL,
          subject TEXT NOT NULL,
          startTimeMinutes INTEGER NOT NULL,
          endTimeMinutes INTEGER NOT NULL,
          frequency TEXT NOT NULL,
          FOREIGN KEY (timetableId) REFERENCES timetables (id) ON DELETE CASCADE
        )
      ''');
    }
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

  // --- TimeTable Methods ---
  Future<void> insertTimeTableWithSlots(TimeTableModel timetable, List<Map<String, dynamic>> slots) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      int timetableId = await txn.insert('timetables', timetable.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      for (var slot in slots) {
        slot['timetableId'] = timetableId;
        await txn.insert('time_slots', slot);
      }
    });
  }

  Future<List<TimeTableModel>> getAllTimeTablesWithSlots() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> timetableMaps = await db.query('timetables', orderBy: 'id DESC');
    
    List<TimeTableModel> timetables = [];
    for (var timetableMap in timetableMaps) {
      final List<Map<String, dynamic>> slotMaps = await db.query('time_slots', where: 'timetableId = ?', whereArgs: [timetableMap['id']]);
      List<TimeSlotModel> slots = slotMaps.map((slotMap) => TimeSlotModel.fromMap(slotMap)).toList();
      timetables.add(TimeTableModel(
        id: timetableMap['id'],
        title: timetableMap['title'],
        slots: slots
      ));
    }
    return timetables;
  }

  Future<int> deleteTimeTable(int id) async {
    final db = await instance.database;
    return await db.delete('timetables', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

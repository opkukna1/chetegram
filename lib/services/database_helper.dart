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

    // हम भविष्य में किसी भी नए लोकल टेबल के लिए वर्जन बढ़ा सकते हैं
    return await openDatabase(path, version: 3, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    // यहाँ अब कोई टेबल नहीं बनाई जाएगी क्योंकि सब कुछ Firestore पर है
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // अपग्रेड लॉजिक की भी अब ज़रूरत नहीं है
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

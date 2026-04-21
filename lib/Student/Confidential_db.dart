import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ConfidentialDB {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), "confidential.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {

        await db.execute('''
        CREATE TABLE evaluations(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          session TEXT,
          courseCode TEXT,
          courseName TEXT,
          teacherName TEXT,
          question TEXT,
          answer TEXT
        )
        ''');

      },
    );
  }

  static Future<void> insertEvaluation({
    required String session,
    required String courseCode,
    required String courseName,
    required String teacherName,
    required String question,
    required String answer,
  }) async {

    final db = await database;

    await db.insert(
      "evaluations",
      {
        "session": session,
        "courseCode": courseCode,
        "courseName": courseName,
        "teacherName": teacherName,
        "question": question,
        "answer": answer,
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getEvaluations() async {
    final db = await database;
    return await db.query("evaluations");
  }
}
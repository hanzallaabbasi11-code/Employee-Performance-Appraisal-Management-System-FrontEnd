// ignore_for_file: file_names

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
      version: 3,

      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE evaluations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER,
        session TEXT,
        courseCode TEXT,
        courseName TEXT,
        teacherName TEXT,
        question TEXT,
        answer TEXT
      )
      ''');

        await db.execute('''
      CREATE TABLE submitted_evaluations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId TEXT,
        enrollmentId INTEGER
      )
      ''');

        print("✅ TABLE CREATED");
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('''
          CREATE TABLE IF NOT EXISTS submitted_evaluations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            studentId TEXT,
            enrollmentId INTEGER
          )
          ''');

          print("✅ DATABASE UPDATED");
        }
      },
    );
  }

  static Future<void> insertEvaluation({
    required int sessionId,
    required String session,
    required String courseCode,
    required String courseName,
    required String teacherName,
    required String question,
    required String answer,
  }) async {
    final db = await database;

    final data = {
      "sessionId": sessionId,
      "session": session,
      "courseCode": courseCode,
      "courseName": courseName,
      "teacherName": teacherName,
      "question": question,
      "answer": answer,
    };

    print("🗄️ SQLITE INSERT => $data");

    await db.insert("evaluations", data);
  }

  // ================= MARK AS SUBMITTED =================

  static Future<void> markAsSubmitted({
    required String studentId,
    required int enrollmentId,
  }) async {
    final db = await database;

    await db.insert(
      "submitted_evaluations",
      {
        "studentId": studentId,
        "enrollmentId": enrollmentId,
      },
    );
  }

  // ================= CHECK SUBMITTED =================

  static Future<bool> isAlreadySubmitted({
    required String studentId,
    required int enrollmentId,
  }) async {
    final db = await database;

    final data = await db.query(
      "submitted_evaluations",
      where: "studentId = ? AND enrollmentId = ?",
      whereArgs: [studentId, enrollmentId],
    );

    return data.isNotEmpty;
  }

  static int getScore(String value) {
    switch (value) {
      case "Excellent":
        return 4;
      case "Good":
        return 3;
      case "Average":
        return 2;
      case "Poor":
        return 1;
      default:
        return 0;
    }
  }

  static Future<double> getAverageScore({
    required String teacherName,
    required String session,
  }) async {
    final db = await database;

    String extractedYear = session.replaceAll(RegExp(r'[^0-9]'), '');

    List<Map<String, dynamic>> data = [];

    data = await db.query(
      "evaluations",
      where: "teacherName = ? AND session = ?",
      whereArgs: [teacherName, session],
    );

    if (data.isEmpty && extractedYear.isNotEmpty) {
      data = await db.query(
        "evaluations",
        where: "teacherName = ? AND session = ?",
        whereArgs: [teacherName, extractedYear],
      );
    }

    if (data.isEmpty) {
      data = await db.query(
        "evaluations",
        where: "teacherName = ?",
        whereArgs: [teacherName],
      );
    }

    if (data.isEmpty) return 0;

    double total = 0;

    for (var row in data) {
      total += getScore(row['answer'].toString());
    }

    return total / data.length;
  }

  static Future<double> getAverageScoreBySessionId({
    required String teacherName,
    required int sessionId,
  }) async {
    final db = await database;

    print(
      "🔍 Searching SQLITE => Teacher: $teacherName | SessionId: $sessionId",
    );

    final data = await db.rawQuery(
      '''
    SELECT * FROM evaluations
    WHERE teacherName LIKE ?
    AND sessionId = ?
    ''',
      ['%$teacherName%', sessionId],
    );

    print("📊 FILTERED SQLITE DATA => $data");

    if (data.isEmpty) return 0;

    double total = 0;

    for (var row in data) {
      total += getScore(row['answer'].toString());
    }

    return total / data.length;
  }

  static Future<void> clearEvaluations() async {
    final db = await database;
    await db.delete("evaluations");
  }

  static Future<void> printAllEvaluations() async {
    final db = await database;
    final data = await db.query("evaluations");

    print("📊 ALL SQLITE DATA:");
    for (var row in data) {
      print(row);
    }
  }
}
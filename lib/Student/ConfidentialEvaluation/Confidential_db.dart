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
      version: 2,

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

        print("✅ TABLE CREATED");
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE evaluations ADD COLUMN sessionId INTEGER",
          );

          print("✅ TABLE UPDATED");
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

  /// 🔹 NEW: EXACT MATCH WITH REACT (AVG BASED)
  static Future<double> getAverageScore({
    required String teacherName,
    required String session,
  }) async {
    final db = await database;

    /// 🔥 Extract year from session name (Spring 2026 → 2026)
    String extractedYear = session.replaceAll(RegExp(r'[^0-9]'), '');

    List<Map<String, dynamic>> data = [];

    /// 🔥 Try exact match first
    data = await db.query(
      "evaluations",
      where: "teacherName = ? AND session = ?",
      whereArgs: [teacherName, session],
    );

    /// 🔥 If no data → fallback to year match
    if (data.isEmpty && extractedYear.isNotEmpty) {
      data = await db.query(
        "evaluations",
        where: "teacherName = ? AND session = ?",
        whereArgs: [teacherName, extractedYear],
      );
    }

    /// 🔥 LAST fallback → only teacher match
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

  //to delete
  static Future<void> clearEvaluations() async {
    final db = await database;
    await db.delete("evaluations");
  }

  //to print
  static Future<void> printAllEvaluations() async {
    final db = await database;
    final data = await db.query("evaluations");

    print("📊 ALL SQLITE DATA:");
    for (var row in data) {
      print(row);
    }
  }
}

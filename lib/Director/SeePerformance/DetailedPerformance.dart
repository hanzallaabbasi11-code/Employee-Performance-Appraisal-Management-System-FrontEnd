// ignore_for_file: file_names, strict_top_level_inference

import 'dart:convert';
import 'package:epams/Student/ConfidentialEvaluation/Confidential_db.dart';
//import 'package:epams/Student/Confidential_db.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Detailedperformance extends StatefulWidget {
  final String teacherId;
  final int sessionId;
  final String courseCode;

  const Detailedperformance({
    super.key,
    required this.teacherId,
    required this.sessionId,
    required this.courseCode,
  });

  @override
  State<Detailedperformance> createState() => _DetailedperformanceState();
}

class _DetailedperformanceState extends State<Detailedperformance> {
  List sessions = [];
  List questions = [];

  int? selectedSession;

  String selectedType = "Teacher Evaluation";

  final List<String> evaluationTypes = [
    'Teacher Evaluation',
    'Peer Evaluation',
    'Confidential Evaluation',
  ];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    getSessions();
  }

  // ================= SESSIONS =================

  Future getSessions() async {
    var res = await http.get(
      Uri.parse("$Url/Performance/GetSessions"),
    );

    var data = jsonDecode(res.body);

    setState(() {
      sessions = data;
      selectedSession = widget.sessionId;
    });

    getQuestionStats();
  }

  // ================= CONFIDENTIAL LOCAL DB =================

  Future getConfidentialData() async {
    setState(() {
      loading = true;
    });

    final db = await ConfidentialDB.database;

    // GET SESSION NAME
    String sessionName = "";

    try {
      var sessionObj = sessions.firstWhere(
        (s) => s['id'] == selectedSession,
      );

      sessionName = sessionObj['name'].toString();
    } catch (e) {
      sessionName = selectedSession.toString();
    }

    // GET ALL RECORDS
    List<Map<String, dynamic>> data = await db.query(
      "evaluations",
      where: "courseCode = ?",
      whereArgs: [widget.courseCode],
    );

    // FILTER SESSION
    data = data.where((e) {
      String dbSession = e['session'].toString();

      return dbSession == sessionName ||
          dbSession == selectedSession.toString() ||
          dbSession.contains(
            RegExp(r'\d{4}').stringMatch(sessionName) ?? '',
          );
    }).toList();

    // GROUP QUESTIONS
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var item in data) {
      String question = item['question'].toString();

      if (!grouped.containsKey(question)) {
        grouped[question] = [];
      }

      grouped[question]!.add(item);
    }

    List<Map<String, dynamic>> result = [];

    grouped.forEach((question, values) {
      int score1 = 0;
      int score2 = 0;
      int score3 = 0;
      int score4 = 0;

      double total = 0;

      for (var row in values) {
        String answer = row['answer'].toString();

        int score = ConfidentialDB.getScore(answer);

        total += score;

        if (score == 1) score1++;
        if (score == 2) score2++;
        if (score == 3) score3++;
        if (score == 4) score4++;
      }

      double avg = values.isNotEmpty ? total / values.length : 0;

      result.add({
        "QuestionText": question,
        "AverageScore": avg.toStringAsFixed(2),
        "Score1": score1,
        "Score2": score2,
        "Score3": score3,
        "Score4": score4,
      });
    });

    setState(() {
      questions = result;
      loading = false;
    });
  }

  // ================= API =================

  Future getQuestionStats() async {
    // ================= LOCAL DB =================
    if (selectedType == "Confidential Evaluation") {
      await getConfidentialData();
      return;
    }

    setState(() {
      loading = true;
    });

    String type = "student";

    if (selectedType == "Peer Evaluation") type = "peer";
    if (selectedType == "Teacher Evaluation") type = "student";

    var res = await http.get(
      Uri.parse(
        "$Url/Performance/GetTeacherQuestionStatsFull?teacherId=${widget.teacherId}&sessionId=$selectedSession&evaluationType=$type&courseCode=${widget.courseCode}",
      ),
    );

    var data = jsonDecode(res.body);

    setState(() {
      questions = data;
      loading = false;
    });
  }

  // ================= SESSION DROPDOWN =================

  Widget sessionDropdown() {
    return DropdownButtonFormField(
      initialValue: selectedSession,
      decoration: InputDecoration(
        labelText: "Select Session",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: sessions.map<DropdownMenuItem>((s) {
        return DropdownMenuItem(
          value: s['id'],
          child: Text(s['name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedSession = value;
        });

        getQuestionStats();
      },
    );
  }

  // ================= EVALUATION TYPE =================

  Widget evaluationDropdown() {
    return DropdownButtonFormField(
      initialValue: selectedType,
      decoration: InputDecoration(
        labelText: "Full Evaluation Type",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: evaluationTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedType = value!;
        });

        getQuestionStats();
      },
    );
  }

  // ================= STAR ROW =================

  Widget starRow(String label, int count) {
    int stars = 0;

    if (label == "Poor") stars = 1;
    if (label == "Average") stars = 2;
    if (label == "Good") stars = 3;
    if (label == "Excellent") stars = 4;

    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label),
        ),
        Row(
          children: List.generate(
            stars,
            (index) => const Icon(
              Icons.star,
              color: Colors.orange,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(": $count"),
      ],
    );
  }

  // ================= QUESTION CARD =================

  Widget questionCard(q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q['QuestionText'] ?? "",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Average: ${q['AverageScore']} / 4",
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          starRow("Poor", q['Score1']),
          starRow("Average", q['Score2']),
          starRow("Good", q['Score3']),
          starRow("Excellent", q['Score4']),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),
      appBar: AppBar(
        title: const Text("Question Analysis"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "See Detailed Information Of Evaluations",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            sessionDropdown(),

            const SizedBox(height: 12),

            evaluationDropdown(),

            const SizedBox(height: 16),

            Text(
              selectedType,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        return questionCard(
                          questions[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
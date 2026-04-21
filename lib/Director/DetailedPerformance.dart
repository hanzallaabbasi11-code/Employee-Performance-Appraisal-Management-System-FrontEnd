import 'dart:convert';
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

  // ================= API =================

  Future getQuestionStats() async {

    setState(() {
      loading = true;
    });

    String type = "student";

    if (selectedType == "Peer Evaluation") type = "peer";
    if (selectedType == "Teacher Evaluation") type = "student";
    if (selectedType == "Confidential Evaluation") type = "both";

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
      value: selectedSession,
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
      value: selectedType,
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
          BoxShadow(color: Colors.black12, blurRadius: 6),
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            sessionDropdown(),

            const SizedBox(height: 12),

            evaluationDropdown(),

            const SizedBox(height: 16),

            const Text(
              "Student Evaluation",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        return questionCard(questions[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
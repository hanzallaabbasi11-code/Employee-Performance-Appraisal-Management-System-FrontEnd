import 'dart:convert';
import 'package:epams/Teacher/QuestionnaireModel.dart';
import 'package:epams/Teacher/TeacherModel.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Peerevaluationform extends StatefulWidget {
  final TeacherModel teacher;
  final QuestionnaireModel questionnaire;
  final int evaluatorID; // 👈 Fetched evaluator ID from backend

  const Peerevaluationform({
    super.key,
    required this.teacher,
    required this.questionnaire,
    required this.evaluatorID,
  });

  @override
  State<Peerevaluationform> createState() => _PeerevaluationformState();
}

class _PeerevaluationformState extends State<Peerevaluationform> {
  Map<int, String> answers = {};

  int getScore(String value) {
    switch (value) {
      case "Excellent":
        return 1;
      case "Good":
        return 2;
      case "Average":
        return 3;
      case "Poor":
        return 4;
      default:
        return 0;
    }
  }

  Future<void> submitEvaluation() async {
    if (answers.length != widget.questionnaire.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please answer all questions")),
      );
      return;
    }

    List<Map<String, dynamic>> payload = [];

    for (var q in widget.questionnaire.questions) {
      payload.add({
        "evaluatorID": widget.evaluatorID, // 👈 Pass fetched evaluator ID
        "evaluateeID": widget.teacher.teacherID,
        "questionID": q.questionID,
        "courseCode": widget.teacher.courses.isNotEmpty
            ? widget.teacher.courses.first
            : "",
        "score": getScore(answers[q.questionID]!),
      });
    }

    try {
      final response = await http.post(
        Uri.parse("$Url/TeacherDashboard/SubmitEvaluation"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      print("Status Code: ${response.statusCode}");
print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Evaluation Submitted Successfully")),
        );

        Navigator.pop(context, true); // 👈 return success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Submission Failed")),
        );
      }
    } catch (e) {
      print("Submit Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while submitting")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teacher Evaluation Form")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Teacher Info
          Card(
            color: Colors.green,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                widget.teacher.teacherName,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Questions
          ...widget.questionnaire.questions.map((q) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.questionText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: ["Excellent", "Good", "Average", "Poor"]
                          .map(
                            (option) => RadioListTile<String>(
                              title: Text(option),
                              value: option,
                              groupValue: answers[q.questionID],
                              onChanged: (value) {
                                setState(() {
                                  answers[q.questionID] = value!;
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: submitEvaluation,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("Submit Evaluation"),
          ),
        ],
      ),
    );
  }
}

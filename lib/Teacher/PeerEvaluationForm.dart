// ignore_for_file: file_names, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:epams/Teacher/QuestionnaireModel.dart';
import 'package:epams/Teacher/TeacherModel.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Peerevaluationform extends StatefulWidget {
  final TeacherModel teacher;
  final QuestionnaireModel questionnaire;
  final int evaluatorID;
  final String courseCode;

  const Peerevaluationform({
    super.key,
    required this.teacher,
    required this.questionnaire,
    required this.evaluatorID,
    required this.courseCode,
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
        "evaluatorID": widget.evaluatorID,
        "evaluateeID": widget.teacher.teacherID,
        "questionID": q.questionID,
        "courseCode": widget.courseCode,
        "score": getScore(answers[q.questionID] ?? ""),
      });
    }

    try {
      final response = await http.post(
        Uri.parse("$Url/TeacherDashboard/SubmitEvaluation"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Evaluation Submitted")),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
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
          Card(
            color: Colors.green,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                widget.teacher.teacherName,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 20),

          ...widget.questionnaire.questions.map((q) {
            return Card(
              child: Column(
                children: [
                  ListTile(title: Text(q.questionText)),
                  Column(
                    children: ["Excellent", "Good", "Average", "Poor"]
                        .map((option) {
                      return RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: answers[q.questionID],
                        onChanged: (value) {
                          setState(() {
                            answers[q.questionID] = value!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: submitEvaluation,
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
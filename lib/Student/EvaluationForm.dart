import 'dart:convert';
import 'package:epams/Teacher/QuestionnaireModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Url.dart';

class Evaluationform extends StatefulWidget {
  final String courseCode;
  final String courseName;
  final String teacherName;
  final QuestionnaireModel questionnaire;
  final String studentId;
  final int enrollmentID;

  const Evaluationform({
    super.key,
    required this.courseCode,
    required this.courseName,
    required this.teacherName,
    required this.questionnaire,
    required this.studentId,
    required this.enrollmentID,
  });

  @override
  State<Evaluationform> createState() => _EvaluationformState();
}

class _EvaluationformState extends State<Evaluationform> {
  Map<int, String> selectedAnswers = {};

  final Map<String, int> scoreMap = {
    "Excellent": 4,
    "Good": 3,
    "Average": 2,
    "Poor": 1,
  };

  final List<String> options = [
    "Excellent",
    "Good",
    "Average",
    "Poor",
  ];

  bool isSubmitting = false;

  /// ===========================================
  /// Submit Student Evaluation (Separated Method)
  /// ===========================================
  Future<bool> submitStudentEvaluation() async {
  final questions = widget.questionnaire.questions;

  if (selectedAnswers.length != questions.length) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please answer all questions")),
    );
    return false;
  }

  setState(() => isSubmitting = true);

  try {
    List<Map<String, dynamic>> evaluationList = [];

    for (int i = 0; i < questions.length; i++) {
      evaluationList.add({
        "enrollmentID": widget.enrollmentID,
        "questionID": questions[i].questionID,
        "score": scoreMap[selectedAnswers[i]],
        "StudentId": widget.studentId
      });
    }

    print("Submitting Data:");
    print(jsonEncode(evaluationList));

    final response = await http.post(
      Uri.parse("$Url/Student/SubmitStudentEvaluation"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(evaluationList),
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    setState(() => isSubmitting = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Evaluation Submitted Successfully")),
      );
      return true;
    } else {
      // 👇 Show actual backend message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error ${response.statusCode}: ${response.body}",
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return false;
    }
  } catch (e) {
    setState(() => isSubmitting = false);

    print("Exception: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Exception: $e"),
        duration: const Duration(seconds: 4),
      ),
    );

    return false;
  }
}


  @override
  Widget build(BuildContext context) {
    final questions = widget.questionnaire.questions;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Back Row
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Text(
                    "Back to Courses",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              /// Course Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.courseCode,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      widget.courseName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Instructor: ${widget.teacherName}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Evaluation Questions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              /// Questions List
              ListView.builder(
                itemCount: questions.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final question = questions[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          "${index + 1}. ${question.questionText}",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: options.map((option) {
                            bool isSelected = selectedAnswers[index] == option;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedAnswers[index] = option;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.green.shade50
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.green
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.green
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              /// Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          bool success = await submitStudentEvaluation();

                          if (success) {
                            Navigator.pop(context, true);
                          }
                        },
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Submit Evaluation",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "Your responses will remain confidential.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

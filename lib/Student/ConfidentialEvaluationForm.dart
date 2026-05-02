import 'dart:convert';
//import 'package:epams/Student/Confidential_db.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:epams/Teacher/QuestionnaireModel.dart';
//import 'confidential_db.dart';

class Confidentialevaluationform extends StatefulWidget {
  final String courseCode;
  final String courseName;
  final String teacherName;
  final QuestionnaireModel questionnaire;
  final String studentId;
  final int enrollmentId;

  const Confidentialevaluationform({
    super.key,
    required this.courseCode,
    required this.courseName,
    required this.teacherName,
    required this.questionnaire,
    required this.studentId,
    required this.enrollmentId,
  });

  @override
  State<Confidentialevaluationform> createState() =>
      _ConfidentialevaluationformState();
}

class _ConfidentialevaluationformState
    extends State<Confidentialevaluationform> {

  Map<int, String> selectedAnswers = {};

  final List<String> options = ["Excellent", "Good", "Average", "Poor"];

  bool isSubmitting = false;

  int getScore(String value) {
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

  /// 🔹 UPDATED FUNCTION
  Future<void> submitEvaluation() async {

    final questions = widget.questionnaire.questions;

    List<Map<String, dynamic>> answers = [];

    for (var question in questions) {
      answers.add({
        "questionId": question.questionID,
        "score": getScore(selectedAnswers[question.questionID]!)
      });
    }

    final body = {
      "EnrollmentId": widget.enrollmentId,
      "StudentId": widget.studentId,
      "Answers": answers
    };

    setState(() => isSubmitting = true);

    try {

      /// 🔹 Save answers in SQLite
      // for (var question in questions) {

      //   await ConfidentialDB.insertEvaluation(
      //     session: DateTime.now().year.toString(),
      //     courseCode: widget.courseCode,
      //     courseName: widget.courseName,
      //     teacherName: widget.teacherName,
      //     question: question.questionText,
      //     answer: selectedAnswers[question.questionID]!,
      //   );

      // }

      /// 🔹 Existing Backend API (Email)
      final response = await http.post(
        Uri.parse("$Url/Student/SubmitConfidentialEvaluation"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Evaluation Submitted Successfully"),
          ),
        );

        Navigator.pop(context);

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${response.body}"),
          ),
        );

      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Exception: $e"),
        ),
      );

    }

    setState(() => isSubmitting = false);
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

              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Text(
                    "Back to Courses",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 15),

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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4),
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
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Evaluation Questions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

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
                      border: Border.all(
                          color: Colors.green.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          "${index + 1}. ${question.questionText}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: options.map((option) {

                            bool isSelected =
                                selectedAnswers[question.questionID] == option;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedAnswers[question.questionID] = option;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8),
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

              /// 🔹 Submit Button
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

                          if (selectedAnswers.length != questions.length) {

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please answer all questions"),
                              ),
                            );

                            return;
                          }

                          await submitEvaluation();
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
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
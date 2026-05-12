// ignore_for_file: file_names, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:epams/Url.dart';

class Evaluatementors extends StatefulWidget {
  final Map mentorData;
  final int sessionId;
  final String evaluatorId;

  const Evaluatementors({
    super.key,
    required this.mentorData,
    required this.sessionId,
    required this.evaluatorId,
  });

  @override
  State<Evaluatementors> createState() => _EvaluatementorsState();
}

class _EvaluatementorsState extends State<Evaluatementors> {
  List questions = [];
  Map<int, int> selectedScores = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  // ================= FETCH QUESTIONS =================

  Future<void> fetchQuestions() async {
    try {
      final response = await http.get(
        Uri.parse(
          "$Url/SocietyEvaluation/GetActiveQuestionnaire?type=Society Mentor",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["Questions"] == null) {
          setState(() {
            questions = [];
            isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["Message"] ?? "No questionnaire found")),
          );
          return;
        }

        setState(() {
          questions = data["Questions"];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load questions");
      }
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // ================= SUBMIT EVALUATION =================

  Future<void> submitEvaluation() async {
    if (selectedScores.length < questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please answer all questions")),
      );
      return;
    }

    List submissionData = questions.map((q) {
  return {
    "EvaluatorId": widget.evaluatorId,
    "EvaluateeId": widget.mentorData['TeacherId'].toString(),
    "SocietyId": widget.mentorData['SocietyId'],
    "QuestionId": q['QuestionID'],
    "Score": selectedScores[q['QuestionID']],
    "SessionId": widget.sessionId,   // ✅ SEND SELECTED SESSION
    "EvaluationType": "Mentor"
  };
}).toList();

    try {
      final response = await http.post(
        Uri.parse("$Url/SocietyEvaluation/Submit"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(submissionData),
      );

      final result = jsonDecode(response.body);

      if (result["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Evaluation Submitted Successfully")),
        );

        Navigator.pop(context, true);
      } else {
        throw Exception(result["error"]);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submission Failed: $e")),
      );
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text("Mentor Evaluation"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [

                // ===== HEADER =====

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Colors.teal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mentorData['TeacherName'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.mentorData['SocietyName'],
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ===== QUESTIONS =====

                Expanded(
                  child: ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      var q = questions[index];

                      return Card(
                        margin: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q['QuestionText'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 10),

                              buildRadio(q['QuestionID'], "Excellent", 4),
                              buildRadio(q['QuestionID'], "Good", 3),
                              buildRadio(q['QuestionID'], "Average", 2),
                              buildRadio(q['QuestionID'], "Poor", 1),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ===== SUBMIT BUTTON =====

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.all(14),
                      ),
                      icon: const Icon(Icons.send),
                      label: const Text("Submit Evaluation"),
                      onPressed: submitEvaluation,
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget buildRadio(int questionId, String label, int value) {
    return RadioListTile<int>(
      title: Text(label),
      value: value,
      groupValue: selectedScores[questionId],
      activeColor: Colors.teal,
      onChanged: (val) {
        setState(() {
          selectedScores[questionId] = val!;
        });
      },
    );
  }
}
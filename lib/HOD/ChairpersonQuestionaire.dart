import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:epams/Url.dart';

class ChairpersonQuestionnaire extends StatefulWidget {
  final Map chairData;
  final int sessionId;
  final String evaluatorId;

  const ChairpersonQuestionnaire({
    super.key,
    required this.chairData,
    required this.sessionId,
    required this.evaluatorId,
  });

  @override
  State<ChairpersonQuestionnaire> createState() =>
      _ChairpersonQuestionnaireState();
}

class _ChairpersonQuestionnaireState extends State<ChairpersonQuestionnaire> {
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
          "$Url/SocietyEvaluation/GetActiveQuestionnaire?type=Society Chairperson",
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
            SnackBar(
              content: Text(data["Message"] ?? "No questionnaire found"),
            ),
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
        "EvaluateeId": widget.chairData['TeacherId'].toString(),
        "SocietyId": widget.chairData['SocietyId'],
        "QuestionId": q['QuestionID'],
        "Score": selectedScores[q['QuestionID']],
        "SessionId": widget.sessionId, // ⭐ ADD THIS
        "EvaluationType": "Chairperson",
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

        Navigator.pop(context, true); // ⭐ important (already correct)
      } else {
        throw Exception(result["error"]);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Submission Failed: $e")));
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chairperson Evaluation")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ===== HEADER =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Colors.green,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.chairData['TeacherName'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.chairData['SocietyName'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
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
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q['QuestionText'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
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
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: submitEvaluation,
                      child: const Text("Submit Evaluation"),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildRadio(int questionId, String label, int value) {
    return RadioListTile<int>(
      title: Text(label),
      value: value,
      groupValue: selectedScores[questionId],
      onChanged: (val) {
        setState(() {
          selectedScores[questionId] = val!;
        });
      },
    );
  }
}

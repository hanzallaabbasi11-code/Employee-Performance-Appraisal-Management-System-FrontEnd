import 'package:epams/Teacher/QuestionnaireModel.dart';
import 'package:flutter/material.dart';

class Confidentialevaluationform extends StatefulWidget {
  final String courseCode;
  final String courseName;
  final String teacherName;
  final QuestionnaireModel questionnaire; // Pass active questionnaire

  const Confidentialevaluationform({
    super.key,
    required this.courseCode,
    required this.courseName,
    required this.teacherName,
    required this.questionnaire, required String studentId,
  });

  @override
  State<Confidentialevaluationform> createState() => _ConfidentialevaluationformState();
}

class _ConfidentialevaluationformState extends State<Confidentialevaluationform> {
  Map<int, String> selectedAnswers = {};
  final List<String> options = ["Excellent", "Good", "Average", "Poor"];

  @override
  Widget build(BuildContext context) {
    final questions = widget.questionnaire.questions; // Use API questions

    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔹 Back Row
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

              /// 🔹 Course Info Card
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

                    /// Course Code Badge
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
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// 🔹 Title Above Questions
              const Text(
                "Evaluation Questions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              /// 🔹 Questions List
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

                        /// Question Text
                        Text(
                          "${index + 1}. ${question.questionText}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// Options
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
                                  color: isSelected ? Colors.green.shade50 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? Colors.green : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    color: isSelected ? Colors.green : Colors.black,
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
                  onPressed: () {
                    if (selectedAnswers.length != questions.length) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please answer all questions"),
                        ),
                      );
                      return;
                    }

                    // TODO: Call API to save evaluation here

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Evaluation Submitted Successfully"),
                      ),
                    );

                    Navigator.pop(context);
                  },
                  child: const Text(
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

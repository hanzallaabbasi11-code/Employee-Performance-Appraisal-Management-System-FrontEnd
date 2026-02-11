import 'package:flutter/material.dart';

class Evaluatementors extends StatefulWidget {
  const Evaluatementors({super.key});

  @override
  State<Evaluatementors> createState() => _EvaluatementorsState();
}

class _EvaluatementorsState extends State<Evaluatementors> {

  // Store selected answers
  Map<int, String> selectedAnswers = {};

  // Questions Data
  final List<Map<String, dynamic>> questions = [
    {
      "question": "Participated actively in society events?",
      "options": ["Yes", "No", "Partially"]
    },
    {
      "question": "Contributed to planning and organizing activities?",
      "options": ["Excellent", "Good", "Average"]
    },
    {
      "question": "Attendance in society meetings?",
      "options": ["Regular", "Occasional", "Rare"]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: Column(
          children: [

            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),

                  const SizedBox(width: 8),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ali Raza",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Computing Society",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  Image.asset('assets/images/logo.jpeg', height: 40),
                ],
              ),
            ),

            // ================= INFO BANNER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.teal,
              child: const Text(
                "Please evaluate based on recent society activities.",
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 10),

            // ================= QUESTIONS =================
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return _questionCard(index);
                },
              ),
            ),

            // ================= SUBMIT BUTTON =================
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Evaluation Submitted")),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Submit Evaluation"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= QUESTION CARD =================
  Widget _questionCard(int index) {
    final question = questions[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Question Title
          Text(
            "${index + 1}. ${question["question"]}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          // Options
          Column(
            children: List.generate(
              question["options"].length,
              (optIndex) {
                String option = question["options"][optIndex];

                bool isSelected =
                    selectedAnswers[index] == option;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAnswers[index] = option;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.teal
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [

                        // Radio Dot
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.black
                                : Colors.transparent,
                            border: Border.all(
                                color: Colors.black),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(child: Text(option)),

                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: Colors.teal)
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

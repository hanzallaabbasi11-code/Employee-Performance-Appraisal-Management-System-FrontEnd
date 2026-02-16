//import 'package:epams//MakeQuestioner.dart';
import 'package:epams/Teacher/QuestionnaireModel.dart';
import 'package:epams/Teacher/TeacherModel.dart';
import 'package:flutter/material.dart';

class Peerevaluationform extends StatefulWidget {
  final TeacherModel teacher;
  final QuestionnaireModel questionnaire;

  const Peerevaluationform({
    super.key,
    required this.teacher,
    required this.questionnaire,
  });

  @override
  State<Peerevaluationform> createState() =>
      _PeerevaluationformState();
}

class _PeerevaluationformState extends State<Peerevaluationform> {

  Map<int, String> answers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teacher Evaluation Form")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// Teacher Info Card
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

          /// Dynamic Questions
          ...widget.questionnaire.questions.map((q) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.questionText),
                    const SizedBox(height: 10),

                    Column(
                      children: ["Excellent", "Good", "Average", "Poor"]
                          .map((option) => RadioListTile<String>(
                                title: Text(option),
                                value: option,
                                groupValue: answers[q.questionID],
                                onChanged: (value) {
                                  setState(() {
                                    answers[q.questionID] = value!;
                                  });
                                },
                              ))
                          .toList(),
                    )
                  ],
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              print(answers);
              // Send to API
            },
            child: const Text("Submit Evaluation"),
          )
        ],
      ),
    );
  }
}

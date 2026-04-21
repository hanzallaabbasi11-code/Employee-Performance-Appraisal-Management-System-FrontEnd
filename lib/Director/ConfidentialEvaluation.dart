import 'package:epams/Student/Confidential_db.dart';
import 'package:flutter/material.dart';
//import 'confidential_db.dart';

class Confidentialevaluation extends StatefulWidget {
  const Confidentialevaluation({super.key});

  @override
  State<Confidentialevaluation> createState() =>
      _ConfidentialevaluationState();
}

class _ConfidentialevaluationState
    extends State<Confidentialevaluation> {

  List<Map<String, dynamic>> evaluations = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await ConfidentialDB.getEvaluations();
    setState(() {
      evaluations = data;
    });
  }

  @override
  Widget build(BuildContext context) {

    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var row in evaluations) {
      String key = "${row['session']}_${row['teacherName']}";

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }

      grouped[key]!.add(row);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Confidential Evaluation"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(12),

        children: grouped.entries.map((entry) {

          var data = entry.value.first;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),

            child: Padding(
              padding: const EdgeInsets.all(12),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    "Session: ${data['session']}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  Text("Course: ${data['courseName']}"),

                  Text("Teacher: ${data['teacherName']}"),

                  const Divider(),

                  ...entry.value.map((q) {

                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(
                            q['question'],
                            style: const TextStyle(
                                fontWeight:
                                    FontWeight.w500),
                          ),

                          Text(
                            "Answer: ${q['answer']}",
                            style: const TextStyle(
                                color: Colors.green),
                          ),

                        ],
                      ),
                    );
                  }),

                ],
              ),
            ),
          );

        }).toList(),
      ),
    );
  }
}
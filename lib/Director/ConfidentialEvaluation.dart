import 'dart:convert';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Confidentialevaluation extends StatefulWidget {
  const Confidentialevaluation({super.key});

  @override
  State<Confidentialevaluation> createState() => _ConfidentialevaluationState();
}

class _ConfidentialevaluationState extends State<Confidentialevaluation> {
  List emails = [];
  String? selectedEmail;
  List evaluations = [];
  bool loading = false;

  // ✅ NEW FILTER VARIABLE
  String selectedFilter = "all";

  @override
  void initState() {
    super.initState();
    loadEmails();
  }

  Future<void> loadEmails() async {
    final res = await http.get(Uri.parse("$Url/email/getall"));
    if (res.statusCode == 200) {
      setState(() {
        emails = jsonDecode(res.body);
      });
    }
  }

  Future<void> loadEvaluations() async {
    if (selectedEmail == null) return;

    setState(() {
      loading = true;
      evaluations = [];
    });

    final res = await http.post(
      Uri.parse("$Url/Confidential/get-evaluations"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "mail": selectedEmail,
        "filter": selectedFilter, // ✅ ADDED
      }),
    );

    final data = jsonDecode(res.body);

    if (data["success"] == true) {
      setState(() {
        evaluations = data["data"];
      });
    }

    setState(() {
      loading = false;
    });
  }

  Map<String, List> groupData() {
    Map<String, List> grouped = {};
    for (var e in evaluations) {
      String key = "${e['subjectCode']}_${e['teacherName']}";
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(e);
    }
    return grouped;
  }

  int getScore(dynamic evaluationList) {
    int total = 0;
    if (evaluationList == null) return 0;
    for (var q in evaluationList) {
      total += int.tryParse(q["score"].toString()) ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupData();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Confidential Evaluations"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedEmail,
              hint: const Text("Select Email"),
              isExpanded: true,
              items: emails.map<DropdownMenuItem<String>>((e) {
                return DropdownMenuItem<String>(
                  value: e["mail"],
                  child: Text(e["mail"]),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedEmail = val;
                });
              },
            ),

            const SizedBox(height: 10),

            // ✅ NEW FILTER DROPDOWN (NO DESIGN CHANGE)
            DropdownButtonFormField<String>(
              value: selectedFilter,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              items: const [
                DropdownMenuItem(value: "all", child: Text("All")),
                DropdownMenuItem(value: "unread", child: Text("Unread")),
                DropdownMenuItem(value: "read", child: Text("Read")),
              ],
              onChanged: (val) {
                setState(() {
                  selectedFilter = val!;
                });
              },
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: loadEvaluations,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text("Load Evaluations"),
            ),

            const SizedBox(height: 10),

            if (loading) const CircularProgressIndicator(),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: grouped.entries.map((entry) {
                  var first = entry.value.first;
                  int totalScore = getScore(first["evaluation"]);
                  List questList = first["evaluation"] ?? [];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                first["subjectCode"],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                "Total: $totalScore ⭐",
                                style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(),
                          Text("Student: ${first["studentName"] ?? "-"}"),
                          Text("Teacher: ${first["teacherName"] ?? "-"}"),
                          Text("Session: ${first["session"] ?? "-"}"),
                          const SizedBox(height: 10),

                          const Text(
                            "Detailed Feedback:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 5),

                          ...questList.map((q) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.arrow_right, size: 18),
                                  Expanded(
                                    child: Text(
                                      "${q['questionText']}: ",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Text(
                                    "${q['score']} ⭐",
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'CreateNewQuestionnaier.dart';
import 'EditEvaluationQuestionnaire.dart';

/// ================= API CONFIG =================
final String baseUrl = '$Url/Questionnaire';

/// ================= MODEL =================
class QuestionnaireModel {
  final int id;
  final String type;
  final int questionCount;
  bool isActive;

  QuestionnaireModel({
    required this.id,
    required this.type,
    required this.questionCount,
    required this.isActive,
  });

  factory QuestionnaireModel.fromJson(Map<String, dynamic> json) {
    return QuestionnaireModel(
      id: json['Id'],
      type: json['Type'],
      questionCount: json['QuestionCount'],
      isActive: json['Flag'] == "1",
    );
  }
}

/// ================= API METHODS =================
Future<List<QuestionnaireModel>> getAllQuestionnaires() async {
  final response = await http.get(Uri.parse('$baseUrl/GetAll'));

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => QuestionnaireModel.fromJson(e)).toList();
  } else {
    throw Exception("Failed to load questionnaires");
  }
}

Future<String?> toggleQuestionnaire({
  required int questionnaireId,
  required bool turnOn,
}) async {
  final response = await http.post(
    Uri.parse("$baseUrl/Toggle"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"QuestionnaireId": questionnaireId, "TurnOn": turnOn}),
  );

  if (response.statusCode == 200) {
    return null;
  } else {
    final body = jsonDecode(response.body);
    return body["Message"] ?? "Something went wrong";
  }
}

/// ================= MAIN SCREEN =================
class Makequestioner extends StatefulWidget {
  const Makequestioner({super.key});

  @override
  State<Makequestioner> createState() => _MakequestionerState();
}

class _MakequestionerState extends State<Makequestioner> {
  late Future<List<QuestionnaireModel>> future;

  @override
  void initState() {
    super.initState();
    future = getAllQuestionnaires();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<List<QuestionnaireModel>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final list = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ===== HEADER =====
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          "Evaluation Questionnaires",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Image.asset('assets/images/logo.jpeg', height: 40),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// ===== INFO BAR =====
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${list.length} Questionnaires Available",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Createnewquestionnaier(),
                                ),
                              );
                            },
                            child: const Text(
                              "+ Create New",
                              style: TextStyle(color: Colors.green,fontSize:13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ===== LIST =====
                  ...list.map((q) => QuestionnaireCard(model: q)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ================= CARD =================
class QuestionnaireCard extends StatefulWidget {
  final QuestionnaireModel model;

  const QuestionnaireCard({super.key, required this.model});

  @override
  State<QuestionnaireCard> createState() => _QuestionnaireCardState();
}

class _QuestionnaireCardState extends State<QuestionnaireCard> {
  late bool isActive;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    isActive = widget.model.isActive;
  }

  Future<void> onToggle(bool value) async {
    setState(() {
      loading = true;
      isActive = value;
    });

    final error = await toggleQuestionnaire(
      questionnaireId: widget.model.id,
      turnOn: value,
    );

    setState(() {
      loading = false;
    });

    if (error != null) {
      setState(() {
        isActive = !value;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      widget.model.isActive = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.model.type,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                  children: [
                    const Text("Questions", style: TextStyle(fontSize: 12)),
                    Text(
                      widget.model.questionCount.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// TOGGLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isActive ? "Active" : "Inactive",
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch(
                        value: isActive,
                        onChanged: onToggle,
                        activeColor: Colors.green,
                      ),
              ],
            ),

            const SizedBox(height: 10),

            /// EDIT BUTTON
            OutlinedButton.icon(
              onPressed: isActive
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditQuestionnaireScreen(
                            questionnaireId: widget.model.id,
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.edit),
              label: const Text("Edit"),
            ),
          ],
        ),
      ),
    );
  }
}

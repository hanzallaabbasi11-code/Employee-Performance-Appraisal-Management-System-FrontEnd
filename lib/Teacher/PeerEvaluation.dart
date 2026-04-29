import 'dart:convert';
import 'package:epams/Teacher/PeerEvaluationForm.dart';
import 'package:epams/Teacher/QuestionnaireModel.dart';
import 'package:epams/Teacher/TeacherModel.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Peerevaluation extends StatefulWidget {
  final int evaluatorID;
  final String userId;

  const Peerevaluation({
    super.key,
    required this.evaluatorID,
    required this.userId,
  });

  @override
  State<Peerevaluation> createState() => _PeerevaluationState();
}

class _PeerevaluationState extends State<Peerevaluation> {
  List<TeacherModel> teachers = [];
  Set<String> evaluatedTeachers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await fetchTeachers();
    await fetchSubmittedEvaluations();
  }

  Future<void> fetchTeachers() async {
    final response = await http.get(
      Uri.parse(
        '$Url/TeacherDashboard/GetTeachersWithCourses/${widget.userId}',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      teachers = data.map<TeacherModel>((e) {
        return TeacherModel.fromJson(e);
      }).toList();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchSubmittedEvaluations() async {
    final response = await http.get(
      Uri.parse(
        "$Url/TeacherDashboard/GetSubmittedEvaluations/${widget.evaluatorID}",
      ),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      evaluatedTeachers = data
          .map<String>((item) => "${item["TeacherID"]}-${item["CourseCode"]}")
          .toSet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teacher Evaluation")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                final teacher = teachers[index];

                final course = teacher.courses.isNotEmpty
                    ? teacher.courses.first
                    : "";

                final key = "${teacher.teacherID}-$course";

                final alreadyEvaluated = evaluatedTeachers.contains(key);

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      teacher.teacherName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Courses: ${teacher.courses.join(", ")}"),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: alreadyEvaluated
                            ? Colors.grey
                            : Colors.green,
                      ),
                      onPressed: alreadyEvaluated
                          ? null
                          : () async {
                              final response = await http.get(
                                Uri.parse(
                                  "$Url/TeacherDashboard/GetActiveQuestionnaire",
                                ),
                              );

                              if (response.statusCode == 200) {
                                final questionnaire =
                                    QuestionnaireModel.fromJson(
                                      jsonDecode(response.body),
                                    );

                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Peerevaluationform(
                                      teacher: teacher,
                                      questionnaire: questionnaire,
                                      evaluatorUserId: widget.userId,
                                    ),
                                  ),
                                );

                                if (result == true) {
                                  fetchSubmittedEvaluations();
                                }
                              }
                            },
                      child: Text(alreadyEvaluated ? "Evaluated" : "Evaluate"),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

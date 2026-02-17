import 'dart:convert';
import 'package:epams/Teacher/PeerEvaluationForm.dart';
import 'package:epams/Teacher/QuestionnaireModel.dart';
import 'package:epams/Teacher/TeacherModel.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Peerevaluation extends StatefulWidget {
  final int evaluatorID;

  const Peerevaluation({super.key, required this.evaluatorID});

  @override
  State<Peerevaluation> createState() => _PeerevaluationState();
}

class _PeerevaluationState extends State<Peerevaluation> {
  List<TeacherModel> teachers = [];
  Set<String> evaluatedTeachers = {}; // store teacherID-course
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeachers();
    fetchSubmittedEvaluations();
  }

  Future<void> fetchTeachers() async {
    final response = await http.get(
      Uri.parse('$Url/TeacherDashboard/GetTeachersWithCourses'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      teachers = data.map((e) => TeacherModel.fromJson(e)).toList();
    }
    setState(() => isLoading = false);
  }

  Future<void> fetchSubmittedEvaluations() async {
    final response = await http.get(
      Uri.parse(
          "$Url/TeacherDashboard/GetSubmittedEvaluations?evaluatorID=${widget.evaluatorID}"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      for (var item in data) {
        evaluatedTeachers
            .add("${item["TeacherID"]}-${item["CourseCode"]}");
      }
      setState(() {});
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
                final key =
                    "${teacher.teacherID}-${teacher.courses.isNotEmpty ? teacher.courses.first : ""}";

                final alreadyEvaluated =
                    evaluatedTeachers.contains(key);

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacher.teacherName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text("Courses: ${teacher.courses.join(", ")}"),
                        const SizedBox(height: 12),
                        ElevatedButton(
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
                                        "$Url/TeacherDashboard/GetActiveQuestionnaire"),
                                  );

                                  if (response.statusCode == 200) {
                                    final data =
                                        jsonDecode(response.body);

                                    final questionnaire =
                                        QuestionnaireModel.fromJson(
                                            data);

                                    final result =
                                        await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            Peerevaluationform(
                                          teacher: teacher,
                                          questionnaire:
                                              questionnaire,
                                          evaluatorID:
                                              widget.evaluatorID,
                                        ),
                                      ),
                                    );

                                    if (result == true) {
                                      fetchSubmittedEvaluations();
                                    }
                                  }
                                },
                          child: Text(
                              alreadyEvaluated
                                  ? "Evaluated"
                                  : "Evaluate"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

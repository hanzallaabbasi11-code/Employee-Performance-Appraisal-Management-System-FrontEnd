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
    init();
  }

  Future<void> init() async {
    await fetchTeachers();
    await fetchSubmittedEvaluations();
  }

  Future<void> fetchTeachers() async {
    try {
      final res = await http.get(
        Uri.parse(
          "$Url/TeacherDashboard/GetTeachersWithCourses?userId=${widget.userId}",
        ),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data is List) {
          teachers = data
              .map<TeacherModel>(
                (e) => TeacherModel.fromJson(e),
              )
              .toList();
        } else {
          teachers = [];
        }
      }

      print(res.body);
    } catch (e) {
      teachers = [];
      print("fetchTeachers error: $e");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchSubmittedEvaluations() async {
    try {
      final res = await http.get(
        Uri.parse(
          "$Url/TeacherDashboard/GetSubmittedEvaluations?evaluatorID=${widget.evaluatorID}",
        ),
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);

        if (mounted) {
          setState(() {
            evaluatedTeachers = data
                .map<String>(
                  (e) => "${e["TeacherID"]}-${e["CourseCode"]}",
                )
                .toSet();
          });
        }
      }
    } catch (e) {
      print("fetchSubmittedEvaluations error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teacher Evaluation")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : teachers.isEmpty
              ? const Center(child: Text("No Teachers Found"))
              : ListView.builder(
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final t = teachers[index];

                    final courses = t.courses;

                    if (courses.isEmpty) {
                      return const SizedBox(); // safe skip
                    }

                    return Column(
                      children: courses.map((course) {
                        final key = "${t.teacherID}-$course";
                        final done = evaluatedTeachers.contains(key);

                        return Card(
                          child: ListTile(
                            title: Text(t.teacherName),
                            subtitle: Text("Course: $course"),
                            trailing: ElevatedButton(
                              onPressed: done
                                  ? null
                                  : () async {
                                      final q = await http.get(
                                        Uri.parse(
                                          "$Url/TeacherDashboard/GetActiveQuestionnaire",
                                        ),
                                      );

                                      if (q.statusCode != 200) return;

                                      final questionnaire =
                                          QuestionnaireModel.fromJson(
                                        jsonDecode(q.body),
                                      );

                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => Peerevaluationform(
                                            teacher: t,
                                            questionnaire: questionnaire,
                                            evaluatorID: widget.evaluatorID,
                                            courseCode: course,
                                          ),
                                        ),
                                      );

                                      if (result == true) {
                                        await fetchSubmittedEvaluations();
                                      }
                                    },
                              child: Text(done ? "Evaluated" : "Evaluate"),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
    );
  }
}
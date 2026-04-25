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
  Set<String> evaluatedTeachers = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  /// =========================
  /// INITIAL LOAD
  /// =========================
  Future<void> initialize() async {
    await fetchTeachers();
    await fetchSubmittedEvaluations();
  }

  /// =========================
  /// LOAD TEACHERS
  /// =========================
  Future<void> fetchTeachers() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$Url/TeacherDashboard/GetTeachersWithCourses/${widget.evaluatorID}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          teachers = data.map((e) => TeacherModel.fromJson(e)).toList();
        } else {
          error = "Invalid API response";
        }
      } else {
        error = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      error = "Error: $e";
    }

    setState(() => isLoading = false);
  }

  /// =========================
  /// FETCH SUBMITTED EVALUATIONS
  /// =========================
  Future<void> fetchSubmittedEvaluations() async {
    try {
      final response = await http.get(
        Uri.parse(
          "$Url/TeacherDashboard/GetSubmittedEvaluations/${widget.evaluatorID}",
        ),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          evaluatedTeachers = data
              .map<String>(
                (item) => "${item["TeacherID"]}-${item["CourseCode"]}",
              )
              .toSet();
        });
      }
    } catch (_) {}
  }

  /// =========================
  /// CHECK EVALUATOR STATUS
  /// =========================
  Future<bool> canEvaluate() async {
    try {
      final response = await http.get(
        Uri.parse(
          "$Url/TeacherDashboard/IsEvaluator/${widget.evaluatorID}",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["isEvaluator"] == true;
      }
    } catch (_) {}

    return false;
  }

  /// =========================
  /// UI
  /// =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Evaluation"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          : error != null
              ? Center(child: Text(error!))

              : teachers.isEmpty
                  ? const Center(child: Text("No teachers found"))

                  : ListView.builder(
                      itemCount: teachers.length,
                      itemBuilder: (context, index) {
                        final teacher = teachers[index];

                        final course =
                            teacher.courses.isNotEmpty ? teacher.courses.first : "";

                        final key = "${teacher.teacherID}-$course";

                        final alreadyEvaluated =
                            evaluatedTeachers.contains(key);

                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  teacher.teacherName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  "Courses: ${teacher.courses.join(", ")}",
                                ),

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
                                          bool allowed =
                                              await canEvaluate();

                                          if (!allowed) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Not allowed to evaluate this teacher",
                                                ),
                                              ),
                                            );
                                            return;
                                          }

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
                                        : "Evaluate",
                                  ),
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
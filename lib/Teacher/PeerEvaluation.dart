import 'dart:convert';
import 'package:epams/Teacher/PeerEvaluationForm.dart';
import 'package:epams/Teacher/QuestionnaireModel.dart';
import 'package:epams/Teacher/TeacherModel.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Peerevaluation extends StatefulWidget {
  const Peerevaluation({super.key});

  @override
  State<Peerevaluation> createState() => _PeerevaluationState();
}

class _PeerevaluationState extends State<Peerevaluation> {
  //final Questions=List<Question>;
  //final questionnaire = QuestionnaireModel.fromJson(data);
  List<TeacherModel> teachers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  Future<void> fetchTeachers() async {
    try {
      final response = await http.get(
        Uri.parse('$Url/TeacherDashboard/GetTeachersWithCourses'),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          teachers = data.map((e) => TeacherModel.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("API Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Exception: $e");
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
                final teacher = teachers[index];

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
                          onPressed: () {
                            // Fetch active questionnaire and navigate if available
                            checkAndLoadQuestionnaire(teacher);
                          },
                          child: const Text("Evaluate"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> checkAndLoadQuestionnaire(TeacherModel teacher) async {
    try {
      final response = await http.get(
        Uri.parse("$Url/TeacherDashboard/GetActiveQuestionnaire"),
      );

      print("Questionnaire Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["Flag"] != null &&
            data["Flag"].toString() == "1" &&
            data["Type"] != null &&
            data["Type"].toString().toLowerCase() == "peer evaluation") {
          final questionnaire = QuestionnaireModel.fromJson(data);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Peerevaluationform(
                teacher: teacher,
                questionnaire: questionnaire,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No active teacher questionnaire")),
          );
        }
      }
    } catch (e) {
      print("Questionnaire Exception: $e");
    }
  }
}

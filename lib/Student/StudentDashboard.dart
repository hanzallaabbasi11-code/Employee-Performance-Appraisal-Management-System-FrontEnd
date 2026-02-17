import 'dart:convert';
import 'package:epams/Student/EvaluationForm.dart';
import 'package:epams/Student/ConfidentialEvaluation.dart';
import 'package:epams/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Teacher/QuestionnaireModel.dart' show QuestionnaireModel;
import '../Url.dart';

class Studentdashboard extends StatefulWidget {
  final String studentId; // Logged-in student ID

  const Studentdashboard({super.key, required this.studentId});

  @override
  State<Studentdashboard> createState() => _StudentdashboardState();
}

class _StudentdashboardState extends State<Studentdashboard> {
  bool isLoadingCourses = true;
  bool isLoadingQuestionnaire = true;
   String studentName = "";

  List<StudentCourse> courses = [];
  QuestionnaireModel? activeQuestionnaire;

  @override
  void initState() {
    super.initState();
    fetchStudentCourses();
    fetchStudentName();
    fetchActiveQuestionnaire();
  }

  // Fetch courses for the logged-in student
Future<void> fetchStudentName() async {
    try {
      final response = await http.get(
        Uri.parse("$Url/Student/GetStudentName/${widget.studentId}"),
      );

      if (response.statusCode == 200) {
        setState(() {
          studentName = response.body.replaceAll('"', '');
        });
      } else {
         studentName = "Student";
      }
    } catch (e) {
      print("Error fetching student name: $e");
    }
  }

  Future<void> fetchStudentCourses() async {
    try {
      final response = await http.get(
        Uri.parse("$Url/Student/GetStudentEnrollments/${widget.studentId}"),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          courses = data.map((e) => StudentCourse.fromJson(e)).toList();
          isLoadingCourses = false;
        });
      } else {
        setState(() => isLoadingCourses = false);
        print("Courses API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Courses Exception: $e");
      setState(() => isLoadingCourses = false);
    }
  }

  // Fetch active teacher questionnaire
  Future<void> fetchActiveQuestionnaire() async {
    try {
      final response = await http.get(
        Uri.parse("$Url/Student/GetActiveQuestionnaire?type=Teacher Evaluation"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["Flag"]?.toString() == "1") {
          setState(() {
            activeQuestionnaire = QuestionnaireModel.fromJson(data);
            isLoadingQuestionnaire = false;
          });
        } else {
          setState(() {
            activeQuestionnaire = null;
            isLoadingQuestionnaire = false;
          });
        }
      } else {
        setState(() => isLoadingQuestionnaire = false);
      }
    } catch (e) {
      print("Questionnaire Exception: $e");
      setState(() => isLoadingQuestionnaire = false);
    }
  }

  Widget buildCourseCard(StudentCourse course) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Code + Semester
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(course.courseCode,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(course.sessionName,
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          Text(course.courseTitle),
          Text(course.teacherName),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: activeQuestionnaire != null
                    ? Colors.green
                    : Colors.grey,
                foregroundColor: Colors.white,
              ),
              onPressed: activeQuestionnaire != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Evaluationform(
                            courseCode: course.courseCode,
                            courseName: course.courseTitle,
                            teacherName: course.teacherName,
                            questionnaire: activeQuestionnaire!,
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text('Evaluate'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF9),
      body: SafeArea(
        child: isLoadingCourses
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Top Profile Row
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundImage: AssetImage(
                                'assets/images/student_image.jpeg'),
                          ),
                          const SizedBox(width: 10),
                           Expanded(
                             child: Text(
                                                     studentName.isEmpty
                              ? "Welcome 👏"
                              : "Welcome, $studentName 👏",
                                                     style: const TextStyle(
                                                       fontSize: 12,
                                                       fontWeight: FontWeight.bold,
                                                     ),
                                                   ),
                           ),
                          const Spacer(),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              onPressed: () {
                                // Pass studentId to Confidential Evaluation
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Confidentialevaluation(
                                        studentId: widget.studentId),
                                  ),
                                );
                              },
                              child: const Text(
                                'Confidential Evaluation',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0A8F3C),
                                ),
                              ),
                            ),
                          
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'Teacher Evaluation',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Review and evaluate your courses for the current semester',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 15),

                      // Courses List
                      ...courses.map((course) => buildCourseCard(course)),

                      /// Logout Button
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Logout",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

/// Model for student courses
class StudentCourse {
  final int enrollmentID;
  final String courseCode;
  final String courseTitle;
  final String teacherName;
  final String sessionName;

  StudentCourse({
    required this.enrollmentID,
    required this.courseCode,
    required this.courseTitle,
    required this.teacherName,
    required this.sessionName,
  });

  factory StudentCourse.fromJson(Map<String, dynamic> json) {
    return StudentCourse(
      enrollmentID: json['EnrollmentID'],
      courseCode: json['CourseCode'] ?? '',
      courseTitle: json['CourseTitle'] ?? '',
      teacherName: json['TeacherName'] ?? '',
      sessionName: json['SessionName'] ?? '',
    );
  }
}

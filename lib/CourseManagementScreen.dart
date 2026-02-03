import 'dart:convert';
import 'package:epams/CMModal.dart';
import 'package:epams/CourseManagementModel.dart';
import 'package:epams/Session.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Coursemanagementscreen extends StatefulWidget {
  const Coursemanagementscreen({super.key});

  @override
  State<Coursemanagementscreen> createState() => _CoursemanagementscreenState();
}

class _CoursemanagementscreenState extends State<Coursemanagementscreen> {
  late Future<List<Session>> _sessionsFuture;
  Future<List<EnrollmentCourse>>? _coursesFuture;

  Session? selectedSession;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = fetchSessions();
  }

  // ================= FETCH SESSIONS =================
  Future<List<Session>> fetchSessions() async {
    final response = await http.get(
      Uri.parse('$Url/PeerEvaluator/Sessions'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Session.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load sessions');
    }
  }

  // ================= FETCH COURSES =================
  Future<List<EnrollmentCourse>> fetchEnrollmentCourses(int sessionId) async {
    final response = await http.get(
      Uri.parse('$Url/CourseManagement/EnrollmentCourses/$sessionId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => EnrollmentCourse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load courses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF9),
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Course Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Evaluate Course Submission and\nAcademic Responsibilities',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Image.asset('assets/images/logo.jpeg', height: 40),
                ],
              ),
            ),

            // ================= SESSION DROPDOWN =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FutureBuilder<List<Session>>(
                future: _sessionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return const Text('Failed to load sessions');
                  }

                  final sessions = snapshot.data!;

                  return DropdownButtonFormField<Session>(
                    value: selectedSession,
                    hint: const Text('Select Session'),
                    items: sessions.map((s) {
                      return DropdownMenuItem<Session>(
                        value: s,
                        child: Text(s.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedSession = val;
                        _coursesFuture = fetchEnrollmentCourses(val!.id);
                      });
                    },
                    decoration: _inputDecoration(),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ================= COURSE LIST =================
            Expanded(
              child: selectedSession == null
                  ? const Center(child: Text('Please select a session'))
                  : FutureBuilder<List<EnrollmentCourse>>(
                      future: _coursesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Failed to load courses'),
                          );
                        }

                        final courses = snapshot.data!;

                        if (courses.isEmpty) {
                          return const Center(child: Text('No courses found'));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            return EnrollmentCourseCard(
                              course: courses[index],
                              onEvaluate: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) => Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(
                                        context,
                                      ).viewInsets.bottom,
                                    ),
                                    child: EvaluateModal(
                                      courseTitle: courses[index].course,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF3F8F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}

//
// ================= CARD WIDGET =================
//

class EnrollmentCourseCard extends StatelessWidget {
  final EnrollmentCourse course;
  final VoidCallback onEvaluate;

  const EnrollmentCourseCard({
    super.key,
    required this.course,
    required this.onEvaluate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teacher
          Row(
            children: [
              const Icon(Icons.person, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                course.teacher,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Course title
          Text(
            course.course.toUpperCase(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 4),

          // Course code
          Text(course.code, style: TextStyle(color: Colors.grey.shade600)),

          const SizedBox(height: 16),

          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onEvaluate,
              icon: const Icon(Icons.edit),
              label: const Text('Evaluate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

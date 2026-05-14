// ignore_for_file: file_names, deprecated_member_use

import 'dart:convert';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Coursemanagmentevaluation extends StatefulWidget {
  final String teacherId;

  const Coursemanagmentevaluation({
    super.key,
    required this.teacherId,
  });

  @override
  State<Coursemanagmentevaluation> createState() =>
      _CoursemanagmentevaluationState();
}

class _CoursemanagmentevaluationState
    extends State<Coursemanagmentevaluation> {
  bool isLoading = true;
  bool isSessionLoading = true;

  List<dynamic> performanceList = [];
  List<dynamic> coursesList = [];
  List<dynamic> sessions = [];

  int? selectedSessionId;

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  // ================= FETCH SESSIONS =================
  Future<void> fetchSessions() async {
    try {
      final response = await http.get(
        Uri.parse("$Url/PeerEvaluator/Sessions"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          sessions = data;

          if (sessions.isNotEmpty) {
            selectedSessionId = sessions.first['id'];
          }

          isSessionLoading = false;
        });

        if (selectedSessionId != null) {
          fetchPerformance();
        }
      } else {
        setState(() {
          isSessionLoading = false;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isSessionLoading = false;
        isLoading = false;
      });
    }
  }

  // ================= FETCH PERFORMANCE =================
  Future<void> fetchPerformance() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          "$Url/CourseManagement/my-Courseperformance/${widget.teacherId}/$selectedSessionId",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          performanceList = data['Performance'] ?? [];
          coursesList = data['Courses'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          performanceList = [];
          coursesList = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        performanceList = [];
        coursesList = [];
        isLoading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    return status.toLowerCase() == "on time"
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);
  }

  Color getProgressColor(double score) {
    if (score >= 5) return const Color(0xFF16A34A);
    if (score >= 3) return Colors.orange;
    return Colors.red;
  }

  Color getStatusBg(String status) {
    return status.toLowerCase() == "on time"
        ? const Color(0xFFDDF7E5)
        : const Color(0xFFFDE2E2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER (UNCHANGED) =================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Course Management",
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                        Text(
                          "HOD Evaluation & Session Performance",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ================= BODY =================
            Expanded(
              child: isSessionLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "My Performance Details",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ================= SESSION DROPDOWN (UNCHANGED) =================
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: selectedSessionId,
                                items: sessions.map((session) {
                                  return DropdownMenuItem<int>(
                                    value: session['id'],
                                    child: Text(session['name']),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedSessionId = value;
                                  });
                                  fetchPerformance();
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (isLoading)
                            const Center(child: CircularProgressIndicator()),

                          if (!isLoading && coursesList.isEmpty)
                            const Center(
                              child: Text("No courses found"),
                            ),

                          // ================= COURSES =================
                          if (!isLoading)
                            ListView.builder(
                              itemCount: coursesList.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final course = coursesList[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        course['CourseName'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(course['CourseCode'] ?? ''),

                                      const SizedBox(height: 12),

                                      // ================= PERFORMANCE (UNCHANGED LOGIC) =================
                                      ListView.builder(
                                        itemCount: performanceList.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, i) {
                                          final item = performanceList[i];

                                          final double score =
                                              (item['ObtainedScore'] ?? 0)
                                                  .toDouble();

                                          final String status =
                                              item['Status'] ?? "";

                                          return Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF9FAFB),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(item['Activity'] ?? ""),
                                                const SizedBox(height: 6),
                                                Text(item['Remarks'] ?? ""),
                                                const SizedBox(height: 6),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(status),
                                                    Text("${score.toInt()}/5"),
                                                  ],
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
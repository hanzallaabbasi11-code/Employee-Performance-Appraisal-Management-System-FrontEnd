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

  // ================= COLORS =================

  Color getStatusColor(String status) {
    return status.toLowerCase() == "on time"
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);
  }

  Color getStatusBg(String status) {
    return status.toLowerCase() == "on time"
        ? const Color(0xFFDDF7E5)
        : const Color(0xFFFDE2E2);
  }

  Color getScoreColor(double score) {
    if (score >= 5) return const Color(0xFF16A34A);
    if (score >= 3) return Colors.orange;
    return Colors.red;
  }

  // ================= FILTER COURSE PERFORMANCE =================

  List<dynamic> getCoursePerformance(String courseCode) {
    return performanceList
        .where((item) => item['CourseCode'] == courseCode)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),

      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================

            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

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

                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                      ),
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
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
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
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
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

                          // ================= SESSION DROPDOWN =================

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),

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

                          // ================= LOADING =================

                          if (isLoading)
                            const Center(
                              child: CircularProgressIndicator(),
                            ),

                          // ================= EMPTY =================

                          if (!isLoading && coursesList.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: Text("No courses found"),
                              ),
                            ),

                          // ================= COURSE CARDS =================

                          if (!isLoading)
                            ListView.builder(
                              itemCount: coursesList.length,
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),

                              itemBuilder: (context, index) {
                                final course = coursesList[index];

                                final courseCode =
                                    course['CourseCode'] ?? "";

                                final coursePerformance =
                                    getCoursePerformance(courseCode);

                                return Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 18),

                                  padding: const EdgeInsets.all(16),

                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),

                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      // ================= COURSE HEADER =================

                                      Row(
                                        children: [
                                          Container(
                                            padding:
                                                const EdgeInsets.all(10),

                                            decoration: BoxDecoration(
                                              color: const Color(
                                                  0xFFE8F5E9),

                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12),
                                            ),

                                            child: const Icon(
                                              Icons.menu_book_rounded,
                                              color: Colors.green,
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,

                                              children: [
                                                Text(
                                                  course['CourseName'] ??
                                                      '',

                                                  style:
                                                      const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w800,
                                                  ),
                                                ),

                                                const SizedBox(height: 2),

                                                Text(
                                                  courseCode,
                                                  style: TextStyle(
                                                    color: Colors
                                                        .grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 18),

                                      // ================= PERFORMANCE ITEMS =================

                                      if (coursePerformance.isEmpty)
                                        Container(
                                          padding:
                                              const EdgeInsets.all(14),

                                          decoration: BoxDecoration(
                                            color: const Color(
                                                0xFFF9FAFB),

                                            borderRadius:
                                                BorderRadius.circular(
                                                    14),
                                          ),

                                          child: const Text(
                                            "No evaluation found",
                                          ),
                                        ),

                                      ...coursePerformance.map((item) {
                                        final double score =
                                            (item['ObtainedScore'] ??
                                                    0)
                                                .toDouble();

                                        final String status =
                                            item['Status'] ?? "";

                                        final String remarks =
                                            item['Remarks'] ?? "";

                                        return Container(
                                          margin:
                                              const EdgeInsets.only(
                                                  bottom: 12),

                                          padding:
                                              const EdgeInsets.all(14),

                                          decoration: BoxDecoration(
                                            color: const Color(
                                                0xFFF9FAFB),

                                            borderRadius:
                                                BorderRadius.circular(
                                                    16),
                                          ),

                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,

                                            children: [
                                              // ================= ACTIVITY =================

                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,

                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item['Activity'] ??
                                                          "",

                                                      style:
                                                          const TextStyle(
                                                        fontWeight:
                                                            FontWeight
                                                                .w700,

                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),

                                                  Container(
                                                    padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5,
                                                    ),

                                                    decoration:
                                                        BoxDecoration(
                                                      color:
                                                          getStatusBg(
                                                              status),

                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                                  30),
                                                    ),

                                                    child: Text(
                                                      status,

                                                      style: TextStyle(
                                                        color:
                                                            getStatusColor(
                                                                status),

                                                        fontWeight:
                                                            FontWeight
                                                                .bold,

                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 12),

                                              // ================= SCORE =================

                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.star_rounded,
                                                    color: Colors.amber,
                                                    size: 18,
                                                  ),

                                                  const SizedBox(
                                                      width: 6),

                                                  Text(
                                                    "Score: ${score.toInt()}/5",

                                                    style: TextStyle(
                                                      color:
                                                          getScoreColor(
                                                              score),

                                                      fontWeight:
                                                          FontWeight
                                                              .bold,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 12),

                                              // ================= REMARKS =================

                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets
                                                        .all(12),

                                                decoration:
                                                    BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(12),

                                                  border: Border.all(
                                                    color: Colors
                                                        .grey.shade200,
                                                  ),
                                                ),

                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,

                                                  children: [
                                                    const Icon(
                                                      Icons.comment,
                                                      size: 18,
                                                      color:
                                                          Colors.green,
                                                    ),

                                                    const SizedBox(
                                                        width: 8),

                                                    Expanded(
                                                      child: Text(
                                                        remarks,
                                                        style:
                                                            const TextStyle(
                                                          height: 1.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
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
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
        setState(() {
          performanceList = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          performanceList = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        performanceList = [];
        isLoading = false;
      });
    }
  }

  // ================= HELPERS =================
  Color getStatusColor(String status) {
    if (status.toLowerCase() == "on time") {
      return const Color(0xFF16A34A);
    }
    return const Color(0xFFDC2626);
  }

  Color getProgressColor(double score) {
    if (score >= 5) {
      return const Color(0xFF16A34A);
    } else if (score >= 3) {
      return Colors.orange;
    }
    return Colors.red;
  }

  Color getStatusBg(String status) {
    if (status.toLowerCase() == "on time") {
      return const Color(0xFFDDF7E5);
    }
    return const Color(0xFFFDE2E2);
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: Color(0xFF374151),
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
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "HOD Evaluation & Session Performance",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ================= BODY =================
            Expanded(
              child: isSessionLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF16A34A),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ================= TITLE =================
                          const Text(
                            "My Performance Details",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                              height: 1.1,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            "View HOD remarks, KPI scores and performance details for each session.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ================= SESSION DROPDOWN =================
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: selectedSessionId,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                ),
                                items: sessions.map((session) {
                                  return DropdownMenuItem<int>(
                                    value: session['id'],
                                    child: Text(
                                      session['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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

                          const SizedBox(height: 24),

                          // ================= LOADING =================
                          if (isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 50),
                                child: CircularProgressIndicator(
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ),

                          // ================= EMPTY =================
                          if (!isLoading && performanceList.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "No performance data found",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // ================= PERFORMANCE LIST =================
                          if (!isLoading)
                            ListView.builder(
                              itemCount: performanceList.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final item = performanceList[index];

                                final double score =
                                    (item['ObtainedScore'] ?? 0).toDouble();

                                final String status =
                                    item['Status'] ?? "";

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 18),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ================= TOP =================
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 52,
                                            width: 52,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEAF8EE),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: const Icon(
                                              Icons.auto_graph_rounded,
                                              color: Color(0xFF16A34A),
                                              size: 26,
                                            ),
                                          ),

                                          const SizedBox(width: 14),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['Activity'] ?? "",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 18,
                                                    color: Color(0xFF111827),
                                                  ),
                                                ),

                                                const SizedBox(height: 4),

                                                const Text(
                                                  "KPI PERFORMANCE EVALUATION",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 1.2,
                                                    color: Color(0xFF9CA3AF),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 7,
                                            ),
                                            decoration: BoxDecoration(
                                              color: getStatusBg(status),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Text(
                                              status.toUpperCase(),
                                              style: TextStyle(
                                                color:
                                                    getStatusColor(status),
                                                fontWeight: FontWeight.w800,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 22),

                                      // ================= REMARKS =================
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF9FAFB),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          border: Border.all(
                                            color: const Color(0xFFE5E7EB),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: const [
                                                Icon(
                                                  Icons.description_outlined,
                                                  size: 15,
                                                  color: Color(0xFF6B7280),
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  "HOD REMARKS",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 10,
                                                    letterSpacing: 1,
                                                    color: Color(0xFF9CA3AF),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 12),

                                            Text(
                                              "\"${item['Remarks'] ?? ''}\"",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.italic,
                                                color: Color(0xFF374151),
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // ================= SCORE =================
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "OBTAINED SCORE",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1,
                                              color: Color(0xFF9CA3AF),
                                            ),
                                          ),

                                          Text(
                                            "${score.toInt()} / 5",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color:
                                                  getProgressColor(score),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        child: LinearProgressIndicator(
                                          value: score / 5,
                                          minHeight: 8,
                                          backgroundColor:
                                              const Color(0xFFE5E7EB),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            getProgressColor(score),
                                          ),
                                        ),
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
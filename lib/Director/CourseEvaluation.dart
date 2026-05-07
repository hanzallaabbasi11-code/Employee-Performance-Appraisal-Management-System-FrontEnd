// courseevaluation.dart

import 'dart:convert';
//import 'package:epams/Director/CourseEvaluation.dart';
import 'package:epams/Director/DetailedCourseEvaluation.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class Courseevaluation extends StatefulWidget {
  const Courseevaluation({super.key});

  @override
  State<Courseevaluation> createState() => _CourseevaluationState();
}

class _CourseevaluationState extends State<Courseevaluation> {
  List sessions = [];
  List teachers = [];
  List<Map<String, dynamic>> courseComparison = [];
  Map<String, dynamic>? teacherPerformance;

  int? selectedSessionId;
  String? selectedTeacherId;
  String? selectedTeacherName;
  String selectedEvalType = "both";

  bool loading = false;

  @override
  void initState() {
    super.initState();
    getSessions();
  }

  Future<void> getSessions() async {
    try {
      final response = await http.get(
        Uri.parse("$Url/ExtraFeatures/GetSessions"),
      );

      if (response.statusCode == 200) {
        setState(() {
          sessions = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getTeachers(int sessionId) async {
    try {
      final response = await http.get(
        Uri.parse("$Url/ExtraFeatures/GetTeachersBySession/$sessionId"),
      );

      if (response.statusCode == 200) {
        setState(() {
          teachers = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getPerformance() async {
    if (selectedTeacherId == null || selectedSessionId == null) return;

    setState(() {
      loading = true;
      courseComparison.clear();
      teacherPerformance = null;
    });

    try {
      final performanceResponse = await http.get(
        Uri.parse(
          "$Url/ExtraFeatures/GetMyPerformance/$selectedTeacherId/$selectedSessionId",
        ),
      );

      final comparisonResponse = await http.get(
        Uri.parse(
          "$Url/ExtraFeatures/GetCourseComparison/$selectedTeacherId/$selectedSessionId?evaluationType=$selectedEvalType",
        ),
      );

      if (performanceResponse.statusCode == 200 &&
          comparisonResponse.statusCode == 200) {
        final performanceData = jsonDecode(performanceResponse.body);

        final List<dynamic> comparisonData = jsonDecode(
          comparisonResponse.body,
        );

        setState(() {
          teacherPerformance = Map<String, dynamic>.from(performanceData);

          courseComparison = comparisonData
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        });

        debugPrint(courseComparison.toString());
      }
    } catch (e) {
      debugPrint("ERROR => $e");
    }

    setState(() {
      loading = false;
    });
  }

  Color getScoreColor(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.lightGreen;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }

  Widget buildLegend(Color color, String text) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget buildCourseCard(Map item) {
    double student = (item["StudentAverage"] ?? 0).toDouble();
    double peer = (item["PeerAverage"] ?? 0).toDouble();
    double overall = (item["Overall"] ?? 0).toDouble();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Detailedcourseevaluation(
              teacherId: selectedTeacherId!,
              teacherName: selectedTeacherName ?? "",
              sessionId: selectedSessionId!,
              courseCode: item["CourseCode"],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.menu_book_rounded),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "OVERALL",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "${overall.toStringAsFixed(2)}%",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0b7a34),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  item["CourseCode"],
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: const [
                Text(
                  "Tap for question-wise detail",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (selectedEvalType != "peer")
              Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      const Text("Student"),
                      const Spacer(),
                      SizedBox(
                        width: 120,
                        child: LinearProgressIndicator(
                          value: student / 10,
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.green,
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${student.toStringAsFixed(2)}/10",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            if (selectedEvalType != "student")
              Row(
                children: [
                  const CircleAvatar(radius: 4, backgroundColor: Colors.purple),
                  const SizedBox(width: 8),
                  const Text("Peer"),
                  const Spacer(),
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      value: peer / 10,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.purple,
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${peer.toStringAsFixed(2)}/10",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 18),
            Container(
              alignment: Alignment.centerRight,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "View detail",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6f8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: const Color(0xff0b7a34),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "EVALUATION PORTAL",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        fontSize: 11,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Course Evaluation Ratings",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Select session, teacher and evaluation type",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // FIX THIS COMPLETE SECTION INSIDE YOUR SCREEN
              // Replace ONLY the white filter container section with this.
              // Everything else remains SAME.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(.08),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ================= SESSION + TEACHER =================
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool mobile = constraints.maxWidth < 700;

                        return mobile
                            ? Column(
                                children: [
                                  DropdownButtonFormField<int>(
                                    value: selectedSessionId,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      labelText: "SESSION",
                                    ),
                                    items: sessions.map<DropdownMenuItem<int>>((
                                      e,
                                    ) {
                                      return DropdownMenuItem(
                                        value: e["id"],
                                        child: Text(
                                          e["name"].toString(),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (v) async {
                                      setState(() {
                                        selectedSessionId = v;
                                        selectedTeacherId = null;
                                        teachers.clear();
                                      });

                                      if (v != null) {
                                        await getTeachers(v);
                                      }
                                    },
                                  ),

                                  const SizedBox(height: 14),

                                  DropdownButtonFormField<String>(
                                    value: selectedTeacherId,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      labelText: "TEACHER",
                                    ),
                                    items: teachers
                                        .map<DropdownMenuItem<String>>((e) {
                                          return DropdownMenuItem(
                                            value: e["UserID"],
                                            child: Text(
                                              e["Name"].toString(),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        })
                                        .toList(),
                                    onChanged: (v) {
                                      final teacher = teachers.firstWhere(
                                        (e) => e["UserID"] == v,
                                      );

                                      setState(() {
                                        selectedTeacherId = v;
                                        selectedTeacherName = teacher["Name"];
                                      });
                                    },
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<int>(
                                      value: selectedSessionId,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey.shade100,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        labelText: "SESSION",
                                      ),
                                      items: sessions
                                          .map<DropdownMenuItem<int>>((e) {
                                            return DropdownMenuItem(
                                              value: e["id"],
                                              child: Text(
                                                e["name"].toString(),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          })
                                          .toList(),
                                      onChanged: (v) async {
                                        setState(() {
                                          selectedSessionId = v;
                                          selectedTeacherId = null;
                                          teachers.clear();
                                        });

                                        if (v != null) {
                                          await getTeachers(v);
                                        }
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedTeacherId,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey.shade100,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        labelText: "TEACHER",
                                      ),
                                      items: teachers
                                          .map<DropdownMenuItem<String>>((e) {
                                            return DropdownMenuItem(
                                              value: e["UserID"],
                                              child: Text(
                                                e["Name"].toString(),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          })
                                          .toList(),
                                      onChanged: (v) {
                                        final teacher = teachers.firstWhere(
                                          (e) => e["UserID"] == v,
                                        );

                                        setState(() {
                                          selectedTeacherId = v;
                                          selectedTeacherName = teacher["Name"];
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                      },
                    ),

                    const SizedBox(height: 14),

                    // ================= EVAL + BUTTON =================
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool mobile = constraints.maxWidth < 700;

                        return mobile
                            ? Column(
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: selectedEvalType,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      labelText: "EVALUATION TYPE",
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: "both",
                                        child: Text(
                                          "Both",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: "student",
                                        child: Text(
                                          "Student",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: "peer",
                                        child: Text(
                                          "Peer",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      setState(() {
                                        selectedEvalType = v!;
                                      });
                                    },
                                  ),

                                  const SizedBox(height: 14),

                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: getPerformance,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xff0b7a34,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 18,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "View",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedEvalType,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey.shade100,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        labelText: "EVALUATION TYPE",
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: "both",
                                          child: Text(
                                            "Both",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: "student",
                                          child: Text(
                                            "Student",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: "peer",
                                          child: Text(
                                            "Peer",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        setState(() {
                                          selectedEvalType = v!;
                                        });
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  ElevatedButton(
                                    onPressed: getPerformance,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff0b7a34),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 18,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.search, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          "View",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (!loading && courseComparison.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xff0b7a34),
                            child: Icon(Icons.show_chart, color: Colors.white),
                          ),

                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Performance Comparison",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                "Student + Peer ratings per course",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),

                          if (selectedEvalType != "peer")
                            buildLegend(Colors.green, "Student"),

                          if (selectedEvalType != "student")
                            buildLegend(Colors.purple, "Peer"),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 380,
                        child: SfCartesianChart(
                          plotAreaBorderWidth: 0,
                          primaryXAxis: CategoryAxis(
                            majorGridLines: const MajorGridLines(width: 0),
                            axisLine: const AxisLine(width: 0),
                            majorTickLines: const MajorTickLines(size: 0),
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          primaryYAxis: NumericAxis(
                            minimum: 0,
                            maximum: 10,
                            interval: 2,
                            axisLine: const AxisLine(width: 0),
                            majorTickLines: const MajorTickLines(size: 0),
                            majorGridLines: MajorGridLines(
                              width: 1,
                              color: Colors.grey.shade200,
                            ),
                            labelStyle: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          legend: Legend(
                            isVisible: true,
                            position: LegendPosition.top,
                            overflowMode: LegendItemOverflowMode.wrap,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          tooltipBehavior: TooltipBehavior(
                            enable: true,
                            canShowMarker: false,
                            format: 'point.x : point.y',
                          ),
                          series: <CartesianSeries>[
                            if (selectedEvalType != "peer")
                              ColumnSeries<Map, String>(
                                name: "Student",
                                width: 0.35,
                                spacing: 0.2,
                                borderRadius: BorderRadius.circular(8),
                                dataSource: courseComparison,
                                xValueMapper: (data, _) => data["CourseCode"],
                                yValueMapper: (data, _) =>
                                    (data["StudentAverage"] ?? 0).toDouble(),
                                color: Colors.green,
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            if (selectedEvalType != "student")
                              ColumnSeries<Map, String>(
                                name: "Peer",
                                width: 0.35,
                                spacing: 0.2,
                                borderRadius: BorderRadius.circular(8),
                                dataSource: courseComparison,
                                xValueMapper: (data, _) => data["CourseCode"],
                                yValueMapper: (data, _) =>
                                    (data["PeerAverage"] ?? 0).toDouble(),
                                color: Colors.purple,
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 10,
                        children: [
                          buildLegend(Colors.green, "8-10 EXCELLENT"),
                          buildLegend(Colors.lightGreen, "6-8 GOOD"),
                          buildLegend(Colors.orange, "4-6 AVERAGE"),
                          buildLegend(Colors.red, "0-4 LOW"),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              if (courseComparison.isNotEmpty)
                const Text(
                  "COURSE DETAILS — CLICK FOR QUESTION-WISE RATINGS",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.grey,
                    letterSpacing: 1,
                  ),
                ),
              const SizedBox(height: 18),
              ...courseComparison.map((e) => buildCourseCard(e)),
            ],
          ),
        ),
      ),
    );
  }
}

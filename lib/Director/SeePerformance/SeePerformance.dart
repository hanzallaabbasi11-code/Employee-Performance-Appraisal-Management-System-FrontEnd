// ignore_for_file: file_names, strict_top_level_inference

import 'dart:convert';
//import 'package:epams/Director/DetailComparison.dart';
//import 'package:epams/Director/CompareResult.dart';
import 'package:epams/Director/SeePerformance/DetailComparison.dart';
import 'package:epams/Director/SeePerformance/DetailedPerformance.dart';
import 'package:epams/Student/ConfidentialEvaluationStudents/Confidential_db.dart';
//import 'package:epams/Director/ViewPerformance.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class Seeperformance extends StatefulWidget {
  const Seeperformance({super.key});

  @override
  State<Seeperformance> createState() => _SeeperformanceState();
}

class _SeeperformanceState extends State<Seeperformance> {
  List sessions = [];
  List<String> courses = [];
  List teachers = [];

  int? selectedSession;
  int selectedTab = 0;

  String selectedCourse = "All";

  // ================= NEW STATIC TYPES =================
  List<String> employeeTypes = ["CS", "Non CS"];
  String selectedDepartment = "CS";

  @override
  void initState() {
    super.initState();
    getSessions();
  }

  // ================= SESSIONS =================
  Future getSessions() async {
    var res = await http.get(Uri.parse("$Url/Performance/GetSessions"));
    var data = jsonDecode(res.body);

    setState(() {
      sessions = data;

      if (sessions.isNotEmpty) {
        selectedSession = sessions.first['id'];
        getCourses(selectedSession!);
        getPerformance();
      }
    });
  }

  // ================= COURSES =================
  Future getCourses(int sessionId) async {
    var res = await http.get(
      Uri.parse("$Url/Performance/GetCoursesBySession?sessionId=$sessionId"),
    );

    var data = jsonDecode(res.body);

    setState(() {
      courses = ["All"];

      for (var c in data) {
        if (c is String) {
          courses.add(c);
        } else {
          courses.add(c['courseCode']?.toString() ?? '');
        }
      }

      selectedCourse = "All";
    });
  }

  // ================= PERFORMANCE =================
  Future getPerformance() async {
    if (selectedSession == null) return;

    String backendDepartment = "All";

    if (selectedDepartment == "CS") {
      backendDepartment = "CS";
    } else if (selectedDepartment == "Non CS") {
      backendDepartment = "Non CS";
    }

    var res = await http.get(
      Uri.parse(
        "$Url/performance/GetTeachersPerformanceList"
        "?sessionId=$selectedSession"
        "&department=$backendDepartment"
        "&courseCode=$selectedCourse",
      ),
    );

    var data = jsonDecode(res.body);

    setState(() {
      teachers = data;
    });
  }

  // ================= MINI BAR =================
  Widget _buildMiniBar(String label, double value, Color color) {
    double normalized = (value / 100);
    normalized = normalized.clamp(0.0, 1.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: normalized,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // ================= DROPDOWNS =================
  Widget sessionDropdown() {
    return DropdownButtonFormField(
      initialValue: selectedSession,
      items: sessions.map<DropdownMenuItem>((s) {
        return DropdownMenuItem(
          value: s['id'],
          child: Text(s['name']?.toString() ?? ''),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => selectedSession = value);
        getCourses(selectedSession!);
        getPerformance();
      },
    );
  }

  Widget departmentDropdown() {
    return DropdownButtonFormField(
      initialValue: selectedDepartment,
      items: employeeTypes.map((d) {
        return DropdownMenuItem(
          value: d,
          child: Text(d),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => selectedDepartment = value.toString());
        getPerformance();
      },
    );
  }

  Widget courseFilter() {
    return Wrap(
      spacing: 8,
      children: courses.map((c) {
        bool active = selectedCourse == c;

        return ChoiceChip(
          label: Text(c),
          selected: active,
          onSelected: (_) {
            setState(() => selectedCourse = c);
            getPerformance();
          },
        );
      }).toList(),
    );
  }

  // ================= CHART =================
  Widget performanceChart() {
    if (teachers.isEmpty) return const SizedBox();

    List chartData = [...teachers];

    // descending order by percentage
    chartData.sort((a, b) {
      double aValue =
          ((a['StudentAverage'] ?? 0).toDouble() +
                  (a['PeerAverage'] ?? 0).toDouble() +
                  (a['ChrAverage'] ?? 0).toDouble()) /
              30 *
              100;

      double bValue =
          ((b['StudentAverage'] ?? 0).toDouble() +
                  (b['PeerAverage'] ?? 0).toDouble() +
                  (b['ChrAverage'] ?? 0).toDouble()) /
              30 *
              100;

      return bValue.compareTo(aValue);
    });

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Teachers Performance",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartData.length * 120,
              height: 320,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelRotation: -45,
                ),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: 100,
                  interval: 10,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  ColumnSeries(
                    dataSource: chartData,
                    xValueMapper: (d, _) => d['Name'] ?? '',
                    yValueMapper: (d, _) {
                      double student =
                          (d['StudentAverage'] ?? 0).toDouble();

                      double peer =
                          (d['PeerAverage'] ?? 0).toDouble();

                      double chr =
                          (d['ChrAverage'] ?? 0).toDouble();

                      double percent =
                          ((student + peer + chr) / 30) * 100;

                      return percent.clamp(0, 100);
                    },
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= CARD =================
  Widget teacherCard(t) {
    double student = (t['StudentAverage'] ?? 0).toDouble();

    double peer = (t['PeerAverage'] ?? 0).toDouble();

    double chr = (t['ChrAverage'] ?? 0).toDouble();

    return FutureBuilder<double>(
      future: ConfidentialDB.getAverageScoreBySessionId(
        teacherName: t['Name']?.toString() ?? '',
        sessionId: selectedSession ?? 0,
      ),
      builder: (context, snapshot) {
        // ================= CONVERT EACH KPI TO % =================
        double studentPercent = (student / 10) * 100;

        double peerPercent = (peer / 10) * 100;

        double chrPercent = (chr / 10) * 100;

        double confidentialRaw = (snapshot.data ?? 0) * 2.5;

        double confidentialPercent = (confidentialRaw / 10) * 100;

        // ================= FINAL TOTAL % =================
        double percent = (
              studentPercent +
              peerPercent +
              chrPercent +
              confidentialPercent
            ) /
            4;

        percent = percent.clamp(0, 100);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      t['Name']?.toString() ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    "${percent.toStringAsFixed(0)}%",
                  ),
                ],
              ),

              Text(
                t['CourseCode']?.toString() ?? '',
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value: percent / 100,
              ),

              const SizedBox(height: 10),

              _buildMiniBar(
                "Student",
                studentPercent,
                Colors.green,
              ),

              _buildMiniBar(
                "Peer",
                peerPercent,
                Colors.orange,
              ),

              _buildMiniBar(
                "CHR",
                chrPercent,
                Colors.purple,
              ),

              // 🔥 CONFIDENTIAL KPI
              _buildMiniBar(
                "Confidential",
                confidentialPercent,
                Colors.blue,
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Detailedperformance(
                        teacherId: t['TeacherID'],
                        courseCode: t['CourseCode'],
                        sessionId: selectedSession!,
                      ),
                    ),
                  );
                },
                child: const Text("View Performance"),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Performance"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          sessionDropdown(),

          const SizedBox(height: 10),

          departmentDropdown(),

          const SizedBox(height: 10),

          courseFilter(),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Detailcomparison(),
                ),
              );
            },
            child: const Text('Detailed'),
          ),

          performanceChart(),

          const SizedBox(height: 10),

          ...teachers.map((t) => teacherCard(t)),
        ],
      ),
    );
  }
}
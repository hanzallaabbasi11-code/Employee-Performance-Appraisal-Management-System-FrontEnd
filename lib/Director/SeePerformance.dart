import 'dart:convert';
//import 'package:epams/Director/DetailComparison.dart';
import 'package:epams/Director/DetailedPerformance.dart';
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
  List<String> employeeTypes = [];
  List<String> courses = [];
  List teachers = [];

  int? selectedSession;
  int selectedTab = 0;

  String selectedCourse = "All";
  String selectedDepartment = "All";

  @override
  void initState() {
    super.initState();
    getSessions();
    getEmployeeTypes();
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

  // ================= DEPARTMENTS =================
  Future getEmployeeTypes() async {
    var res = await http.get(Uri.parse("$Url/Performance/GetEmployeeTypes"));
    var data = jsonDecode(res.body);

    setState(() {
      employeeTypes = ["All"];

      for (var d in data) {
        if (d is String) {
          employeeTypes.add(d);
        } else {
          employeeTypes.add(d['type']?.toString() ?? '');
        }
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

    var res = await http.get(
      Uri.parse(
        "$Url/performance/GetTeachersPerformanceList"
        "?sessionId=$selectedSession"
        "&department=$selectedDepartment"
        "&courseCode=$selectedCourse",
      ),
    );

    var data = jsonDecode(res.body);

    for (var t in data) {
      double student = (t['StudentAverage'] ?? 0).toDouble();
      double peer = (t['PeerAverage'] ?? 0).toDouble();
      double chr = (t['ChrAverage'] ?? 0).toDouble();

      double percent = ((student + peer + chr) / 30) * 100;
      t['Percentage'] = percent.clamp(0, 100);
    }

    setState(() {
      teachers = data;
    });
  }

  Widget _buildMiniBar(String label, double value, Color color) {
    double normalized = (value / 10);
    normalized = normalized.clamp(0.0, 1.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 90, child: Text(label, style: TextStyle(fontSize: 12))),
        Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.symmetric(horizontal: 8),
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
        Text(value.toStringAsFixed(1), style: TextStyle(fontSize: 12)),
      ],
    );
  }

  // ================= DROPDOWNS =================
  Widget sessionDropdown() {
    return DropdownButtonFormField(
      value: selectedSession,
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
      value: selectedDepartment,
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
    if (teachers.isEmpty) return SizedBox();

    var topTeachers = teachers.take(3).toList();

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              series: [
                ColumnSeries(
                  dataSource: topTeachers,
                  xValueMapper: (d, _) => d['Name'] ?? '',
                  yValueMapper: (d, _) => d['Percentage'] ?? 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= CARD =================
  Widget teacherCard(t) {
    double percent = (t['Percentage'] ?? 0).toDouble();

    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t['TeacherName']?.toString() ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("${percent.toStringAsFixed(0)}%"),
            ],
          ),

          Text(t['CourseCode']?.toString() ?? ''),

          SizedBox(height: 8),

          LinearProgressIndicator(value: percent / 100),

          SizedBox(height: 10),

          _buildMiniBar("Student", (t['StudentAverage'] ?? 0).toDouble(), Colors.green),
          _buildMiniBar("Peer", (t['PeerAverage'] ?? 0).toDouble(), Colors.orange),
          _buildMiniBar("CHR", (t['ChrAverage'] ?? 0).toDouble(), Colors.purple),

          SizedBox(height: 10),

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
            child: Text("View Performance"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Employee Performance")),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          sessionDropdown(),
          SizedBox(height: 10),

          departmentDropdown(),
          SizedBox(height: 10),

          courseFilter(),
          SizedBox(height: 10),

          performanceChart(),
          SizedBox(height: 10),

          ...teachers.map((t) => teacherCard(t)).toList(),
        ],
      ),
    );
  }
}
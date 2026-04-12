import 'dart:convert';
import 'package:epams/Director/DetailComparison.dart';
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
  List employeeTypes = [];
  List courses = [];
  List teachers = [];

  int? selectedSession;
  int selectedTab = 0;
  String selectedCourse = "All";

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

  // ================= EMPLOYEE TYPES =================
  Future getEmployeeTypes() async {
    var res = await http.get(Uri.parse("$Url/Performance/GetEmployeeTypes"));
    var data = jsonDecode(res.body);

    setState(() {
      employeeTypes = data;
    });
  }

  // ================= COURSES BY SESSION =================
  Future getCourses(int sessionId) async {
    var res = await http.get(
      Uri.parse("$Url/Performance/GetCoursesBySession?sessionId=$sessionId"),
    );

    var data = jsonDecode(res.body);

    setState(() {
      courses = ["All", ...data];
      selectedCourse = "All";
    });
  }

  // ================= PERFORMANCE =================
  Future getPerformance() async {
    if (selectedSession == null) return;

    var res = await http.get(
      Uri.parse(
        "$Url/Performance/GetTeacherPerformance?sessionId=$selectedSession&courseCode=$selectedCourse",
      ),
    );

    var data = jsonDecode(res.body);

    setState(() {
      teachers = data;
    });
  }

  // ================= SESSION DROPDOWN =================
  Widget sessionDropdown() {
    return DropdownButtonFormField(
      value: selectedSession,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
      ),
      items: sessions.map<DropdownMenuItem>((s) {
        return DropdownMenuItem(
          value: s['id'],
          child: Text(s['name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedSession = value;
        });

        getCourses(selectedSession!);
        getPerformance();
      },
    );
  }

  // ================= EMPLOYEE TYPE TABS =================
  Widget employeeTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(employeeTypes.length, (index) {
          bool active = selectedTab == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(employeeTypes[index]['type']),
              selected: active,
              selectedColor: Colors.green,
              onSelected: (v) {
                setState(() {
                  selectedTab = index;
                });
              },
            ),
          );
        }),
      ),
    );
  }

  // ================= COURSE FILTER =================
  Widget courseFilter() {
    return Wrap(
      spacing: 8,
      children: courses.map((c) {
        bool active = selectedCourse == c;

        return ChoiceChip(
          label: Text(c),
          selected: active,
          selectedColor: Colors.green,
          onSelected: (v) {
            setState(() {
              selectedCourse = c;
            });

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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Teacher Performance Comparison",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Detailcomparison(),
                    ),
                  );
                },
                child: Text("Detail Comparison"),
              ),
            ],
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              series: <CartesianSeries>[
                ColumnSeries<dynamic, String>(
                  dataSource: topTeachers,
                  xValueMapper: (data, _) => data['TeacherName'],
                  yValueMapper: (data, _) => data['Percentage'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= TEACHER CARD =================
  Widget teacherCard(t) {
    double percent = (t['Percentage'] ?? 0).toDouble();

    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t['TeacherName'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "${percent.toStringAsFixed(0)}%",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            t['CourseCode'],
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {},
              child: Text("View Performance"),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F6FA),
      appBar: AppBar(
        title: Text("Employee Performance"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: ListView(
          children: [
            sessionDropdown(),
            SizedBox(height: 12),
            employeeTabs(),
            SizedBox(height: 12),
            Text("Filter by Course:"),
            SizedBox(height: 8),
            courseFilter(),
            SizedBox(height: 16),
            performanceChart(),
            SizedBox(height: 16),
            ...teachers.map((t) => teacherCard(t)).toList(),
          ],
        ),
      ),
    );
  }
}
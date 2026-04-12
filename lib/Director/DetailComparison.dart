import 'dart:convert';
import 'package:epams/Director/CompareResult.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class Detailcomparison extends StatefulWidget {
  const Detailcomparison({super.key});

  @override
  State<Detailcomparison> createState() => _DetailcomparisonState();
}

class _DetailcomparisonState extends State<Detailcomparison> {
  String mode = "course";

  List courses = [];
  List teachers = [];
  List sessions = [];

  String? selectedCourse;
  String? teacherA;
  String? teacherB;
  int? session1;
  int? session2;

  List result = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();
    getSessions();
    changeMode("course");
  }

  // ---------------- API CALLS ----------------

  Future getCourses() async {
    var res = await http.get(Uri.parse("$Url/Performance/GetAllCourses"));

    setState(() {
      courses = jsonDecode(res.body);
      teachers = [];
    });
  }

  Future getSessions() async {
    var res = await http.get(Uri.parse("$Url/Performance/GetSessions"));

    setState(() {
      sessions = jsonDecode(res.body);
    });
  }

  Future getTeachersByCourse(String course) async {
    teacherA = null;
    teacherB = null;

    var res = await http.get(
      Uri.parse("$Url/Performance/GetTeachersByCourse?courseCode=$course"),
    );

    setState(() {
      teachers = jsonDecode(res.body);
    });
  }

  Future getAllTeachers() async {
    var res = await http.get(Uri.parse("$Url/Performance/GetAllTeachers"));

    setState(() {
      teachers = jsonDecode(res.body);
    });
  }

  // ---------------- COMPARE API ----------------

  Future compareTeachers() async {

    if (mode == "course") {
      if (selectedCourse == null || teacherA == null || teacherB == null) {
        showMsg("Please select course and both teachers");
        return;
      }
    }

    if (mode == "session") {
      if (teacherA == null || session1 == null || session2 == null) {
        showMsg("Please select teacher and sessions");
        return;
      }
    }

    setState(() {
      loading = true;
    });

    var body = {
      "mode": mode,
      "courseCode": selectedCourse,
      "teacherA": teacherA,
      "teacherB": teacherB,
      "session1": session1,
      "session2": session2,
    };

    var res = await http.post(
      Uri.parse("$Url/Performance/CompareTeachers"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print(res.body); 

    if (res.statusCode == 200) {

      result = jsonDecode(res.body);

      setState(() {
        loading = false;
      });

      if (result.isEmpty) {
        showMsg("No comparison data found");
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Compareresult(
            result: result,
            mode: mode,
            course: selectedCourse,
            session1: session1,
            session2: session2,
          ),
        ),
      );
    } else {
      setState(() {
        loading = false;
      });

      showMsg("Error loading comparison");
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------- MODE SWITCH ----------------

  void changeMode(String newMode) async {

    setState(() {
      mode = newMode;

      selectedCourse = null;
      teacherA = null;
      teacherB = null;
      session1 = null;
      session2 = null;

      teachers = [];
      courses = [];
      result = [];
    });

    if (mode == "course") {
      await getCourses();
    } else {
      await getAllTeachers();
    }
  }

  // ---------------- CHART ----------------

  Widget buildChart() {

    if (result.isEmpty) return const SizedBox();

    return SizedBox(
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <CartesianSeries>[
          ColumnSeries<dynamic, String>(
            dataSource: result,
            xValueMapper: (data, _) => data["Name"],
            yValueMapper: (data, _) => data["OverallAverageOutOfHundred"],
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Detail Comparison"),
        backgroundColor: Colors.green,
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: ListView(

          children: [

            // -------- MODE SWITCH --------

            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),

              child: Row(
                children: [

                  Expanded(
                    child: GestureDetector(
                      onTap: () => changeMode("course"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: mode == "course"
                              ? Colors.green
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "Compare Teachers",
                            style: TextStyle(
                              color: mode == "course"
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: GestureDetector(
                      onTap: () => changeMode("session"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: mode == "session"
                              ? Colors.green
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "Compare Sessions",
                            style: TextStyle(
                              color: mode == "session"
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // -------- COURSE MODE --------

            if (mode == "course") ...[

              DropdownButtonFormField(
                value: selectedCourse,
                decoration: const InputDecoration(labelText: "Select Course"),
                items: courses.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (v) {

                  setState(() {
                    selectedCourse = v.toString();
                  });

                  getTeachersByCourse(v.toString());
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField(
                value: teacherA,
                decoration: const InputDecoration(labelText: "Teacher A"),
                items: teachers.map((t) {
                  return DropdownMenuItem(
                    value: t["id"],
                    child: Text(t["name"]),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    teacherA = v.toString();
                  });
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField(
                value: teacherB,
                decoration: const InputDecoration(labelText: "Teacher B"),
                items: teachers.map((t) {
                  return DropdownMenuItem(
                    value: t["id"],
                    child: Text(t["name"]),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    teacherB = v.toString();
                  });
                },
              ),
            ],

            // -------- SESSION MODE --------

            if (mode == "session") ...[

              DropdownButtonFormField(
                value: teacherA,
                decoration: const InputDecoration(labelText: "Select Teacher"),
                items: teachers.map((t) {
                  return DropdownMenuItem(
                    value: t["id"],
                    child: Text(t["name"]),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    teacherA = v.toString();
                  });
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField(
                value: session1,
                decoration: const InputDecoration(labelText: "Session 1"),
                items: sessions.map((s) {
                  return DropdownMenuItem(
                    value: s["id"],
                    child: Text(s["name"]),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    session1 = v as int?;
                  });
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField(
                value: session2,
                decoration: const InputDecoration(labelText: "Session 2"),
                items: sessions.map((s) {
                  return DropdownMenuItem(
                    value: s["id"],
                    child: Text(s["name"]),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    session2 = v as int?;
                  });
                },
              ),
            ],

            const SizedBox(height: 25),

            // -------- COMPARE BUTTON --------

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),

              onPressed: loading ? null : compareTeachers,

              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Compare"),
            ),

            const SizedBox(height: 30),

            buildChart(),
          ],
        ),
      ),
    );
  }
}
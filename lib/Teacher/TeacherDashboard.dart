import 'dart:convert';
//import 'package:epams/HOD/ChairpersonQuestionaire.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:epams/Teacher/ClassHeldReport.dart';
import 'package:epams/Teacher/CourseManagmentEvaluation.dart';
import 'package:epams/Teacher/EvaluateSocietyMentors.dart';
import 'package:epams/Teacher/Kpidatamodel.dart';
import 'package:epams/Teacher/PeerEvaluation.dart';
import 'package:epams/Teacher/TeacherSeePerformance.dart';
import 'package:epams/login.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Teacherdashboard extends StatefulWidget {
  final String teacherID;

  const Teacherdashboard({super.key, required this.teacherID});

  @override
  TeacherdashboardState createState() => TeacherdashboardState();
}

class TeacherdashboardState extends State<Teacherdashboard> {
  bool isPeerActive = false;
  bool isChecking = true;
  String teacherName = "";
  int? _evaluatorID;

  @override
  void initState() {
    super.initState();
    fetchTeacherName();
    checkPeerEvaluationStatus();
  }

  Future<void> fetchTeacherName() async {
    try {
      final response = await http.get(
        Uri.parse("$Url/TeacherDashboard/GetTeacherName/${widget.teacherID}"),
      );

      if (response.statusCode == 200) {
        setState(() {
          teacherName = response.body.replaceAll('"', '');
        });
      } else {
        setState(() {
          teacherName = "Teacher";
        });
      }
    } catch (e) {
      setState(() {
        teacherName = "Teacher";
      });
    }
  }

  Future<void> checkPeerEvaluationStatus() async {
    try {
      bool questionnaireActive = false;

      final questionnaireResponse = await http.get(
        Uri.parse("$Url/TeacherDashboard/GetActiveQuestionnaire"),
      );

      if (questionnaireResponse.statusCode == 200) {
        final data = jsonDecode(questionnaireResponse.body);

        if (data["Flag"] == "1" &&
            data["Type"].toString().toLowerCase() == "peer evaluation") {
          questionnaireActive = true;
        }
      }

      final evaluatorResponse = await http.get(
        Uri.parse(
          "$Url/TeacherDashboard/GetPeerEvaluatorID?userId=${widget.teacherID}",
        ),
      );

      if (evaluatorResponse.statusCode == 200) {
        final evalData = jsonDecode(evaluatorResponse.body);
        _evaluatorID = evalData["peerEvaluatorID"];
      }

      setState(() {
        isPeerActive = questionnaireActive && _evaluatorID != null;
        isChecking = false;
      });
    } catch (e) {
      setState(() {
        isPeerActive = false;
        isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacherName.isEmpty
                            ? "Welcome 👏"
                            : "Welcome, $teacherName 👏",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Your performance Overview',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Image.asset('assets/images/logo.jpeg', height: 40),
                ],
              ),

              const SizedBox(height: 15),

              /// PEER EVALUATION BUTTON (FIXED LOGIC ONLY)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: isPeerActive && _evaluatorID != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Peerevaluation(
                              evaluatorID: _evaluatorID!,
                              userId: widget.teacherID,
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text(
                  'Peer Evaluation',
                  style: TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 15),

              Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: Colors.green,
                ),
                child: Center(
                  child: Text(
                    'Monitor your teaching performance and manage course material.',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// KPI SECTION (UNCHANGED)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "KPI Metrics Overview",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 250,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        primaryYAxis: NumericAxis(
                          minimum: 0,
                          maximum: 100,
                          interval: 25,
                        ),
                        series: <CartesianSeries>[
                          ColumnSeries<KpiData, String>(
                            dataSource: [
                              KpiData("Peer", 82),
                              KpiData("Student", 90),
                              KpiData("CHR", 96),
                              KpiData("Society", 78),
                            ],
                            xValueMapper: (KpiData data, _) => data.category,
                            yValueMapper: (KpiData data, _) => data.score,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// QUICK ACTIONS (UNCHANGED FULL)
              buildManageButton(
                icon: Icons.calendar_today,
                label: 'Class Held Report',
                description: 'View your CHR status',
                backgroundColor: Colors.purple,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Classheldreport()),
                  );
                },
              ),

              const SizedBox(height: 15),

              buildManageButton(
                icon: Icons.assignment_turned_in,
                label: 'Course Management Evaluation',
                description: 'View HOD Evaluations',
                backgroundColor: Colors.orange,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Coursemanagmentevaluation(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              buildManageButton(
                icon: Icons.group,
                label: 'Evaluate Society Mentors',
                description: 'Evaluate Your Society Mentors',
                backgroundColor: Colors.teal,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Evaluatesocietymentors(
                        teacherId: widget.teacherID,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              buildManageButton(
                icon: Icons.bar_chart,
                label: 'See Performance',
                description: 'See Your Overall Performance',
                backgroundColor: Colors.green,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Teacherseeperformance(
                        teacherName: teacherName,
                        userId: widget.teacherID,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              /// LOGOUT (UNCHANGED)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Login()),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildManageButton({
  required IconData icon,
  required String label,
  required String description,
  required Color backgroundColor,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.lightGreen.shade200, width: 1.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: backgroundColor.withOpacity(0.15),
            child: Icon(icon, color: backgroundColor, size: 18),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.arrow_forward_ios, size: 14, color: backgroundColor),
        ],
      ),
    ),
  );
}
}
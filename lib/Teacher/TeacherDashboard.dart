import 'dart:convert';
import 'package:epams/Teacher/ClassHeldReport.dart';
import 'package:epams/Teacher/CourseManagmentEvaluation.dart';
import 'package:epams/Teacher/EvaluateSocietyMentors.dart';
import 'package:epams/Teacher/Kpidatamodel.dart';
import 'package:epams/Teacher/PeerEvaluation.dart';
import 'package:epams/Teacher/TeacherSeePerformance.dart';
import 'package:epams/Url.dart';
import 'package:epams/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class Teacherdashboard extends StatefulWidget {
  final String teacherID; // Logged-in teacher ID

  const Teacherdashboard({super.key, required this.teacherID});

  @override
  TeacherdashboardState createState() => TeacherdashboardState();
}

class TeacherdashboardState extends State<Teacherdashboard> {
  bool isPeerActive = false;
  bool isChecking = true;
  String teacherName = "";
  int? _evaluatorID; // fetched evaluator ID

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
      print("Error fetching teacher name: $e");
      setState(() {
        teacherName = "Teacher";
      });
    }
  }

  Future<void> checkPeerEvaluationStatus() async {
    try {
      bool questionnaireActive = false;
      int? evaluatorID;

      // 1️⃣ Check Active Questionnaire
      final questionnaireResponse = await http.get(
        Uri.parse("$Url/TeacherDashboard/GetActiveQuestionnaire"),
      );

      if (questionnaireResponse.statusCode == 200) {
        final data = jsonDecode(questionnaireResponse.body);
        if (data["Flag"] != null &&
            data["Flag"].toString() == "1" &&
            data["Type"] != null &&
            data["Type"].toString().toLowerCase() == "peer evaluation") {
          questionnaireActive = true;
        }
      }

      // 2️⃣ Get Evaluator ID for logged-in teacher
      final evaluatorResponse = await http.get(
        Uri.parse(
            "$Url/TeacherDashboard/GetPeerEvaluatorID?userId=${widget.teacherID}"),
      );

      if (evaluatorResponse.statusCode == 200) {
        final evalData = jsonDecode(evaluatorResponse.body);
        evaluatorID = evalData["peerEvaluatorID"];
      }

      // 3️⃣ Final Condition
      setState(() {
        isPeerActive = questionnaireActive && evaluatorID != null;
        isChecking = false;
        _evaluatorID = evaluatorID;
      });
    } catch (e) {
      setState(() {
        isChecking = false;
        isPeerActive = false;
        _evaluatorID = null;
      });
      print("Error checking peer evaluation status: $e");
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

              /// Peer Evaluation Button
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

              /// KPI Overview
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Your performance across different KPI categories",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    /// Chart
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
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// Overall Score
                    Center(
                      child: Column(
                        children: const [
                          Text(
                            "89%",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            "Overall Performance Score",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text('Quick Actions'),
              const SizedBox(height: 20),

              buildManageButton(
                icon: Icons.calendar_today,
                label: 'Class Held Report',
                description: 'View your CHR status',
                backgroundColor: Colors.purple,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Classheldreport(),
                    ),
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
                      builder: (context) => Coursemanagmentevaluation(),
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
                      builder: (context) => Evaluatesocietymentors(),
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
                      builder: (context) => Teacherseeperformance(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),

              /// Logout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
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
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Colors.lightGreen,
            width: 1.3,
          ),
        ),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: backgroundColor.withOpacity(0.15),
            child: Icon(icon, color: backgroundColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: backgroundColor,
          ),
        ],
      ),
    );
  }
}

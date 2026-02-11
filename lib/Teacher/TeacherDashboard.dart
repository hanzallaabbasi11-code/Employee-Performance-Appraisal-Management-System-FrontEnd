import 'package:epams/Teacher/ClassHeldReport.dart';
import 'package:epams/Teacher/CourseManagmentEvaluation.dart';
import 'package:epams/Teacher/EvaluateSocietyMentors.dart';
import 'package:epams/Teacher/Kpidatamodel.dart';
import 'package:epams/Teacher/TeacherSeePerformance.dart';
import 'package:epams/login.dart';
import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Teacherdashboard extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  Teacherdashboard({Key? key}) : super(key: key);

  @override
  TeacherdashboardState createState() => TeacherdashboardState();
}

class TeacherdashboardState extends State<Teacherdashboard> {
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
                      const Text(
                        'Welcome,Mr.Muhammad Ahsan 👏',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        'Your performnace Overview',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Image.asset('assets/images/logo.jpeg', height: 40),
                ],
              ),

              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {},
                child: Text('Peer Evaluation', style: TextStyle(fontSize: 18)),
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
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "KPI Metrics Overview",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Your performance across different KPI categories",
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 20),

                    /// 🔹 Chart
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
                              //KpiData("Coordination", 95),
                              KpiData("CHR", 96),
                              KpiData("Society", 78),
                             // KpiData("Admin", 88),
                            ],
                            xValueMapper: (KpiData data, _) => data.category,
                            yValueMapper: (KpiData data, _) => data.score,
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    /// 🔹 Overall Score
                    Center(
                      child: Column(
                        children: [
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

               SizedBox(height: 20),
               Text('Quick Actions'),

               SizedBox(height: 20),

                buildManageButton(
                    icon: Icons.calendar_today,
                    label: 'Class Held Report',
                    description: 'View your CHR status',
                    backgroundColor: Colors.purple,
                    onPressed: () {
                         Navigator.push(
                            context,
                          MaterialPageRoute(
                     builder: (context) => Classheldreport(), // your target screen
                         ),
                      );
                    },
                  ),

                  SizedBox(height: 15),

                  buildManageButton(
                    icon: Icons.assignment_turned_in,
                    label: 'Course Management Evaluation',
                    description: 'View HOD Evaluations',
                    backgroundColor: Colors.orange,
                    onPressed: () {
                         Navigator.push(
                            context,
                          MaterialPageRoute(
                     builder: (context) => Coursemanagmentevaluation(), // your target screen
                         ),
                      );
                    },
                  ),
                    SizedBox(height: 15),
                  buildManageButton(
                    icon: Icons.group,
                    label: 'Evaluate Society Mentors',
                    description: 'Evaluate Your Society Mentors',
                    backgroundColor: Colors.teal,
                    onPressed: () {
                         Navigator.push(
                            context,
                          MaterialPageRoute(
                     builder: (context) => Evaluatesocietymentors(), // your target screen
                         ),
                      );
                    },
                  ),
                    SizedBox(height: 15),
                   buildManageButton(
                    icon: Icons.bar_chart,
                    label: 'See Performance',
                    description: 'See Your Overall Performance',
                    backgroundColor: Colors.green,
                    onPressed: () {
                         Navigator.push(
                            context,
                          MaterialPageRoute(
                     builder: (context) => Teacherseeperformance(), // your target screen
                         ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),
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
    required Color backgroundColor, // used ONLY for icon color
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // ✅ card-like white
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Colors.lightGreen,
            width: 1.3,
          ), // ✅ green border
        ),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: backgroundColor.withOpacity(0.15), // soft color bg
            child: Icon(icon, color: backgroundColor), // ✅ original icon color
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
            color: backgroundColor, // ✅ arrow matches icon color
          ),
        ],
      ),
    );
  }
}

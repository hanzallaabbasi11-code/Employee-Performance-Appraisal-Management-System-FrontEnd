import 'package:epams/AddPeerEvaluatorScreen.dart';
import 'package:epams/CHRPointsSettingScreen.dart';
import 'package:epams/CourseManagementScreen.dart';
import 'package:epams/SeePerformanceScreen.dart';
//import 'package:epams/SeePerformanceScreen.dart';
import 'package:flutter/material.dart';
import 'package:epams/AddKpiScreen.dart';

class HodDashboard extends StatefulWidget {
  const HodDashboard({super.key});

  @override
  State<HodDashboard> createState() => _HodState();
}

class _HodState extends State<HodDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HOD: Dr. Munir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Head of Department',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Image.asset(
                    'assets/images/logo.jpeg',
                    height: 40, // adjust size as needed
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Green card: Monitor teacher performance
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF0A8F3C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Monitor teacher performance, manage KPIs, and assign peer evaluators.',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[800],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Fall 2025',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Cards row (Total Teachers & Top Performer)
              Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      child: SizedBox(
                        height: 180, // Fixed height, adjust as needed
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment
                                .center, // center content vertically
                            children: [
                              Icon(Icons.group, size: 40, color: Colors.green),
                              const SizedBox(height: 8),
                              Text(
                                'Total Teachers',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '6 Active faculty',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      child: SizedBox(
                        height: 180, // same height here
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star, size: 40, color: Colors.amber),
                              const SizedBox(height: 8),
                              Text(
                                'Top Performer',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Mr. Muhammad Zahid\n93% rating',
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Manage section heading
              Text(
                'Manage',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // Buttons list
              Column(
                children: [
                  buildManageButton(
                    icon: Icons.add,
                    label: 'Add KPI',
                    description: 'Define new performance indicators',
                    backgroundColor: Colors.green,
                    onPressed: () {
                         Navigator.push(
                            context,
                          MaterialPageRoute(
                     builder: (context) => AddKpiScreen(), // your target screen
                         ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  buildManageButton(
                    icon: Icons.person_add,
                    label: 'Add Peer Evaluator',
                    description: 'Assign evaluators to teachers',
                    backgroundColor: Colors.blue,
                    onPressed: () {
                       Navigator.push(
                            context,
                          MaterialPageRoute(
                     builder: (context) => AddPeerEvaluatorScreen(), // your target screen
                         ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  buildManageButton(
                    icon: Icons.book,
                    label: 'Course Management',
                    description: 'Evaluate course submissions',
                    backgroundColor: Colors.purple,
                    onPressed: () {
                      Navigator.push(
                            context,
                          MaterialPageRoute(
                     builder: (context) => Coursemanagementscreen(), // your target screen
                         ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  buildManageButton(
                    icon: Icons.analytics,
                    label: 'See Performance',
                    description: 'View detailed analytics',
                    backgroundColor: Colors.orange,
                    onPressed: () {
                       Navigator.push(
                            context,
                          MaterialPageRoute(
                     builder: (context) => SeePerformanceScreen(), // your target screen
                         ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  buildManageButton(
                    icon: Icons.settings,
                    label: 'CHR Points Settings',
                    description: 'Configure CHR scoring rules',
                    backgroundColor: Colors.lightGreen,
                    onPressed: () {
                       Navigator.push(
                            context,
                          MaterialPageRoute(
                     builder: (context) => Chrpointssettingscreen(), // your target screen
                         ),
                      );
                    },
                  ),
                ],
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

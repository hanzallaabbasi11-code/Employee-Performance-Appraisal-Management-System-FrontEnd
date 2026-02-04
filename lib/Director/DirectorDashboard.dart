import 'package:epams/Director/AddKPI.dart';
import 'package:epams/Director/AddPeerEvaluators.dart';
import 'package:epams/Director/ConfidentialEvaluation.dart';
import 'package:epams/Director/MakeQuestioner.dart';
import 'package:epams/Director/SeePerformance.dart';
import 'package:epams/login.dart';
import 'package:flutter/material.dart';

class Directordashboard extends StatefulWidget {
  const Directordashboard({super.key});

  @override
  State<Directordashboard> createState() => _DirectordashboardState();
}

class _DirectordashboardState extends State<Directordashboard> {
  Widget dashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FFFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            /// Icon Container
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1BAA5D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),

            const SizedBox(width: 12),

            /// Text Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            /// Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.green.shade600,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dr. Jamil Sarwar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Director of University',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Image.asset('assets/images/logo.jpeg', height: 40),
                ],
              ),

              const SizedBox(height: 20),

              /// Title
              Column(
                children: const [
                  Text(
                    'Director Dashboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage and monitor university performance',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              /// Cards Grid (FIXED SIZE)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: dashboardCard(
                      icon: Icons.assignment,
                      title: 'Make Questionnaire',
                      subtitle: 'Create evaluation forms for all departments',
                      onTap: () {
                         Navigator.push(
                            context,
                          MaterialPageRoute(
                     builder: (context) => const Makequestioner(), // your target screen
                         ),
                      );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: dashboardCard(
                      icon: Icons.bar_chart,
                      title: 'See Performance',
                      subtitle:
                          'View employee performance analytics and reports',
                      onTap: () {

                        Navigator.push(
                            context,
                          MaterialPageRoute(
                     builder: (context) => const Seeperformance() , // your target screen
                         ),
                      );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: dashboardCard(
                      icon: Icons.add_chart,
                      title: 'Add KPI',
                      subtitle:
                          'Manage key performance indicators for employees',
                      onTap: () {
                         Navigator.push(
                            context,
                          MaterialPageRoute(
                     builder: (context) => const Addkpi(), // your target screen
                         ),
                      );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: dashboardCard(
                      icon: Icons.verified_user,
                      title: 'Confidential Evaluation',
                      subtitle:
                          'Access and review confidential evaluation results',
                      onTap: () {

                         Navigator.push(
                            context,
                          MaterialPageRoute(
                     builder: (context) => const Confidentialevaluation(), // your target screen
                         ),
                      );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: dashboardCard(
                      icon: Icons.people,
                      title: 'Add Peer Evaluators',
                      subtitle: 'Assign Evaluators to teachers',
                      onTap: () {
                         Navigator.push(
                            context,
                          MaterialPageRoute(
                     builder: (context) => const Addpeerevaluators(), // your target screen
                         ),
                      );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Logout Button
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
}

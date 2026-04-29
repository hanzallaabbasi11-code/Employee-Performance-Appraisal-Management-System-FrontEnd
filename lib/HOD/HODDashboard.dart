import 'package:epams/HOD/AddPeerEvaluatorScreen.dart';
import 'package:epams/HOD/CHRPointsSettingScreen.dart';
import 'package:epams/HOD/CourseManagementScreen.dart';
import 'package:epams/HOD/EvaluateSocietyChairpersons.dart';
import 'package:epams/HOD/SeePerformanceScreen.dart';
import 'package:epams/HOD/SocietyDashboard.dart';
import 'package:epams/login.dart';
import 'package:flutter/material.dart';
import 'package:epams/HOD/AddKpiScreen.dart';

class HodDashboard extends StatefulWidget {
  final String hodId; // ✅ logged in HOD id

  const HodDashboard({super.key, required this.hodId});

  @override
  State<HodDashboard> createState() => _HodState();
}

class _HodState extends State<HodDashboard> {
  @override
  Widget build(BuildContext context) {
    String hodId = widget.hodId; // ✅ use passed id

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
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HOD Dashboard',
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
                  Image.asset('assets/images/logo.jpeg', height: 40),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                'Manage',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              buildManageButton(
                icon: Icons.add,
                label: 'Add KPI',
                description: 'Define new performance indicators',
                backgroundColor: Colors.green,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddKpiScreen()),
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
                      builder: (context) => AddPeerEvaluatorScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // ✅ PASS HOD ID HERE
              buildManageButton(
                icon: Icons.book,
                label: 'Course Management',
                description: 'Evaluate course submissions',
                backgroundColor: Colors.purple,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Coursemanagementscreen(hodId: hodId),
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
                      builder: (context) => SeePerformanceScreen(),
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
                      builder: (context) => Chrpointssettingscreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              buildManageButton(
                icon: Icons.group,
                label: 'Society Management',
                description: 'SMO Administration',
                backgroundColor: Colors.lightGreen,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Societydashboard()),
                  );
                },
              ),

              const SizedBox(height: 12),

              buildManageButton(
                icon: Icons.group,
                label: 'Evaluate Society Chairperson',
                description:
                    "Evaluate the chairperson's leadership and management of the society ",
                backgroundColor: Colors.lightGreen,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Evaluatesocietychairpersons(teacherId: hodId),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
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
          side: BorderSide(color: Colors.lightGreen, width: 1.3),
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(description, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: backgroundColor),
        ],
      ),
    );
  }
}

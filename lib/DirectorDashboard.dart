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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF1BAA5D),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
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
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.92, // 🔥 KEY FIX
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  dashboardCard(
                    icon: Icons.assignment,
                    title: 'Make Questionnaire',
                    subtitle: 'Create evaluation forms for all departments',
                    onTap: () {},
                  ),
                  dashboardCard(
                    icon: Icons.bar_chart,
                    title: 'See Performance',
                    subtitle: 'View employee performance analytics and reports',
                    onTap: () {},
                  ),
                  dashboardCard(
                    icon: Icons.add_chart,
                    title: 'Add KPI',
                    subtitle: 'Manage key performance indicators for employees',
                    onTap: () {},
                  ),
                  dashboardCard(
                    icon: Icons.verified_user,
                    title: 'Confidential Evaluation',
                    subtitle:
                        'Access and review confidential evaluation results',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Login(),
                      ),
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

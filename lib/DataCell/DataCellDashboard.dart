import 'package:epams/DataCell/UploadCoursesScreen.dart';
import 'package:epams/DataCell/UploadStudentsScreen.dart';
import 'package:epams/DataCell/UploadTeachersScreen.dart';
import 'package:epams/DataCell/UploadEnrollmentScreen.dart';
import 'package:epams/login.dart';
import 'package:flutter/material.dart';

class DataCellDashboard extends StatelessWidget {
  const DataCellDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Data Cell Dashboard",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Manage institutional data uploads efficiently",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFE8F8EE),
                    backgroundImage: const AssetImage(
                      'assets/images/logo.jpeg',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// Cards
              dashboardCard(
                context,
                icon: Icons.description,
                title: "Upload CHR Report",
                subtitle: "Upload and manage daily Class Held Reports (CHR)",
                onTap: () {},
              ),

              dashboardCard(
                context,
                icon: Icons.school,
                title: "Upload Students",
                subtitle: "Upload students list using Excel file",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UploadStudentsScreen()),
                  );
                },
              ),

              dashboardCard(
                context,
                icon: Icons.person,
                title: "Upload Teachers",
                subtitle: "Upload teachers list using Excel file",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UploadTeachersScreen()),
                  );
                },
              ),

              dashboardCard(
                context,
                icon: Icons.menu_book,
                title: "Upload Courses",
                subtitle: "Upload course and subject information",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UploadCoursesScreen()),
                  );
                },
              ),

               dashboardCard(
                context,
                icon: Icons.book,
                title: "Upload Enrollment",
                subtitle: "Upload Enrollments",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UploadEnrollmentScreen()),
                  );
                },
              ),


              const Spacer(),

              /// Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // exit(0);
                     Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Logout", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable clickable card
  Widget dashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.green.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

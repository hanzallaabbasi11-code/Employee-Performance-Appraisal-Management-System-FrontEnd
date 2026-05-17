// ignore_for_file: file_names, deprecated_member_use, avoid_print

import 'package:epams/HOD/AddPeerEvaluatorScreen.dart';
import 'package:epams/HOD/CHR%20Report/CHRReport.dart';
import 'package:epams/HOD/CourseManagement/CourseManagementScreen.dart';
import 'package:epams/HOD/EvaluateSocietyChairperson/EvaluateSocietyChairpersons.dart';
import 'package:epams/HOD/SeePerformance/SeePerformanceScreen.dart';
import 'package:epams/HOD/SocietyManagement/SocietyDashboard.dart';
import 'package:epams/login.dart';
import 'package:flutter/material.dart';
import 'package:epams/HOD/AddKpi/AddKpiScreen.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:epams/Url.dart';

class HodDashboard extends StatefulWidget {
  final String hodId; // ✅ logged in HOD id

  const HodDashboard({super.key, required this.hodId});

  @override
  State<HodDashboard> createState() => _HodState();

  
}

class _HodState extends State<HodDashboard> {
  @override
    @override
  void initState() {
    super.initState();

    getTeachersCount();
    getTopPerformer();
  }

  int totalTeachers=0;
  String topPerformerName = "Loading...";
  double topPerformerPercentage = 0;

  Future<void> getTeachersCount() async{

  try{
     int sessionId=3;

     final response= await http.get(Uri.parse('$Url/Performer/GetTeachersCount?sessionId=$sessionId',));

     print("Teachers Count Response: ${response.body}");

     if(response.statusCode==200){
      final data = jsonDecode(response.body);

      setState(() {
        totalTeachers = data['TotalTeachers'];
      });

     }


  }catch(e)
  {

   print("Teachers Count Error: $e");
  }     
  }

  Future<void> getTopPerformer() async {
  try {

    int sessionId = 3;

    final response = await http.get(
      Uri.parse(
        '$Url/Performer/GetBestPerformerTeacher?sessionId=$sessionId',
      ),
    );

    print("Top Performer Response: ${response.body}");

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      setState(() {

        topPerformerName =
            data['TeacherName'] ?? "N/A";

        topPerformerPercentage =
            (data['Percentage'] ?? 0).toDouble();

      });

    }

  } catch (e) {

    print("Top Performer Error: $e");

  }
}


//   Widget studentCard(
//   String name,
//   String department,
// ) {
//   return Card(
//     child: ListTile(
//       title: Text(name),
//       subtitle: Text(department),
//     ),
//   );
// }


Widget buildTopCard({
  required String title,
  required String value,
  required String subtitle,
  required IconData icon,
  required Color iconColor,
}) {

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),

    child: Column(
      children: [

        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 16),

        Icon(
          icon,
          size: 40,
          color: iconColor,
        ),

        const SizedBox(height: 16),

        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

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

              Row(
  children: [

    Expanded(
      child: buildTopCard(
        title: "Total Teachers",
        value: totalTeachers.toString(),
        subtitle: "Active Faculty",
        icon: Icons.groups,
        iconColor: Colors.blue,
      ),
    ),

    const SizedBox(width: 12),

    Expanded(
      child: buildTopCard(
        title: "Top Performer",
        value: topPerformerName,
        subtitle:
            "${topPerformerPercentage.toStringAsFixed(1)}% Rating",
        icon: Icons.workspace_premium,
        iconColor: Colors.orange,
      ),
    ),

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
                label: 'CHR Report',
                description: 'Check the CHR Report',
                backgroundColor: Colors.lightGreen,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Chrreport(),
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

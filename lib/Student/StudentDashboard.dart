import 'package:flutter/material.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  //bool canEvaluate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: AssetImage(
                        'assets/images/student_image.jpeg',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Hanzalla Abbasi\n22-Arid-4088',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                      ),
                      onPressed: () {
                        setState(() {
                          //canEvaluate = true;
                        });
                      },
                      child: Text(
                        'Confidential Evaluation',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF0A8F3C),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  'Teacher Evaluation',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Review and evaluate your courses for the current semester',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F9EF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Color(0xFF0A8F3C)),
                      SizedBox(width: 8),
                      Text(
                        'Evaluation will be enabled soon',
                        style: TextStyle(color: Color(0xFF0A8F3C)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CS-301                                                    Fall 2025',
                      ),
                      Text('Database System'),
                      Text('Mr.Ali Khan'),

                      SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.green, // sets button background color
                            foregroundColor:
                                Colors.white, // sets text and icon color
                          ),
                          onPressed: () {},
                          child: Text(
                            'Evaluate',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CS-302                                                    Fall 2025',
                      ),
                      Text('Software Engineering'),
                      Text('Dr.Fatima Noor'),

                      SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.green, // sets button background color
                            foregroundColor:
                                Colors.white, // sets text and icon color
                          ),
                          onPressed: () {},
                          child: Text('Evaluate'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CS-303                                                    Fall 2025',
                      ),
                      Text('Leaner Algebra'),
                      Text('Mr.Shahid Raheed'),

                      SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.green, // sets button background color
                            foregroundColor:
                                Colors.white, // sets text and icon color
                          ),
                          onPressed: () {},
                          child: Text('Evaluate'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

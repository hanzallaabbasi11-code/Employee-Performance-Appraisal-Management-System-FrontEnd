import 'package:flutter/material.dart';

class Coursemanagmentevaluation extends StatefulWidget {
  const Coursemanagmentevaluation({super.key});

  @override
  State<Coursemanagmentevaluation> createState() =>
      _CoursemanagmentevaluationState();
}

class _CoursemanagmentevaluationState extends State<Coursemanagmentevaluation> {
  String selectedSession = "Fall 2025";
  String selectedCourse = "All Courses";

  // ================= DYNAMIC DATA LIST =================
  List<Map<String, dynamic>> courses = [
    {
      "title": "Database Systems",
      "code": "CS-301",
      "session": "Fall 2025",
      "paperStatus": "On Time",
      "folderStatus": "On Time",
      "score": 8.7,
      "remarks":
          "Excellent course organization and timely submissions. Course material is comprehensive and well-structured.",
      "evaluatedBy": "Dr. Munir",
      "date": "Nov 20, 2025",
    },
    {
      "title": "Operating Systems",
      "code": "CS-302",
      "session": "Fall 2025",
      "paperStatus": "Late",
      "folderStatus": "On Time",
      "score": 7.5,
      "remarks": "Needs improvement in assignment submissions and material clarity.",
      "evaluatedBy": "Dr. Ahmed",
      "date": "Nov 21, 2025",
    },
    // Add more courses here easily
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Course Management Evaluation",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "View the evaluation given by HOD for each of your courses",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Image.asset('assets/images/logo.jpeg', height: 40),
                ],
              ),
            ),

            const Divider(height: 1),

            // ================= FILTER SECTION =================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(Icons.filter_list, size: 18, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "Filters",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedSession,
                          items: ["Fall 2025", "Spring 2025"]
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(
                                    e,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedSession = val!;
                            });
                          },
                          decoration: _compactInputDecoration("Session"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedCourse,
                          items: ["All Courses", "Database Systems"]
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(
                                    e,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedCourse = val!;
                            });
                          },
                          decoration: _compactInputDecoration("Course"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ================= EVALUATION CARDS =================
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  return _evaluationCard(courses[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget _evaluationCard(Map<String, dynamic> course) {
    double progress = (course['score'] as double) / 10;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Title
          Row(
            children: [
              const Icon(Icons.menu_book, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                course['title'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              _tag(course['code'], Colors.green.shade100),
              const SizedBox(width: 6),
              _tag(course['session'], Colors.blue.shade100),
            ],
          ),

          const SizedBox(height: 16),

          // Submission Status
          _statusRow("Paper Submission", course['paperStatus']),
          _statusRow("Course Folder Submission", course['folderStatus']),

          const SizedBox(height: 16),

          // Score
          const Text(
            "Course Quality Score",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              Text(
                "${course['score']} / 10",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),

          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            color: Colors.green,
          ),

          const SizedBox(height: 16),

          // Remarks
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.verified, color: Colors.green, size: 18),
                    SizedBox(width: 6),
                    Text(
                      "HOD Remarks",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  course['remarks'],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Evaluated by: ${course['evaluatedBy']}",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                course['date'],
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= HELPER WIDGETS =================
  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11)),
    );
  }

  Widget _statusRow(String title, String status) {
    Color color = status == "On Time" ? Colors.green : Colors.red;
    IconData icon = status == "On Time" ? Icons.check_circle : Icons.error;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 4),
              Text(status, style: TextStyle(color: color)),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _compactInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true, // important
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFF1F4F3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}

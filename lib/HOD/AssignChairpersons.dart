import 'dart:convert';
import 'package:epams/Session.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Assignchairpersons extends StatefulWidget {
  final Session session;

  const Assignchairpersons({super.key, required this.session});

  @override
  State<Assignchairpersons> createState() => _AssignchairpersonsState();
}

class _AssignchairpersonsState extends State<Assignchairpersons> {
  List societies = [];
  List teachers = [];

  Map? selectedSociety;
  String? selectedTeacherId;

  Map? currentChairperson;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// =============================
  /// LOAD SOCIETIES + TEACHERS
  /// =============================
  Future<void> loadData() async {
    setState(() {
      loading = true;
    });

    /// UPDATED ENDPOINT
    final societyRes = await http.get(
      Uri.parse("$Url/CourseManagement/GetAll"),
    );

    final teacherRes = await http.get(
      Uri.parse("$Url/CourseManagement/GetTeachers"),
    );

    if (societyRes.statusCode == 200 && teacherRes.statusCode == 200) {
      setState(() {
        societies = json.decode(societyRes.body);
        teachers = json.decode(teacherRes.body);
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  /// =============================
  /// LOAD CURRENT CHAIRPERSON
  /// =============================
  Future<void> loadCurrentChairperson() async {
    if (selectedSociety == null) return;

    final response = await http.get(
      Uri.parse(
        "$Url/CourseManagement/GetChairpersons/${selectedSociety!["SocietyId"]}/${widget.session.id}",
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        currentChairperson = data;
      });
    }
  }

  /// =============================
  /// ASSIGN CHAIRPERSON
  /// =============================
  Future<void> assignChairperson() async {
    if (selectedSociety == null || selectedTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select society and teacher")),
      );

      return;
    }

    final response = await http.post(
      Uri.parse("$Url/CourseManagement/AssignTeacher"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "TeacherId": selectedTeacherId,
        "SocietyId": selectedSociety!["SocietyId"],
        "SessionId": widget.session.id,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chairperson assigned successfully")),
      );

      setState(() {
        selectedTeacherId = null;
      });

      loadCurrentChairperson();
    }
  }

  /// =============================
  /// UI
  /// =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f5),

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Assign Chairperson"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// SESSION BAR
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  color: Colors.green.shade400,
                  child: Row(
                    children: [
                      const Text(
                        "Session:",
                        style: TextStyle(color: Colors.white),
                      ),

                      const SizedBox(width: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.session.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// SELECT SOCIETY
                        const Text(
                          "Select Society",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButton<Map>(
                            value: selectedSociety,
                            hint: const Text("Choose Society"),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: societies.map((s) {
                              return DropdownMenuItem<Map>(
                                value: s,
                                child: Text(s["SocietyName"]),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSociety = value;
                              });

                              loadCurrentChairperson();
                            },
                          ),
                        ),

                        const SizedBox(height: 15),

                        /// CURRENT CHAIRPERSON CARD
                        if (currentChairperson != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green, width: 2),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.green),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Current Chairperson",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      currentChairperson?["TeacherName"] ??
                                          "Not Assigned",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        /// SELECT TEACHER
                        const Text(
                          "Select Teacher",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 10),

                        Expanded(
                          child: ListView.builder(
                            itemCount: teachers.length,
                            itemBuilder: (context, index) {
                              final teacher = teachers[index];

                              return Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: RadioListTile<String>(
                                  value: teacher["userID"].toString(),
                                  groupValue: selectedTeacherId,
                                  title: Text(teacher["name"]),
                                  activeColor: Colors.green,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedTeacherId = val;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),

                        /// ASSIGN BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.all(14),
                            ),
                            onPressed: assignChairperson,
                            child: const Text("Assign Chairperson"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
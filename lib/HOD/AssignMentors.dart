import 'dart:convert';
import 'package:epams/Session.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Assignmentors extends StatefulWidget {
  final Session session;

  const Assignmentors({super.key, required this.session});

  @override
  State<Assignmentors> createState() => _AssignmentorsState();
}

class _AssignmentorsState extends State<Assignmentors> {

  List<dynamic> societies = [];
  List<dynamic> teachers = [];
  List<dynamic> filteredTeachers = [];

  Map<String, dynamic>? selectedSociety;

  Set<String> selectedTeachers = {};

  final TextEditingController searchController = TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// =============================
  /// LOAD DATA
  /// =============================
  Future<void> loadData() async {

    setState(() {
      loading = true;
    });

    final societyRes = await http.get(
        Uri.parse("$Url/CourseManagement/GetAll")
    );

    final teacherRes = await http.get(
        Uri.parse("$Url/CourseManagement/GetTeachers")
    );

    if (societyRes.statusCode == 200 && teacherRes.statusCode == 200) {

      societies = json.decode(societyRes.body);
      teachers = json.decode(teacherRes.body);

      filteredTeachers = teachers;

      setState(() {
        loading = false;
      });

    } else {

      setState(() {
        loading = false;
      });

    }
  }

  /// =============================
  /// SEARCH TEACHER
  /// =============================
  void searchTeacher(String value) {

    value = value.toLowerCase();

    setState(() {

      filteredTeachers = teachers.where((t) {

        return (t["name"] ?? "")
            .toString()
            .toLowerCase()
            .contains(value);

      }).toList();

    });
  }

  /// =============================
  /// ASSIGN MENTORS
  /// =============================
  Future<void> assignMentors() async {

    if (selectedSociety == null || selectedTeachers.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select society and mentors"))
      );

      return;
    }

    List data = selectedTeachers.map((teacherId) {

      return {
        "TeacherId": teacherId,
        "SocietyId": selectedSociety!["SocietyId"],
        "SessionId": widget.session.id,
        "IsChairperson": false,
        "IsMentor": true
      };

    }).toList();

    final response = await http.post(

      Uri.parse("$Url/CourseManagement/AssignMentorsBulk"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mentors assigned successfully"))
      );

      setState(() {
        selectedTeachers.clear();
      });

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
        title: const Text("Assign Mentors"),
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
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    widget.session.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  /// SELECT SOCIETY
                  const Text("Select Society"),

                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300)
                    ),

                    child: DropdownButton<Map<String,dynamic>>(

                      value: selectedSociety,

                      hint: const Text("Choose Society"),

                      isExpanded: true,

                      underline: const SizedBox(),

                      items: societies.map((s) {

                        return DropdownMenuItem<Map<String,dynamic>>(
                          value: s,
                          child: Text(s["SocietyName"] ?? ""),
                        );

                      }).toList(),

                      onChanged: (value) {

                        setState(() {
                          selectedSociety = value;
                        });

                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// SEARCH
                  TextField(
                    controller: searchController,
                    onChanged: searchTeacher,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search teacher",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// SELECTED COUNT
                  Text("Selected: ${selectedTeachers.length}"),

                  const SizedBox(height: 10),

                  /// TEACHERS LIST
                  Expanded(
                    child: ListView.builder(

                      itemCount: filteredTeachers.length,

                      itemBuilder: (context, index) {

                        final teacher = filteredTeachers[index];

                        bool selected =
                        selectedTeachers.contains(
                            teacher["userID"].toString());

                        return Container(

                          margin: const EdgeInsets.only(bottom: 8),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? Colors.green
                                  : Colors.grey.shade300,
                              width: selected ? 2 : 1,
                            ),
                          ),

                          child: CheckboxListTile(

                            title: Text(teacher["name"] ?? ""),

                            value: selected,

                            activeColor: Colors.green,

                            onChanged: (val) {

                              setState(() {

                                if (selected) {
                                  selectedTeachers
                                      .remove(teacher["userID"].toString());
                                } else {
                                  selectedTeachers
                                      .add(teacher["userID"].toString());
                                }

                              });

                            },
                          ),
                        );
                      },
                    ),
                  ),

                  /// SAVE BUTTON
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(14),
                      ),

                      onPressed: assignMentors,

                      child: const Text("Save Mentors"),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
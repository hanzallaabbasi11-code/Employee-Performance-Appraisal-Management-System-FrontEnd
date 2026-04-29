import 'dart:convert';
import 'package:epams/HOD/ChairpersonQuestionaire.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Evaluatesocietychairpersons extends StatefulWidget {
  final String teacherId; // ⭐ logged in user id

  const Evaluatesocietychairpersons({super.key, required this.teacherId});

  @override
  State<Evaluatesocietychairpersons> createState() =>
      _EvaluatesocietychairpersonsState();
}

class _EvaluatesocietychairpersonsState
    extends State<Evaluatesocietychairpersons> {
  List sessions = [];
  List chairpersons = [];

  int? selectedSessionId;

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  // ================= LOAD SESSIONS =================

  Future<void> loadSessions() async {
    final response = await http.get(
      Uri.parse("$Url/SocietyEvaluation/Sessions"),
    );

    if (response.statusCode == 200) {
      setState(() {
        sessions = jsonDecode(response.body);
      });
    }
  }

  // ================= LOAD CHAIRPERSON =================

  Future<void> loadChairpersons(int sessionId) async {
    final response = await http.get(
      Uri.parse("$Url/SocietyEvaluation/GetChairpersons/$sessionId"),
    );

    if (response.statusCode == 200) {
      setState(() {
        chairpersons = jsonDecode(response.body);
      });
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Evaluate Society Chairperson")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= TOP CARD =================
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.groups, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Evaluate Society Chairperson",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Evaluate the chairperson's leadership and management of the society.",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= SESSION DROPDOWN =================
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text("Select Session"),
                  value: selectedSessionId,
                  underline: const SizedBox(),
                  items: sessions.map<DropdownMenuItem<int>>((s) {
                    return DropdownMenuItem(
                      value: s['id'],
                      child: Text(s['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSessionId = value;
                    });

                    loadChairpersons(value!);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= INFO BOX =================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(10),
                color: Colors.green.withOpacity(0.1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Chairperson evaluations help improve society performance.",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= CHAIRPERSON LIST =================
            Expanded(
              child: chairpersons.isEmpty
                  ? const Center(child: Text("No chairperson found"))
                  : ListView.builder(
                      itemCount: chairpersons.length,
                      itemBuilder: (context, index) {
                        var chair = chairpersons[index];

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green,
                              child: const Icon(
                                Icons.groups,
                                color: Colors.white,
                              ),
                            ),
                            title: Text("Mr ${chair['TeacherName']}"),
                            subtitle: Text(chair['SocietyName']),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () async {
                                bool? isSubmitted = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChairpersonQuestionnaire(
                                          chairData: chair,
                                          sessionId: selectedSessionId!,
                                          evaluatorId:
                                              widget.teacherId, // ⭐ Correct ID
                                        ),
                                  ),
                                );

                                if (isSubmitted == true) {
                                  loadChairpersons(selectedSessionId!);
                                }
                              },
                              child: const Text(
                                "Evaluate",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

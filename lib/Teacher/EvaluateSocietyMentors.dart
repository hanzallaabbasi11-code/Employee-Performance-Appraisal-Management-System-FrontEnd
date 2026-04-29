import 'dart:convert';
import 'package:epams/Teacher/EvaluateMentors.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Evaluatesocietymentors extends StatefulWidget {
  final String teacherId;

  const Evaluatesocietymentors({super.key, required this.teacherId});

  @override
  State<Evaluatesocietymentors> createState() => _EvaluatesocietymentorsState();
}

class _EvaluatesocietymentorsState extends State<Evaluatesocietymentors> {
  List sessions = [];
  List mentors = [];

  String societyName = "";
  int? selectedSessionId;

  bool isChairperson = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  // ================= GET SESSIONS =================

  Future fetchSessions() async {
    final response = await http.get(
      Uri.parse("$Url/SocietyEvaluation/Sessions"),
    );

    if (response.statusCode == 200) {
      sessions = jsonDecode(response.body);

      setState(() {
        if (sessions.isNotEmpty) {
          selectedSessionId = sessions.first['id'];
        }
      });

      fetchMentors();
    } else {
      setState(() => loading = false);
    }
  }

  // ================= GET MENTORS =================

  Future fetchMentors() async {
    if (selectedSessionId == null) return;

    setState(() {
      loading = true;
    });

    final response = await http.get(
      Uri.parse(
        "$Url/SocietyEvaluation/GetChairpersonSocietyWithMentors/${widget.teacherId}/$selectedSessionId",
      ),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      setState(() {
        isChairperson = data["IsChairperson"] ?? false;
        loading = false;

        if (isChairperson) {
          societyName = data["SocietyName"] ?? "";
          mentors = data["Mentors"] ?? [];
        } else {
          societyName = "";
          mentors = [];
        }
      });
    } else {
      setState(() {
        loading = false;
        isChairperson = false;
      });
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F0),
      body: SafeArea(
        child: Column(
          children: [

            // ===== HEADER =====

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
                          "Evaluate Society Mentors",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          "Evaluate the mentors of your society based on their performance.",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Image.asset("assets/images/logo.jpeg", height: 40),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ===== SESSION DROPDOWN =====

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    value: selectedSessionId,
                    isExpanded: true,
                    items: sessions.map<DropdownMenuItem>((s) {
                      return DropdownMenuItem(
                        value: s['id'],
                        child: Text(s['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSessionId = value as int;
                      });
                      fetchMentors();
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ===== SOCIETY INFO BAR =====

            if (isChairperson)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.teal,
                ),
                child: Center(
                  child: Text(
                    "$societyName - Select a mentor to evaluate.",
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // ===== LIST =====

            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : !isChairperson
                      ? const Center(
                          child: Text("You are not chairperson of any society"),
                        )
                      : ListView.builder(
                          itemCount: mentors.length,
                          itemBuilder: (context, index) {
                            var mentor = mentors[index];

                            return mentorCard(mentor);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= MENTOR CARD =================

  Widget mentorCard(Map mentor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.groups, color: Colors.teal),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mentor["TeacherName"] ?? "",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    mentor["SocietyName"] ?? "",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () async {

                bool? submitted = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Evaluatementors(
                      mentorData: mentor,
                      sessionId: selectedSessionId!,
                      evaluatorId: widget.teacherId,
                    ),
                  ),
                );

                if (submitted == true) {
                  fetchMentors();
                }
              },
              child: const Text("Evaluate", style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
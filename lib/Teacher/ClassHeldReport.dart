import 'dart:convert';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Classheldreport extends StatefulWidget {
  final String teacherId;

  const Classheldreport({super.key, required this.teacherId});

  @override
  State<Classheldreport> createState() => _ClassheldreportState();
}

class _ClassheldreportState extends State<Classheldreport> {
  List sessions = [];
  List reports = [];

  int? selectedSession;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    initData();
  }

  // 🔥 FIX: proper sequential loading
  Future<void> initData() async {
    await loadSessions();
    await loadReports();
  }

  // ================= SESSIONS =================
  Future<void> loadSessions() async {
    final res = await http.get(Uri.parse("$Url/CHR/GetSessions"));

    if (res.statusCode == 200) {
      setState(() {
        sessions = json.decode(res.body);
      });
    }
  }

  // ================= REPORTS =================
  Future<void> loadReports() async {
    setState(() {
      loading = true;
      reports = []; // 🔥 IMPORTANT: clear old data
    });

    String url =
        "$Url/CHR/GetTeacherReport?teacherId=${widget.teacherId}";

    if (selectedSession != null) {
      url += "&sessionID=$selectedSession";
    }

    print("REPORT API URL: $url");

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      setState(() {
        reports = json.decode(res.body);
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  // ================= DATE FORMAT =================
  String formatDate(String date) {
    DateTime dt = DateTime.parse(date);
    return "${dt.day.toString().padLeft(2, '0')} ${_monthName(dt.month)} ${dt.year}";
  }

  String _monthName(int m) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[m - 1];
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF9),
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Class Held Report (CHR)",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "View your daily performance record",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Image.asset('assets/images/logo.jpeg', height: 40),
                ],
              ),
            ),

            // ================= SESSION FILTER =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<int>(
                value: selectedSession,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: "Select Session",
                ),

                items: sessions.map<DropdownMenuItem<int>>((s) {
                  return DropdownMenuItem<int>(
                    value: int.parse(s["id"].toString()),
                    child: Text(s["name"].toString()),
                  );
                }).toList(),

                onChanged: (val) async {
                  setState(() {
                    selectedSession = val;
                  });

                  // 🔥 FORCE reload AFTER state update
                  await loadReports();
                },
              ),
            ),

            const SizedBox(height: 10),

            // ================= LIST =================
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : reports.isEmpty
                      ? const Center(child: Text("No Reports Found"))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: reports.length,
                          itemBuilder: (context, index) {
                            final item = reports[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.assignment,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item["CourseCode"] ?? "No Course",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(item["TeacherName"] ?? ""),
                                          const SizedBox(height: 4),
                                          Text(
                                            formatDate(item["ClassDate"]),
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Score: ${item["Score"]} | Status: ${item["Status"]}",
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
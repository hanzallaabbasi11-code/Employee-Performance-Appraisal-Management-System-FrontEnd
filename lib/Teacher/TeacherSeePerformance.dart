import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:epams/Session.dart';
import 'package:epams/Url.dart';
import 'package:epams/Student/Confidential_db.dart';

class Teacherseeperformance extends StatefulWidget {
  final String teacherName;
  final String userId;

  const Teacherseeperformance({
    super.key,
    required this.teacherName,
    required this.userId,
  });

  @override
  State<Teacherseeperformance> createState() =>
      _TeacherseeperformanceState();
}

class _TeacherseeperformanceState extends State<Teacherseeperformance> {
  late Future<List<Session>> _sessionsFuture;
  Session? selectedSession;

  Map<String, dynamic>? _teacherPerformance;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = fetchSessions();
  }

  // ================= FETCH SESSIONS =================
  Future<List<Session>> fetchSessions() async {
    final response = await http.get(
      Uri.parse('$Url/PeerEvaluator/Sessions'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Session.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load sessions');
    }
  }

  // ================= FETCH PERFORMANCE =================
  Future<Map<String, dynamic>> fetchPerformance(
      String userId, int sessionId) async {
    final response = await http.get(
      Uri.parse(
          '$Url/teacher/performance/GetTeacherPerformanceAnalytics/$userId/$sessionId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data["Status"] == "Empty") {
        throw Exception(data["Message"]);
      }

      return data;
    } else {
      throw Exception('Failed to load performance');
    }
  }

  // ================= HELPERS =================
  double _getTotalAchieved() {
    if (_teacherPerformance == null) return 0;
    return (_teacherPerformance!["Breakdown"] as List)
        .fold(0.0, (sum, kpi) => sum + (kpi["KPIAchieved"] ?? 0));
  }

  double _getTotalWeight() {
    if (_teacherPerformance == null) return 0;
    return (_teacherPerformance!["Breakdown"] as List)
        .fold(0.0, (sum, kpi) => sum + (kpi["KPIWeight"] ?? 0));
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("My Performance",
                style: TextStyle(color: Colors.black, fontSize: 18)),
            Text(widget.teacherName,
                style: const TextStyle(color: Colors.grey, fontSize: 13))
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // SESSION BAR
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  "Current Session: ${selectedSession?.name ?? "No Session Selected"}",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // DROPDOWN + FETCH + CONFIDENTIAL FIX
            FutureBuilder<List<Session>>(
              future: _sessionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final sessions = snapshot.data!;

                return DropdownButtonFormField<Session>(
                  value: selectedSession,
                  hint: const Text('Select Session'),
                  items: sessions.map((s) {
                    return DropdownMenuItem<Session>(
                      value: s,
                      child: Text(s.name),
                    );
                  }).toList(),

                  onChanged: (val) async {
                    setState(() {
                      selectedSession = val;
                      _teacherPerformance = null;
                    });

                    if (val == null) return;

                    final data =
                        await fetchPerformance(widget.userId, val.id);

                    // ================= 🔥 CONFIDENTIAL FIX (DIRECTOR MATCH) =================

                    final teacherName =
                        (data["TeacherName"] ?? "").toString().trim();
                    final sessionName =
                        (data["SessionName"] ?? "").toString();

                    double avgScore =
                        await ConfidentialDB.getAverageScore(
                      teacherName: teacherName,
                      session: sessionName,
                    );

                    bool hasLocalData = avgScore > 0;

                    List breakdown = data["Breakdown"];

                    for (var kpi in breakdown) {
                      double kpiPoints = 0;

                      for (var sub in kpi["SubDetails"]) {
                        String subName =
                            (sub["SubName"] ?? "")
                                .toString()
                                .toLowerCase();

                        double achievedSync;

                        if (subName.contains("confidential") &&
                            hasLocalData) {
                          double maxScale =
                              (sub["MaxScale"] ?? 4).toDouble();
                          double subMax =
                              (sub["SubMax"] ?? 0).toDouble();

                          double percentage = avgScore / maxScale;

                          if (percentage > 1) percentage = 1;
                          if (percentage < 0) percentage = 0;

                          achievedSync = percentage * subMax;
                        } else {
                          achievedSync =
                              (sub["SubAchieved"] ?? 0).toDouble();

                          if (achievedSync >
                              (sub["SubMax"] ?? 0)) {
                            achievedSync =
                                (sub["SubMax"] ?? 0).toDouble();
                          }
                        }

                        sub["AchievedSync"] = achievedSync;
                        kpiPoints += achievedSync;
                      }

                      kpi["KPIAchieved"] = kpiPoints;
                    }

                    // ================= UPDATE UI =================
                    setState(() {
                      _teacherPerformance = data;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // OVERALL CARD
            if (_teacherPerformance != null)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      '${_teacherPerformance?["OverallPercentage"] ?? 0}%',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    Text(
                      '(${_getTotalAchieved()} / ${_getTotalWeight()} points)',
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // KPI LIST (UNCHANGED UI)
            if (_teacherPerformance != null)
              Column(
                children:
                    (_teacherPerformance!["Breakdown"] as List).map((kpi) {
                  return Column(
                    children: [
                      Text(kpi["KPIName"]),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: kpi["KPIWeight"] == 0
                            ? 0
                            : (kpi["KPIAchieved"] /
                                kpi["KPIWeight"]),
                      ),
                      const SizedBox(height: 20),

                      Column(
                        children: (kpi["SubDetails"] as List)
                            .map<Widget>((sub) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(sub["SubName"]),
                                Text(
                                  "${sub["AchievedSync"] ?? sub["SubAchieved"]} / ${sub["SubMax"]}",
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }).toList(),
              )
            else
              const Text('Select a session to view performance'),
          ],
        ),
      ),
    );
  }
}
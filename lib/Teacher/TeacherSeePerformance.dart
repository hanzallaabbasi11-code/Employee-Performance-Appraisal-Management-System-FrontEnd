import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:epams/Session.dart';
import 'package:epams/Url.dart';

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

            // DROPDOWN
            FutureBuilder<List<Session>>(
              future: _sessionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return const Text('Failed to load sessions');
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

                    if (val != null) {
                      try {
                        final performance =
                            await fetchPerformance(widget.userId, val.id);

                        setState(() {
                          _teacherPerformance = performance;
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                  decoration: _inputDecoration(),
                );
              },
            ),

            const SizedBox(height: 20),

            // OVERALL CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.trending_up,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Overall Performance",
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 5),
                      Text(
                        '${_teacherPerformance?["OverallPercentage"] ?? 0}%',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      Text(
                        '(${_getTotalAchieved()} / ${_getTotalWeight()} points)',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // KPI LIST
            if (_teacherPerformance != null)
              Column(
                children:
                    (_teacherPerformance!["Breakdown"] as List).map((kpi) {
                  return Column(
                    children: [
                      performanceCard(
                        title: kpi["KPIName"],
                        score:
                            '${kpi["KPIAchieved"]} / ${kpi["KPIWeight"]}',
                        progress: kpi["KPIWeight"] == 0
                            ? 0
                            : (kpi["KPIAchieved"] /
                                kpi["KPIWeight"]),
                        items: (kpi["SubDetails"] as List)
                            .map<List<String>>((sub) => [
                                  sub["SubName"],
                                  '${sub["SubAchieved"]} / ${sub["SubMax"]}'
                                ])
                            .toList(),
                      ),
                      const SizedBox(height: 20),
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

  // ================= KPI CARD =================
  Widget performanceCard({
    required String title,
    required String score,
    required double progress,
    required List<List<String>> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text(score,
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: Colors.green,
            minHeight: 8,
          ),
          const SizedBox(height: 15),
          Column(
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [Text(item[0]), Text(item[1])],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF3F8F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
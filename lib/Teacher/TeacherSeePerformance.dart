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

  String? selectedKpiId; // 🔥 REAL KPI ID

  List kpiTypes = [];

  Map<String, dynamic>? _teacherPerformance;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = fetchSessions();
  }

  // ================= SESSIONS =================
  Future<List<Session>> fetchSessions() async {
    final response = await http.get(
      Uri.parse('$Url/PeerEvaluator/Sessions'),
    );

    List data = json.decode(response.body);
    return data.map((e) => Session.fromJson(e)).toList();
  }

  // ================= KPI TYPES =================
  Future<void> fetchKpiTypes(int sessionId) async {
    final res = await http.get(
      Uri.parse('$Url/teacher/performance/GetKpiTypesBySession/$sessionId'),
    );

    if (res.statusCode == 200) {
      setState(() {
        kpiTypes = jsonDecode(res.body);
      });
    }
  }

  // ================= PERFORMANCE =================
  Future<Map<String, dynamic>> fetchPerformance(
      String userId, int sessionId, String? kpiId) async {
    String url =
        '$Url/teacher/performance/GetTeacherPerformanceAnalytics/$userId/$sessionId';

    if (kpiId != null) {
      url += "?kpiId=$kpiId";
    }

    final response = await http.get(Uri.parse(url));
    return json.decode(response.body);
  }

  // ================= GRAPH COLOR =================
 Color getDynamicColor(String text) {
  final hash = text.hashCode;

  final r = (hash & 0xFF0000) >> 16;
  final g = (hash & 0x00FF00) >> 8;
  final b = (hash & 0x0000FF);

  return Color.fromARGB(255, r, g, b).withOpacity(0.8);
}

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Performance")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= SESSION =================
            FutureBuilder<List<Session>>(
              future: _sessionsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final sessions = snapshot.data!;

                return Column(
                  children: [
                    DropdownButtonFormField<Session>(
                      value: selectedSession,
                      hint: const Text("Select Session"),
                      items: sessions.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedSession = val;
                          selectedKpiId = null;
                          _teacherPerformance = null;
                          kpiTypes = [];
                        });

                        if (val != null) {
                          fetchKpiTypes(val.id);
                        }
                      },
                    ),

                    const SizedBox(height: 10),

                    // ================= KPI CATEGORY (REAL IDs) =================
                    DropdownButtonFormField<String>(
                      value: selectedKpiId,
                      hint: const Text("All Categories"),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text("All Categories"),
                        ),
                        ...kpiTypes.map((e) {
                          return DropdownMenuItem(
                            value: e["id"].toString(),
                            child: Text(e["name"]),
                          );
                        }).toList(),
                      ],
                      onChanged: (val) {
                        setState(() {
                          selectedKpiId = val;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    ElevatedButton(
                      onPressed: () async {
                        if (selectedSession == null) return;

                        final data = await fetchPerformance(
                          widget.userId,
                          selectedSession!.id,
                          selectedKpiId,
                        );

                        setState(() {
                          _teacherPerformance = data;
                        });
                      },
                      child: const Text("Generate"),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // ================= RESULT =================
            if (_teacherPerformance != null) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  "${_teacherPerformance!["OverallPercentage"]}%",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 15),

              // ================= GRAPH =================
              SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: (_teacherPerformance!["Breakdown"] as List)
                      .map<Widget>((kpi) {
                    double percent = kpi['KPIWeight'] == 0
                        ? 0
                        : (kpi['KPIAchieved'] /
                            kpi['KPIWeight']) *
                            100;

                    return Column(
                      children: [
                        Text("${percent.toStringAsFixed(0)}%"),
                        const SizedBox(height: 5),
                        Container(
                          width: 18,
                          height: percent * 2,
                          decoration: BoxDecoration(
                            color: getDynamicColor(kpi['KPIName']),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: 60,
                          child: Text(
                            kpi['KPIName'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // ================= KPI DETAILS (UNCHANGED) =================
              Expanded(
                child: ListView(
                  children: (_teacherPerformance!["Breakdown"] as List)
                      .map((kpi) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kpi["KPIName"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),

                        LinearProgressIndicator(
                          value: kpi["KPIWeight"] == 0
                              ? 0
                              : (kpi["KPIAchieved"] /
                                  kpi["KPIWeight"]),
                        ),

                        const SizedBox(height: 10),

                        ...kpi["SubDetails"].map<Widget>((sub) {
                          return Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(sub["SubName"])),
                              Text(
                                  "${sub["AchievedSync"] ?? sub["SubAchieved"]} / ${sub["SubMax"]}"),
                            ],
                          );
                        }).toList(),

                        const SizedBox(height: 15),
                      ],
                    );
                  }).toList(),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
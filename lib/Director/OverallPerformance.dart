import 'dart:convert';
import 'package:epams/Student/Confidential_db.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Overallperformance extends StatefulWidget {
  const Overallperformance({super.key});

  @override
  State<Overallperformance> createState() => _OverallperformanceState();
}

class _OverallperformanceState extends State<Overallperformance> {
  String baseUrl = "$Url/OverallPerformance";

  List sessions = [];
  List teachers = [];
  List kpiTypes = [];

  String? selectedSessionId;
  String? selectedTeacherId;
  String? selectedKpiId; // null = ALL

  Map<String, dynamic>? performanceData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  // ================= FETCH =================

  Future<void> fetchSessions() async {
    final res = await http.get(Uri.parse("$baseUrl/list"));
    if (res.statusCode == 200) {
      setState(() => sessions = jsonDecode(res.body));
    }
  }

  Future<void> fetchTeachers(String sessionId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/GetTeachersBySession/$sessionId"),
    );

    if (res.statusCode == 200) {
      setState(() => teachers = jsonDecode(res.body));
    }
  }

  Future<void> fetchKpiTypes(String sessionId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/GetKpiTypesBySession/$sessionId"),
    );

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);

      // ✅ ADD ALL OPTION
      data.insert(0, {"id": "all", "name": "All Categories"});

      setState(() => kpiTypes = data);
    }
  }

  // ================= ANALYTICS =================

  Future<void> fetchAnalytics() async {
    if (selectedSessionId == null || selectedTeacherId == null) return;

    setState(() => isLoading = true);

    String url =
        "$baseUrl/GetTeacherPerformanceAnalytics/$selectedTeacherId/$selectedSessionId";

    // ✅ APPLY FILTER ONLY IF NOT ALL
    if (selectedKpiId != null && selectedKpiId != "all") {
      url += "?kpiId=$selectedKpiId";
    }

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (data["Status"] == "Empty") {
        setState(() {
          performanceData = null;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["Message"] ?? "No Data Found")),
        );
        return;
      }

      /// LOCAL CONFIDENTIAL AVG
      final teacherName = (data["TeacherName"] ?? "").toString().trim();
      final sessionName = (data["SessionName"] ?? "").toString();

      double avgScore = await ConfidentialDB.getAverageScore(
        teacherName: teacherName,
        session: sessionName,
      );

      bool hasLocalData = avgScore > 0;

      double totalEarned = 0;
      double totalMax = 0;

      List breakdown = data["Breakdown"];

      for (var kpi in breakdown) {
        totalMax += (kpi["KPIWeight"] ?? 0);

        double kpiPoints = 0;

        for (var sub in kpi["SubDetails"]) {
          String subName = (sub["SubName"] ?? "").toString().toLowerCase();

          double achievedSync;

          if (subName.contains("confidential") && hasLocalData) {
            double maxScale = (sub["MaxScale"] ?? 4).toDouble();
            double subMax = (sub["SubMax"] ?? 0).toDouble();

            double percentage = avgScore / maxScale;
            if (percentage > 1) percentage = 1;
            if (percentage < 0) percentage = 0;

            achievedSync = percentage * subMax;
          } else {
            achievedSync = (sub["SubAchieved"] ?? 0).toDouble();

            if (achievedSync > (sub["SubMax"] ?? 0)) {
              achievedSync = (sub["SubMax"] ?? 0).toDouble();
            }
          }

          sub["AchievedSync"] = achievedSync;
          kpiPoints += achievedSync;
        }

        kpi["KPIAchieved"] = kpiPoints > kpi["KPIWeight"]
            ? kpi["KPIWeight"]
            : kpiPoints;

        totalEarned += kpi["KPIAchieved"];
      }

      data["OverallPercentage"] = totalMax > 0
          ? ((totalEarned / totalMax) * 100).round()
          : 0;

      setState(() {
        performanceData = data;
        isLoading = false;
      });
    }
  }

  Color getDynamicColor(String text) {
  final hash = text.hashCode;

  final r = (hash & 0xFF0000) >> 16;
  final g = (hash & 0x00FF00) >> 8;
  final b = (hash & 0x0000FF);

  return Color.fromARGB(255, r, g, b).withOpacity(0.8);
}

  // ================= DROPDOWN =================

  Widget buildDropdown({
    required String hint,
    required List items,
    required Function(String?) onChanged,
    String? value,
    String keyId = 'id',
    String keyName = 'name',
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint),
            isExpanded: true,
            items: items.map<DropdownMenuItem<String>>((e) {
              return DropdownMenuItem(
                value: e[keyId].toString(),
                child: Text(e[keyName]),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade800,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                performanceData?["TeacherName"] ?? "",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                performanceData?["SessionName"] ?? "",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Text(
              "${performanceData?["OverallPercentage"] ?? 0}%",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ================= GRAPH =================

  Widget buildGraph() {
    List breakdown = performanceData?["Breakdown"] ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Metric Analytics",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: breakdown.map<Widget>((kpi) {
              double percent = kpi['KPIWeight'] == 0
                  ? 0
                  : (kpi['KPIAchieved'] / kpi['KPIWeight']) * 100;

              return Column(
                children: [
                  Text("${percent.toStringAsFixed(0)}%"),
                  const SizedBox(height: 5),
                  Container(
                    width: 20,
                    height: percent,
                    color:getDynamicColor(kpi['KPIName']),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 60,
                    child: Text(
                      kpi['KPIName'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  )
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ================= KPI CARD =================

  Widget buildKpiCard(Map kpi) {
    double percent = kpi['KPIWeight'] == 0
        ? 0
        : ((kpi['KPIAchieved'] / kpi['KPIWeight']) * 100);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kpi['KPIName'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${percent.toStringAsFixed(1)}%"),
                Text(
                  "${kpi['KPIAchieved']} / ${kpi['KPIWeight']}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          ...kpi['SubDetails'].map<Widget>((sub) {
            bool isConfidential = (sub['SubName'] ?? "")
                .toString()
                .toLowerCase()
                .contains("confidential");

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(sub['SubName'])),
                  Text(
                    isConfidential
                        ? "${sub['AchievedSync']} / ${sub['SubMax']}"
                        : "${sub['SubAchieved']} / ${sub['SubMax']}",
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(title: const Text("Overall Performance")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [

            /// 🔥 DROPDOWNS
            Row(
              children: [
                buildDropdown(
                  hint: "Session",
                  items: sessions,
                  value: selectedSessionId,
                  onChanged: (val) {
                    setState(() {
                      selectedSessionId = val;
                      selectedTeacherId = null;
                      selectedKpiId = null;
                      teachers = [];
                      kpiTypes = [];
                    });

                    fetchTeachers(val!);
                    fetchKpiTypes(val);
                  },
                ),
                const SizedBox(width: 8),
                buildDropdown(
                  hint: "Teacher",
                  items: teachers,
                  value: selectedTeacherId,
                  keyId: 'UserID',
                  keyName: 'Name',
                  onChanged: (val) {
                    setState(() => selectedTeacherId = val);
                  },
                ),
                const SizedBox(width: 8),
                buildDropdown(
                  hint: "Category",
                  items: kpiTypes,
                  value: selectedKpiId ?? "all",
                  onChanged: (val) {
                    setState(() {
                      if (val == "all") {
                        selectedKpiId = null;
                      } else {
                        selectedKpiId = val;
                      }
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// 🔥 BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: fetchAnalytics,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Generate Analysis"),
              ),
            ),

            const SizedBox(height: 10),

            if (isLoading) const CircularProgressIndicator(),

            if (performanceData != null) ...[
              buildHeaderCard(),
              buildGraph(),

              Expanded(
                child: ListView(
                  children: performanceData!["Breakdown"]
                      .map<Widget>((kpi) => buildKpiCard(kpi))
                      .toList(),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
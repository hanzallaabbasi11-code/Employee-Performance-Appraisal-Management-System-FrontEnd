import 'dart:convert';
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

  String? selectedSessionId;
  String? selectedTeacherId;

  Map<String, dynamic>? performanceData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    final res = await http.get(Uri.parse("$baseUrl/list"));
    if (res.statusCode == 200) {
      setState(() {
        sessions = jsonDecode(res.body);
      });
    }
  }

  Future<void> fetchTeachers(String sessionId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/GetTeachersBySession/$sessionId"),
    );
    if (res.statusCode == 200) {
      setState(() {
        teachers = jsonDecode(res.body);
      });
    }
  }

  Future<void> fetchAnalytics() async {
    if (selectedSessionId == null || selectedTeacherId == null) return;

    setState(() => isLoading = true);

    final res = await http.get(
      Uri.parse(
        "$baseUrl/GetTeacherPerformanceAnalytics/$selectedTeacherId/$selectedSessionId",
      ),
    );

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

      setState(() {
        performanceData = data;
        isLoading = false;
      });
    }
  }

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
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

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
          LinearProgressIndicator(value: percent / 100, minHeight: 8),
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
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(sub['SubName']),
                  Text("${sub['SubAchieved']} / ${sub['SubMax']}"),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(title: const Text("Overall Performance")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                buildDropdown(
                  hint: "Select Session",
                  items: sessions,
                  value: selectedSessionId,
                  onChanged: (val) {
                    setState(() {
                      selectedSessionId = val;
                      selectedTeacherId = null;
                      teachers = [];
                    });
                    fetchTeachers(val!);
                  },
                ),
                const SizedBox(width: 10),
                buildDropdown(
                  hint: "Select Teacher",
                  items: teachers,
                  value: selectedTeacherId,
                  keyId: 'UserID',
                  keyName: 'Name',
                  onChanged: (val) {
                    setState(() => selectedTeacherId = val);
                  },
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: fetchAnalytics,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Generate"),
                ),
              ],
            ),

            const SizedBox(height: 15),

            if (isLoading) const CircularProgressIndicator(),

            if (performanceData != null) ...[
              buildHeaderCard(),
              const SizedBox(height: 15),

              Builder(
                builder: (context) {
                  final breakdown = performanceData?["Breakdown"];

                  if (breakdown == null || breakdown.isEmpty) {
                    return const Center(
                      child: Text(
                        "No KPI Data Available",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  return Expanded(
                    child: ListView(
                      children: breakdown
                          .map<Widget>((kpi) => buildKpiCard(kpi))
                          .toList(),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

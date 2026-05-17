// ignore_for_file: avoid_print, file_names

import 'dart:convert';
import 'package:epams/Student/ConfidentialEvaluationStudents/Confidential_db.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Allperformance extends StatefulWidget {
  const Allperformance({super.key});

  @override
  State<Allperformance> createState() => _AllperformanceState();
}

class _AllperformanceState extends State<Allperformance> {
  final String baseUrl = "$Url/KpiBasedPerformance";

  List sessions = [];
  List kpis = [];
  List subKpis = [];
  List sortedTeacherRankings = [];

  String? selectedSessionId;
  String? selectedKpiId;
  String? selectedSubKpiId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  // ================= NAME NORMALIZATION =================
  String normalizeName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'dr\.?|mr\.?|ms\.?|prof\.?'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ================= API =================

  Future<void> _fetchSessions() async {
    final res = await http.get(Uri.parse("$baseUrl/GetSessions"));
    if (res.statusCode == 200) {
      setState(() {
        sessions = json.decode(res.body);
        if (sessions.isNotEmpty) {
          selectedSessionId = sessions[0]['id'].toString();
          _fetchKPIs(selectedSessionId!);
        }
      });
    }
  }

  Future<void> _fetchKPIs(String sessionId) async {
    final res =
        await http.get(Uri.parse("$baseUrl/GetKPIsBySession/$sessionId"));
    if (res.statusCode == 200) {
      setState(() {
        kpis = json.decode(res.body);
        subKpis = [];
        selectedKpiId = null;
        selectedSubKpiId = null;
      });
    }
  }

  Future<void> _fetchSubKPIs(String kpiId, String sessionId) async {
    final res = await http.get(Uri.parse(
        "$baseUrl/GetSubKPIsByKPIAndSession/$kpiId/$sessionId"));
    if (res.statusCode == 200) {
      setState(() {
        subKpis = json.decode(res.body);
        selectedSubKpiId = null;
      });
    }
  }

  // ================= ENGINE =================

  Future<void> _generatePerformanceEngine() async {
    if (selectedSessionId == null) return;

    setState(() => isLoading = true);

    try {
      String url =
          "$baseUrl/GetTeacherRankingV2?sessionId=$selectedSessionId";

      if (selectedKpiId != null) url += "&kpiId=$selectedKpiId";
      if (selectedSubKpiId != null) url += "&subKpiId=$selectedSubKpiId";

      final res = await http.get(Uri.parse(url));

      if (res.statusCode != 200) {
        setState(() => isLoading = false);
        return;
      }

      List backend = json.decode(res.body);
      List combined = [];

      int sessionInt = int.parse(selectedSessionId!);

      for (var teacher in backend) {
        String name = teacher['TeacherName'] ?? '';
        String clean = normalizeName(name);

        // ================= SQLITE CONFIDENTIAL SCORE =================
        double localAvg =
            await ConfidentialDB.getAverageScoreBySessionId(
          teacherName: clean,
          sessionId: sessionInt,
        );

        double normalized = (localAvg / 4.0) * 100;

        List breakdown = List.from(teacher['Breakdown'] ?? []);

        double totalWeight =
            (teacher['TotalSessionWeight'] as num? ?? 0).toDouble();
        double totalObtained =
            (teacher['TotalObtainedWeight'] as num? ?? 0).toDouble();

        double confidentialWeight = 25.0;
        double achieved = (normalized * confidentialWeight) / 100;

        // ============================================================
        // 🔥 IMPORTANT FIX:
        // Confidential ALWAYS included (all filters)
        // ============================================================

        bool found = false;

        for (var item in breakdown) {
          if ((item['SubKPI'] ?? '')
              .toString()
              .toLowerCase()
              .contains('confidential')) {
            item['RawScore'] = localAvg;
            item['NormalizedScore'] = normalized;
            item['SubKPITotalWeight'] = confidentialWeight;
            item['SubKPIObtainedWeight'] = achieved;
            found = true;
            break;
          }
        }

        if (!found) {
          breakdown.add({
            "SubKPI": "Confidential Evaluation",
            "Category": "Internal (SQLite)",
            "RawScore": localAvg,
            "NormalizedScore": normalized,
            "SubKPITotalWeight": confidentialWeight,
            "SubKPIObtainedWeight": achieved,
          });
        }

        totalWeight += confidentialWeight;
        totalObtained += achieved;

        double finalPercent = totalWeight > 0
            ? (totalObtained / totalWeight) * 100
            : 0;

        combined.add({
          "TeacherName": name,
          "Department": teacher['Department'] ?? 'N/A',
          "OverallPercentage": finalPercent,
          "TotalSessionWeight": totalWeight,
          "TotalObtainedWeight": totalObtained,
          "Breakdown": breakdown,
        });
      }

      combined.sort((a, b) =>
          (b['OverallPercentage'] as num)
              .compareTo(a['OverallPercentage'] as num));

      setState(() {
        sortedTeacherRankings = combined;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Performance")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _dropdown(
                    "Session",
                    selectedSessionId,
                    sessions.map((s) {
                      return DropdownMenuItem(
                        value: s['id'].toString(),
                        child: Text(s['name'] ?? ''),
                      );
                    }).toList(),
                    (v) {
                      setState(() => selectedSessionId = v);
                      if (v != null) _fetchKPIs(v);
                    },
                  ),

                  const SizedBox(height: 10),

                  _dropdown(
                    "KPI",
                    selectedKpiId,
                    kpis.map((k) {
                      return DropdownMenuItem(
                        value: k['id'].toString(),
                        child: Text(k['name'] ?? ''),
                      );
                    }).toList(),
                    (v) {
                      setState(() => selectedKpiId = v);
                      if (v != null && selectedSessionId != null) {
                        _fetchSubKPIs(v, selectedSessionId!);
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  _dropdown(
                    "Sub KPI",
                    selectedSubKpiId,
                    subKpis.map((s) {
                      return DropdownMenuItem(
                        value: s['id'].toString(),
                        child: Text(s['name'] ?? ''),
                      );
                    }).toList(),
                    (v) => setState(() => selectedSubKpiId = v),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: _generatePerformanceEngine,
                    child: const Text("Generate"),
                  ),

                  const SizedBox(height: 20),

                  if (sortedTeacherRankings.isNotEmpty) _buildChart(),

                  const SizedBox(height: 20),

                  _buildList(),
                ],
              ),
            ),
    );
  }

  // ================= DROPDOWN =================

  Widget _dropdown(
    String hint,
    String? value,
    List<DropdownMenuItem<String>> items,
    Function(String?) onChange,
  ) {
    return DropdownButtonFormField(
      value: value,
      hint: Text(hint),
      items: items,
      onChanged: onChange,
    );
  }

  // ================= SAFE CHART =================

  Widget _buildChart() {
    return SizedBox(
      height: 260,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(sortedTeacherRankings.length, (i) {
            final d = sortedTeacherRankings[i];
            double p = (d['OverallPercentage'] as num).toDouble();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("${p.toStringAsFixed(1)}%"),
                  Container(
                    width: 40,
                    height: (p * 1.5).clamp(5, 150),
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 60,
                    child: Text(
                      d['TeacherName'],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // ================= LIST =================

  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedTeacherRankings.length,
      itemBuilder: (c, i) {
        final d = sortedTeacherRankings[i];

        return Card(
          child: ExpansionTile(
            title: Text(d['TeacherName']),
            subtitle: Text(d['Department']),
            trailing: Text(
              "${d['OverallPercentage'].toStringAsFixed(1)}%",
              style: const TextStyle(color: Colors.green),
            ),
            children: (d['Breakdown'] as List).map<Widget>((b) {
              return ListTile(
                title: Text(b['SubKPI'] ?? ''),
                subtitle: Text(b['Category'] ?? ''),
                trailing: Text("${b['RawScore']}"),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
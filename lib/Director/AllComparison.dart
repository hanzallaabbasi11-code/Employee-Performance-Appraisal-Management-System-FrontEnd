import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:epams/Url.dart';
import 'package:epams/Student/ConfidentialEvaluationStudents/Confidential_db.dart';

class AllComparisonScreen extends StatefulWidget {
  const AllComparisonScreen({super.key});

  @override
  State<AllComparisonScreen> createState() => _AllComparisonScreenState();
}

class _AllComparisonScreenState extends State<AllComparisonScreen> {
  final String performanceBase = "$Url/KpiBaseComparision";
  final String sessionBase = "$Url/KpiBasedPerformance";

  List sessions = [];
  List kpis = [];
  List subKpis = [];
  List teachers = [];

  int? selectedSessionId;
  int? selectedKpiId;
  int? selectedSubKpiId;

  String? teacher1Id;
  String? teacher2Id;

  Map<String, dynamic>? teacher1Data;
  Map<String, dynamic>? teacher2Data;

  double confidential1 = 0;
  double confidential2 = 0;

  bool loading = false;
  bool hasCompared = false;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  // ================= SESSIONS =================
  Future<void> _loadSessions() async {
    final res = await http.get(Uri.parse("$sessionBase/GetSessions"));

    if (res.statusCode == 200) {
      sessions = jsonDecode(res.body);

      if (sessions.isNotEmpty) {
        selectedSessionId = sessions[0]['id'];
        await _loadTeachers(selectedSessionId!);
        await _loadKPIs(selectedSessionId!);
      }

      setState(() {});
    }
  }

  // ================= TEACHERS =================
  Future<void> _loadTeachers(int sessionId) async {
    final res = await http.get(
      Uri.parse("$performanceBase/GetTeachersBySession/$sessionId"),
    );

    if (res.statusCode == 200) {
      teachers = jsonDecode(res.body);

      if (teachers.length >= 2) {
        teacher1Id = teachers[0]['id'].toString();
        teacher2Id = teachers[1]['id'].toString();
      }

      setState(() {});
    }
  }

  // ================= KPIs =================
  Future<void> _loadKPIs(int sessionId) async {
    final res = await http.get(
      Uri.parse("$sessionBase/GetKPIsBySession/$sessionId"),
    );

    if (res.statusCode == 200) {
      kpis = jsonDecode(res.body);
      selectedKpiId = null;
      subKpis = [];
      selectedSubKpiId = null;
      setState(() {});
    }
  }

  Future<void> _loadSubKPIs(int kpiId) async {
    final res = await http.get(
      Uri.parse(
        "$sessionBase/GetSubKPIsByKPIAndSession/$kpiId/$selectedSessionId",
      ),
    );

    if (res.statusCode == 200) {
      subKpis = jsonDecode(res.body);
      selectedSubKpiId = null;
      setState(() {});
    }
  }

  // ================= FIXED CONFIDENTIAL CALL =================
  Future<double> _getConfidential(String teacherName) async {
    if (teacherName.isEmpty || selectedSessionId == null) return 0;

    try {
      final cleanName = teacherName.trim(); // IMPORTANT FIX HERE

      return await ConfidentialDB.getAverageScoreBySessionId(
        teacherName: cleanName,
        sessionId: selectedSessionId!,
      );
    } catch (e) {
      debugPrint("Confidential error: $e");
      return 0;
    }
  }

  // ================= COMPARE =================
  Future<void> _compare() async {
    setState(() {
      loading = true;
      hasCompared = true;
    });

    String url =
        "$performanceBase/GetTeacherComparison?sessionId=$selectedSessionId&teacher1Id=$teacher1Id&teacher2Id=$teacher2Id";

    if (selectedKpiId != null) url += "&kpiId=$selectedKpiId";
    if (selectedSubKpiId != null) url += "&subKpiId=$selectedSubKpiId";

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      teacher1Data = data['Teacher1'];
      teacher2Data = data['Teacher2'];

      // 🔥 IMPORTANT: wait until UI has data
      final t1Name = teacher1Data?['TeacherName'] ?? "";
      final t2Name = teacher2Data?['TeacherName'] ?? "";

      // FIX: delay ensures UI state consistency
      Future.delayed(Duration.zero, () async {
        confidential1 = await _getConfidential(t1Name);
        confidential2 = await _getConfidential(t2Name);
        setState(() {});
      });
    }

    setState(() => loading = false);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Teacher Comparison"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _filterCard(),
                  const SizedBox(height: 15),

                  if (hasCompared) ...[
                    _chart(),
                    const SizedBox(height: 15),
                    _summary(),
                    const SizedBox(height: 15),
                    _table(),
                  ]
                ],
              ),
            ),
    );
  }

  // ================= FILTER =================
  Widget _filterCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _dropdown("Session", selectedSessionId, sessions.map((e) {
              return DropdownMenuItem(
                value: e['id'],
                child: Text(e['name']),
              );
            }).toList(), (v) {
              setState(() => selectedSessionId = v);
              _loadTeachers(v);
              _loadKPIs(v);
            }),

            const SizedBox(height: 10),

            _dropdown("KPI", selectedKpiId, kpis.map((e) {
              return DropdownMenuItem(
                value: e['id'],
                child: Text(e['name']),
              );
            }).toList(), (v) {
              setState(() => selectedKpiId = v);
              if (v != null) _loadSubKPIs(v);
            }),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _dropdown("Teacher 1", teacher1Id,
                    teachers.map((e) {
                  return DropdownMenuItem(
                    value: e['id'].toString(),
                    child: Text(e['name']),
                  );
                }).toList(), (v) => setState(() => teacher1Id = v))),

                const SizedBox(width: 10),

                Expanded(child: _dropdown("Teacher 2", teacher2Id,
                    teachers.map((e) {
                  return DropdownMenuItem(
                    value: e['id'].toString(),
                    child: Text(e['name']),
                  );
                }).toList(), (v) => setState(() => teacher2Id = v))),
              ],
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              onPressed: _compare,
              child: const Text("Compare"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(String hint, dynamic value,
      List<DropdownMenuItem> items, Function(dynamic) onChange) {
    return DropdownButtonFormField(
      value: value,
      items: items,
      onChanged: onChange,
      decoration: InputDecoration(labelText: hint),
    );
  }

  // ================= CHART =================
  Widget _chart() {
    double t1 = (teacher1Data?['OverallPercentage'] ?? 0).toDouble();
    double t2 = (teacher2Data?['OverallPercentage'] ?? 0).toDouble();

    final data = [
      _Chart("Teacher 1", t1),
      _Chart("Teacher 2", t2),
    ];

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(maximum: 100),
      series: [
        ColumnSeries<_Chart, String>(
          dataSource: data,
          color: Colors.green,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          xValueMapper: (d, _) => d.name,
          yValueMapper: (d, _) => d.value,
        )
      ],
    );
  }

  // ================= SUMMARY =================
  Widget _summary() {
    return Row(
      children: [
        Expanded(child: _card(teacher1Data, confidential1)),
        const SizedBox(width: 10),
        Expanded(child: _card(teacher2Data, confidential2)),
      ],
    );
  }

  Widget _card(Map<String, dynamic>? d, double conf) {
    double pct = (d?['OverallPercentage'] ?? 0).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(d?['TeacherName'] ?? "N/A"),
            Text("KPI: ${pct.toStringAsFixed(1)}%"),
            Text("Confidential: ${conf.toStringAsFixed(1)}%"),
          ],
        ),
      ),
    );
  }

  // ================= TABLE =================
  Widget _table() {
    final t1 = teacher1Data?['Breakdown'] ?? [];
    final t2 = teacher2Data?['Breakdown'] ?? [];

    Set<String> keys = {};
    for (var e in t1) keys.add(e['SubKPI']);
    for (var e in t2) keys.add(e['SubKPI']);

    return Card(
      child: Column(
        children: keys.map((k) {
          var a = t1.firstWhere((e) => e['SubKPI'] == k, orElse: () => {});
          var b = t2.firstWhere((e) => e['SubKPI'] == k, orElse: () => {});

          return ListTile(
            title: Text(k),
            subtitle: Text(
              "T1: ${a['NormalizedScore'] ?? 0} | T2: ${b['NormalizedScore'] ?? 0}",
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Chart {
  final String name;
  final double value;
  _Chart(this.name, this.value);
}
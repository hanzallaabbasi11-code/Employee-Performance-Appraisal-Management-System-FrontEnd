import 'dart:convert';
import 'package:epams/Director/DetailedPerformance.dart';
//import 'package:epams/Director/Detailedperformance.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class Viewperformance extends StatefulWidget {
  final String teacherId;
  final String courseCode;
  final int sessionId;

  const Viewperformance({
    super.key,
    required this.teacherId,
    required this.courseCode,
    required this.sessionId,
  });

  @override
  State<Viewperformance> createState() => _ViewperformanceState();
}

class _ViewperformanceState extends State<Viewperformance> {
  Map result = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getPerformance();
  }

  // ================= API CALL =================

  Future getPerformance() async {
    var res = await http.get(
      Uri.parse(
        "$Url/Performance/GetTeacherResultByCourse?teacherId=${widget.teacherId}&courseCode=${widget.courseCode}&sessionId=${widget.sessionId}",
      ),
    );

    var data = jsonDecode(res.body);

    setState(() {
      result = data;
      loading = false;
    });
  }

  // ================= CHART =================

  Widget performanceChart() {
    List chartData = [
      {"type": "Peer", "score": result['PeerAverage'] ?? 0},
      {"type": "Student", "score": result['StudentAverage'] ?? 0},
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Teacher Performance",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // 🔹 Navigate to Detailed Screen
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Detailedperformance(
                        teacherId: widget.teacherId,
                        sessionId: widget.sessionId,
                        courseCode: widget.courseCode,
                      ),
                    ),
                  );
                },

                child: const Text("Detailed"),
              ),
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 220,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              series: <CartesianSeries>[
                ColumnSeries<dynamic, String>(
                  dataSource: chartData,
                  xValueMapper: (data, _) => data['type'],
                  yValueMapper: (data, _) => data['score'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= DETAILS CARD =================

  Widget detailCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result['Name'] ?? "",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Peer Score"),
              Text("${result['PeerTotal']} / ${result['PeerMax']}"),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Student Score"),
              Text("${result['StudentTotal']} / ${result['StudentMax']}"),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Score"),
              Text("${result['Total']} / ${result['TotalMax']}"),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Percentage",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "${result['Percentage']}%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),

      appBar: AppBar(
        title: const Text("Teacher Performance"),
        backgroundColor: Colors.green,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ListView(
                children: [
                  performanceChart(),
                  detailCard(),
                ],
              ),
            ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Compareresult extends StatefulWidget {

  final List result;
  final String mode;
  final String? course;
  final int? session1;
  final int? session2;

  const Compareresult({
    super.key,
    required this.result,
    required this.mode,
    this.course,
    this.session1,
    this.session2,
  });

  @override
  State<Compareresult> createState() => _CompareresultState();
}

class _CompareresultState extends State<Compareresult> {

  Map get t1 => widget.result.isNotEmpty ? widget.result[0] : {};
  Map get t2 => widget.result.length > 1 ? widget.result[1] : {};

  // ---------------- WINNER ----------------

  String get winner {

    if(widget.result.isEmpty) return "No Data";

    double p1 = (t1["OverallAverageOutOfHundred"] ?? 0).toDouble();
    double p2 = (t2["OverallAverageOutOfHundred"] ?? 0).toDouble();

    if(p1 > p2) return "${t1["Name"]} Wins";
    if(p2 > p1) return "${t2["Name"]} Wins";

    return "It's a Tie";
  }

  // ---------------- TEACHER CARD ----------------

  Widget teacherCard(Map data) {

    return Container(
      width: MediaQuery.of(context).size.width * .42,
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6)
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            data["Name"] ?? "",
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),

          const SizedBox(height: 10),

          const Text("Peer Score"),
          Text("${data["PeerTotalScore"] ?? 0} / ${data["PeerMaxTotal"] ?? 0}"),

          const SizedBox(height: 6),

          const Text("Student Score"),
          Text("${data["StudentTotalScore"] ?? 0} / ${data["StudentMaxTotal"] ?? 0}"),

          const SizedBox(height: 6),

          const Text("Final %"),
          Text("${data["OverallAverageOutOfHundred"] ?? 0}%"),
        ],
      ),
    );
  }

  // ---------------- PERFORMANCE CHART ----------------

  Widget performanceChart() {

    List chartData = [

      {
        "type": "Peer",
        "t1": t1["PeerAverageOutOfTen"] ?? 0,
        "t2": t2["PeerAverageOutOfTen"] ?? 0
      },

      {
        "type": "Student",
        "t1": t1["StudentAverageOutOfTen"] ?? 0,
        "t2": t2["StudentAverageOutOfTen"] ?? 0
      },

      {
        "type": "Final %",
        "t1": t1["OverallAverageOutOfHundred"] ?? 0,
        "t2": t2["OverallAverageOutOfHundred"] ?? 0
      }
    ];

    return SizedBox(
      height: 300,

      child: SfCartesianChart(

        primaryXAxis: CategoryAxis(),

        legend: Legend(isVisible: true),

        series: [

          ColumnSeries(
            name: "T1",
            dataSource: chartData,
            xValueMapper: (d, _) => d["type"],
            yValueMapper: (d, _) => d["t1"],
          ),

          ColumnSeries(
            name: "T2",
            dataSource: chartData,
            xValueMapper: (d, _) => d["type"],
            yValueMapper: (d, _) => d["t2"],
          )
        ],
      ),
    );
  }

  // ---------------- FINAL RESULT CHART ----------------

  Widget finalChart() {

    List chart = [

      {
        "x": "T1",
        "y": t1["OverallAverageOutOfHundred"] ?? 0
      },

      {
        "x": "T2",
        "y": t2["OverallAverageOutOfHundred"] ?? 0
      }
    ];

    return SizedBox(
      height: 250,

      child: SfCartesianChart(

        primaryXAxis: CategoryAxis(),

        series: [

          ColumnSeries(
            dataSource: chart,
            xValueMapper: (d, _) => d["x"],
            yValueMapper: (d, _) => d["y"],
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          )
        ],
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {

    if(widget.result.isEmpty){
      return const Scaffold(
        body: Center(child: Text("No comparison data found")),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Comparison Result"),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // -------- WINNER BANNER --------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),

              child: Center(
                child: Text(
                  "🏆 $winner",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // -------- TEACHER CARDS --------

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                teacherCard(t1),
                teacherCard(t2),
              ],
            ),

            const SizedBox(height: 25),

            // -------- PERFORMANCE CHART --------

            const Text(
              "Performance Breakdown",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),

            const SizedBox(height: 10),

            performanceChart(),

            const SizedBox(height: 20),

            // -------- FINAL RESULT CHART --------

            const Text(
              "Final Result %",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),

            const SizedBox(height: 10),

            finalChart(),

            const SizedBox(height: 20),

            // -------- MODE INFO --------

            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),

              child: Text(
                widget.mode == "course"
                    ? "Mode: Course Comparison\nCourse: ${widget.course}"
                    : "Mode: Session Comparison\nSessions: ${widget.session1} vs ${widget.session2}",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ignore_for_file: file_names, avoid_print

import 'package:epams/Student/ConfidentialEvaluation/Confidential_db.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Compareresult extends StatefulWidget {
  final List result;
  final String mode;
  final String? course;
  final int? session1;
final int? session2;

final String? sessionName1;
final String? sessionName2;

  const Compareresult({
    super.key,
    required this.result,
    required this.mode,
    this.course,
    this.session1,
    this.session2, 
    this.sessionName1,
    this.sessionName2,
  });

  @override
  State<Compareresult> createState() => _CompareresultState();
}

class _CompareresultState extends State<Compareresult> {
  Map get t1 => widget.result.isNotEmpty ? widget.result[0] : {};
  Map get t2 => widget.result.length > 1 ? widget.result[1] : {};

  double confidential1 = 0;
  double confidential2 = 0;

  // ---------------- SCORES OUT OF 10 ----------------

  double peer10T1 = 0;
  double peer10T2 = 0;

  double student10T1 = 0;
  double student10T2 = 0;

  double confidential10T1 = 0;
  double confidential10T2 = 0;

  // ---------------- FINAL % ----------------

  double finalPercent1 = 0;
  double finalPercent2 = 0;

  bool loadingConfidential = true;

  @override
  void initState() {
    super.initState();
    loadConfidentialScores();
  }

  // ---------------- CALCULATE FINAL ----------------

  void calculateFinalScores() {
    // PEER OUT OF 10
    peer10T1 = (t1["PeerAverageOutOfTen"] ?? 0).toDouble();
    peer10T2 = (t2["PeerAverageOutOfTen"] ?? 0).toDouble();

    // STUDENT OUT OF 10
    student10T1 = (t1["StudentAverageOutOfTen"] ?? 0).toDouble();
    student10T2 = (t2["StudentAverageOutOfTen"] ?? 0).toDouble();

    // CONFIDENTIAL OUT OF 10
    confidential10T1 = confidential1 * 2.5;
    confidential10T2 = confidential2 * 2.5;

    // FINAL %
    finalPercent1 =
        ((peer10T1 + student10T1 + confidential10T1) / 30) * 100;

    finalPercent2 =
        ((peer10T2 + student10T2 + confidential10T2) / 30) * 100;
  }

  // ---------------- CONFIDENTIAL SCORES ----------------

 Future loadConfidentialScores() async {
  try {

    // 🔥 SESSION COMPARISON MODE
    if (widget.mode == "session") {

      confidential1 =
          await ConfidentialDB.getAverageScoreBySessionId(
        teacherName: t1["Name"]?.toString() ?? "",
        sessionId: widget.session1 ?? 0,
      );

      confidential2 =
          await ConfidentialDB.getAverageScoreBySessionId(
        teacherName: t2["Name"]?.toString() ?? "",
        sessionId: widget.session2 ?? 0,
      );

    } else {

      // 🔥 COURSE MODE
      String s1 = widget.sessionName1 ?? "";
      String s2 = widget.sessionName2 ?? "";

      if (t1["SessionName"] != null) {
        s1 = t1["SessionName"].toString();
      }

      if (t2["SessionName"] != null) {
        s2 = t2["SessionName"].toString();
      }

      confidential1 = await ConfidentialDB.getAverageScore(
        teacherName: t1["Name"]?.toString() ?? "",
        session: s1,
      );

      confidential2 = await ConfidentialDB.getAverageScore(
        teacherName: t2["Name"]?.toString() ?? "",
        session: s2,
      );
    }

    print(
      "📊 CONFIDENTIAL T1 => ${t1["Name"]} | ${widget.session1} | $confidential1",
    );

    print(
      "📊 CONFIDENTIAL T2 => ${t2["Name"]} | ${widget.session2} | $confidential2",
    );

    calculateFinalScores();

    setState(() {
      loadingConfidential = false;
    });

  } catch (e) {

    print("❌ Confidential Error => $e");

    setState(() {
      loadingConfidential = false;
    });
  }
}
  // ---------------- WINNER ----------------

  String get winner {
    if (widget.result.isEmpty) return "No Data";

    if (finalPercent1 > finalPercent2) {
      return "${t1["Name"]} Wins";
    }

    if (finalPercent2 > finalPercent1) {
      return "${t2["Name"]} Wins";
    }

    return "It's a Tie";
  }

  // ---------------- TEACHER CARD ----------------

  Widget teacherCard(
    Map data,
    double peer,
    double student,
    double confidential,
    double finalPercent,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * .42,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data["Name"] ?? "",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 10),

          // ---------------- PEER ----------------

          const Text("Peer Score"),

          Text("${peer.toStringAsFixed(2)} / 10"),

          const SizedBox(height: 6),

          // ---------------- STUDENT ----------------

          const Text("Student Score"),

          Text("${student.toStringAsFixed(2)} / 10"),

          const SizedBox(height: 6),

          // ---------------- CONFIDENTIAL ----------------

          const Text("Confidential Score"),

          Text("${confidential.toStringAsFixed(2)} / 10"),

          const SizedBox(height: 6),

          // ---------------- FINAL ----------------

          const Text("Final %"),

          Text("${finalPercent.toStringAsFixed(2)}%"),
        ],
      ),
    );
  }

  // ---------------- PERFORMANCE CHART ----------------

  Widget performanceChart() {
    List chartData = [
      {
        "type": "Peer",
        "t1": peer10T1,
        "t2": peer10T2,
      },

      {
        "type": "Student",
        "t1": student10T1,
        "t2": student10T2,
      },

      {
        "type": "Confidential",
        "t1": confidential10T1,
        "t2": confidential10T2,
      },

      {
        "type": "Final %",
        "t1": finalPercent1,
        "t2": finalPercent2,
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
        "y": finalPercent1,
      },

      {
        "x": "T2",
        "y": finalPercent2,
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
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
            ),
          )
        ],
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    if (widget.result.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("No comparison data found"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comparison Result"),
        backgroundColor: Colors.green,
      ),
      body: loadingConfidential
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -------- WINNER BANNER --------

                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.all(14),
                  //   decoration: BoxDecoration(
                  //     color: Colors.green.shade100,
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Center(
                  //     child: Text(
                  //       "🏆 $winner",
                  //       style: const TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 16,
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  const SizedBox(height: 20),

                  // -------- TEACHER CARDS --------

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      teacherCard(
                        t1,
                        peer10T1,
                        student10T1,
                        confidential10T1,
                        finalPercent1,
                      ),

                      teacherCard(
                        t2,
                        peer10T2,
                        student10T2,
                        confidential10T2,
                        finalPercent2,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // -------- PERFORMANCE CHART --------

                  const Text(
                    "Performance Breakdown",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),

                  performanceChart(),

                  const SizedBox(height: 20),

                  // -------- FINAL RESULT CHART --------

                  const Text(
                    "Final Result %",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
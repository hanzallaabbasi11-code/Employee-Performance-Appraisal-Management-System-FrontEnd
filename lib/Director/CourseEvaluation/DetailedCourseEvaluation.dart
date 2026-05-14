// ignore_for_file: file_names, deprecated_member_use

import 'dart:convert';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class Detailedcourseevaluation extends StatefulWidget {
  final String teacherId;
  final String teacherName;
  final int sessionId;
  final String courseCode;

  const Detailedcourseevaluation({
    super.key,
    required this.teacherId,
    required this.teacherName,
    required this.sessionId,
    required this.courseCode,
  });

  @override
  State<Detailedcourseevaluation> createState() =>
      _DetailedcourseevaluationState();
}

class _DetailedcourseevaluationState
    extends State<Detailedcourseevaluation> {
  List questions = [];
  List courses = [];

  String selectedCourse = "";
  String selectedEvalType = "both";
  String selectedQuestionStatus = "all";

  bool loading = true;

  @override
  void initState() {
    super.initState();
    selectedCourse = widget.courseCode;
    getCourses();
    getQuestions();
  }

  Future<void> getCourses() async {
    final response = await http.get(
      Uri.parse(
        "$Url/ExtraFeatures/GetMyCourses/${widget.teacherId}/${widget.sessionId}",
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        courses = jsonDecode(response.body);

        if (!courses.contains("ALL")) {
          courses.insert(0, "ALL");
        }
      });
    }
  }

  Future<void> getQuestions() async {
    setState(() {
      loading = true;
    });

    final response = await http.get(
      Uri.parse(
        "$Url/ExtraFeatures/GetCourseQuestionDetail/"
        "${widget.teacherId}/${widget.sessionId}/$selectedCourse"
        "?evaluationType=$selectedEvalType"
        "&questionStatus=$selectedQuestionStatus",
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        questions = jsonDecode(response.body);
      });
    }

    setState(() {
      loading = false;
    });
  }

  // ================= GRAPH COLOR =================
  Color getBarColor(double score) {
    if (score >= 3.5) {
      return const Color(0xff18863a);
    } else if (score >= 2.5) {
      return const Color(0xff7DDF9F);
    } else if (score >= 1.5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // ================= GRAPH =================
  Widget buildQuestionGraph() {
    if (questions.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Question-wise Average Score",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Click any question card below to view evaluator details",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 350,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 4,
                interval: 1,
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: Colors.grey.shade200,
                ),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries>[
                ColumnSeries<Map<String, dynamic>, String>(
                  width: 0.45,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  dataSource: questions.asMap().entries.map((e) {
                    return {
                      "x": "Q${e.key + 1}",
                      "y":
                          (e.value["AverageScore"] ?? 0).toDouble(),
                    };
                  }).toList(),
                  xValueMapper: (data, _) => data["x"],
                  yValueMapper: (data, _) => data["y"],
                  pointColorMapper: (data, _) =>
                      getBarColor(data["y"]),
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: false,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              buildLegend(
                const Color(0xff18863a),
                "Excellent (≥3.5)",
              ),
              buildLegend(
                const Color(0xff7DDF9F),
                "Good (≥2.5)",
              ),
              buildLegend(
                Colors.orange,
                "Average (≥1.5)",
              ),
              buildLegend(
                Colors.red,
                "Poor (<1.5)",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget scoreBar(String title, int value, int total, Color color) {
    double width = total == 0 ? 0 : value / total;

    return Row(
      children: [
        SizedBox(width: 30, child: Text(title)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: width,
              minHeight: 10,
              color: color,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void showEvaluatorModal(Map item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * .65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "EVALUATOR LIST",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                item["QuestionText"] ?? "",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: item["StudentDetails"].length,
                  itemBuilder: (_, index) {
                    final d = item["StudentDetails"][index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade100,
                            child: const Icon(
                              Icons.person_outline,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d["StudentName"] ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),

                                Text(
                                  "ID: ${d["RollNo"]}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: (d["Score"] >= 3)
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              "Score: ${d["Score"]}",
                              style: TextStyle(
                                color: (d["Score"] >= 3)
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildQuestionCard(Map item, int index) {
    int total = item["TotalResponses"] ?? 0;

    return GestureDetector(
      onTap: () => showEvaluatorModal(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.08),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["QuestionText"] ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "(${(item["AverageScore"] ?? 0).toStringAsFixed(1)})",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      (item["AverageScore"] ?? 0)
                          .toStringAsFixed(2),
                      style: const TextStyle(
                        color: Color(0xff0b7a34),
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    const Text(
                      "AVG\nRATING",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 26),

            Row(
              children: const [
                Text(
                  "SCORE DISTRIBUTION",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            scoreBar("S4", item["Score4"] ?? 0, total, Colors.green),

            const SizedBox(height: 12),

            scoreBar(
              "S3",
              item["Score3"] ?? 0,
              total,
              Colors.lightGreen,
            ),

            const SizedBox(height: 12),

            scoreBar(
              "S2",
              item["Score2"] ?? 0,
              total,
              Colors.orange,
            ),

            const SizedBox(height: 12),

            scoreBar(
              "S1",
              item["Score1"] ?? 0,
              total,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: courses.contains(selectedCourse)
                ? selectedCourse
                : null,
            decoration: InputDecoration(
              labelText: "COURSE",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            items: courses.map<DropdownMenuItem<String>>((e) {
              return DropdownMenuItem(
                value: e.toString(),
                child: Text(e.toString()),
              );
            }).toList(),
            onChanged: (v) {
              setState(() {
                selectedCourse = v!;
              });

              getQuestions();
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedEvalType,
            decoration: InputDecoration(
              labelText: "EVAL TYPE",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: "both",
                child: Text("Both"),
              ),
              DropdownMenuItem(
                value: "student",
                child: Text("Student"),
              ),
              DropdownMenuItem(
                value: "peer",
                child: Text("Peer"),
              ),
            ],
            onChanged: (v) {
              setState(() {
                selectedEvalType = v!;
              });

              getQuestions();
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6f8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Question-wise Ratings",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          "Teacher ID: ${widget.teacherId} • Session: ${widget.sessionId}",
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          buildFilters(),

                          const SizedBox(height: 14),

                          DropdownButtonFormField<String>(
                            value: selectedQuestionStatus,
                            decoration: InputDecoration(
                              labelText: "QUESTION TYPE",
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: "all",
                                child: Text("All Questions"),
                              ),
                              DropdownMenuItem(
                                value: "critical",
                                child:
                                    Text("Critical Questions"),
                              ),
                            ],
                            onChanged: (v) {
                              setState(() {
                                selectedQuestionStatus = v!;
                              });

                              getQuestions();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (loading)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),

                    if (!loading && questions.isNotEmpty)
                      buildQuestionGraph(),

                    const SizedBox(height: 20),

                    if (!loading && questions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Text(
                            "No Questions Found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),

                    ...questions.asMap().entries.map(
                          (e) => buildQuestionCard(
                            e.value,
                            e.key,
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
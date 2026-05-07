// detailedcourseevaluation.dart

import 'dart:convert';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
          "$Url/ExtraFeatures/GetMyCourses/${widget.teacherId}/${widget.sessionId}"),
    );

    if (response.statusCode == 200) {
      setState(() {
        courses = jsonDecode(response.body);
      });
    }
  }

  Future<void> getQuestions() async {
    setState(() {
      loading = true;
    });

    final response = await http.get(
      Uri.parse(
          "$Url/ExtraFeatures/GetCourseQuestionDetail/${widget.teacherId}/${widget.sessionId}/$selectedCourse?evaluationType=$selectedEvalType"),
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

  Color getBarColor(String key) {
    switch (key) {
      case "Score4":
        return Colors.green;
      case "Score3":
        return Colors.lightGreen;
      case "Score2":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  Widget scoreBar(
      String title, int value, int total, Color color) {
    double width = total == 0 ? 0 : value / total;

    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(title),
        ),
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
        )
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
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
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
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item["QuestionText"],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount:
                      item["StudentDetails"].length,
                  itemBuilder: (_, index) {
                    final d = item["StudentDetails"][index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                Colors.grey.shade100,
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
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  "ID: ${d["RollNo"]}",
                                  style: const TextStyle(
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: (d["Score"] >= 3)
                                  ? Colors.green
                                      .shade100
                                  : Colors.red.shade100,
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            child: Text(
                              "Score: ${d["Score"]}",
                              style: TextStyle(
                                color: (d["Score"] >= 3)
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    "Total: ${item["TotalResponses"]} Responses",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Avg.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        Colors.green.shade100,
                    child: Text(
                      item["AverageScore"]
                          .toStringAsFixed(2),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget buildQuestionCard(Map item, int index) {
    int total = item["TotalResponses"];

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
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius:
                        BorderRadius.circular(14),
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
                        item["QuestionText"],
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(
                          item["AverageScore"]
                              .round(),
                          (index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 18,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      item["AverageScore"]
                          .toStringAsFixed(2),
                      style: const TextStyle(
                        color: Color(0xff0b7a34),
                        fontWeight: FontWeight.bold,
                        fontSize: 34,
                      ),
                    ),
                    const Text(
                      "AVG RATING",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                )
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
            scoreBar(
              "S4",
              item["Score4"],
              total,
              Colors.green,
            ),
            const SizedBox(height: 12),
            scoreBar(
              "S3",
              item["Score3"],
              total,
              Colors.lightGreen,
            ),
            const SizedBox(height: 12),
            scoreBar(
              "S2",
              item["Score2"],
              total,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            scoreBar(
              "S1",
              item["Score1"],
              total,
              Colors.red,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: item["Type"] == "Student"
                        ? Colors.blue.shade50
                        : Colors.purple.shade50,
                    borderRadius:
                        BorderRadius.circular(30),
                  ),
                  child: Text(
                    "${item["Type"]} Eval",
                    style: TextStyle(
                      color:
                          item["Type"] == "Student"
                              ? Colors.blue
                              : Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  "Click to see who rated →",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                )
              ],
            )
          ],
        ),
      ),
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
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Question Analysis",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        "Teacher: ${widget.teacherName} • Session: ${widget.sessionId}",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child:
                                DropdownButtonFormField<String>(
                              value: selectedCourse,
                              decoration: InputDecoration(
                                labelText: "SELECT COURSE",
                                filled: true,
                                fillColor:
                                    Colors.grey.shade100,
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          16),
                                  borderSide:
                                      BorderSide.none,
                                ),
                              ),
                              items: courses
                                  .map<
                                          DropdownMenuItem<
                                              String>>(
                                      (e) =>
                                          DropdownMenuItem(
                                            value: e,
                                            child:
                                                Text(e),
                                          ))
                                  .toList(),
                              onChanged: (v) {
                                setState(() {
                                  selectedCourse =
                                      v!;
                                });
                                getQuestions();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child:
                                DropdownButtonFormField<String>(
                              value: selectedEvalType,
                              decoration: InputDecoration(
                                labelText:
                                    "EVALUATION TYPE",
                                filled: true,
                                fillColor:
                                    Colors.grey.shade100,
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          16),
                                  borderSide:
                                      BorderSide.none,
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
                                  selectedEvalType =
                                      v!;
                                });
                                getQuestions();
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (loading)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child:
                            CircularProgressIndicator(),
                      ),
                    ...questions
                        .asMap()
                        .entries
                        .map((e) => buildQuestionCard(
                            e.value, e.key))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
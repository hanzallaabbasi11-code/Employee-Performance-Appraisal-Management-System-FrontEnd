import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Url.dart';

class EvaluateModal extends StatefulWidget {
  final String teacherId;
  final String teacherName;
  final int sessionId;
  final String hodId;
  final List courses;

  const EvaluateModal({
    super.key,
    required this.teacherId,
    required this.teacherName,
    required this.sessionId,
    required this.hodId,
    required this.courses,
  });

  @override
  State<EvaluateModal> createState() => _EvaluateModalState();
}

class _EvaluateModalState extends State<EvaluateModal> {
  late List<Map<String, dynamic>> evaluations;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    evaluations = widget.courses.map((c) {
      return {
        "courseCode": (c["code"] ?? "").toString(),
        "courseName": (c["course"] ?? "").toString(),
        "paperStatus": "on-time",
        "folderStatus": "on-time",
      };
    }).toList();
  }

  String formatStatus(String value) {
    return value == "on-time" ? "On-Time" : "Late";
  }

  Future<void> saveEvaluation() async {
    setState(() => isSaving = true);

    try {
      final url = Uri.parse("$Url/CourseManagement/SaveEvaluation");

      final body = {
        "TeacherID": widget.teacherId,
        "SessionID": widget.sessionId,
        "HODID": widget.hodId,
        "Evaluations": evaluations.map((e) {
          return {
            "CourseCode": e["courseCode"],
            "PaperStatus": formatStatus(e["paperStatus"]),
            "FolderStatus": formatStatus(e["folderStatus"]),
          };
        }).toList()
      };

      print("📤 REQUEST: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      print("📥 STATUS: ${response.statusCode}");
      print("📥 RESPONSE: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Evaluation Saved Successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Server Error: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Exception: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) setState(() => isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.teacherName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),

          const SizedBox(height: 10),

          ...evaluations.asMap().entries.map((entry) {
            int index = entry.key;
            var item = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item["courseName"]),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: item["paperStatus"],
                          onChanged: (val) {
                            setState(() {
                              evaluations[index]["paperStatus"] = val!;
                            });
                          },
                          items: const [
                            DropdownMenuItem(value: "on-time", child: Text("On Time")),
                            DropdownMenuItem(value: "late", child: Text("Late")),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: item["folderStatus"],
                          onChanged: (val) {
                            setState(() {
                              evaluations[index]["folderStatus"] = val!;
                            });
                          },
                          items: const [
                            DropdownMenuItem(value: "on-time", child: Text("On Time")),
                            DropdownMenuItem(value: "late", child: Text("Late")),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving ? null : saveEvaluation,
              child: isSaving
                  ? const CircularProgressIndicator()
                  : const Text("Submit Evaluation"),
            ),
          )
        ],
      ),
    );
  }
}
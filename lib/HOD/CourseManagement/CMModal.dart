// ignore_for_file: file_names, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Url.dart';

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

        // default statuses
        "paperStatus": "on-time",
        "folderStatus": "on-time",

        // NEW REMARKS FIELD
        "remarks": "",
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

            // NEW REMARKS
            "Remarks": e["remarks"],
          };
        }).toList()
      };

      print("📤 REQUEST:");
      print(jsonEncode(body));

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

    if (mounted) {
      setState(() => isSaving = false);
    }
  }

  Widget buildDropdown({
    required String value,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        onChanged: onChanged,
        items: const [
          DropdownMenuItem(
            value: "on-time",
            child: Text("On Time"),
          ),
          DropdownMenuItem(
            value: "late",
            child: Text("Late"),
          ),
        ],
      ),
    );
  }

  @override
  @override
Widget build(BuildContext context) {
  return DraggableScrollableSheet(
    initialChildSize: 0.85,
    minChildSize: 0.5,
    maxChildSize: 0.95,
    expand: false,

    builder: (context, scrollController) {
      return Container(
        padding: const EdgeInsets.all(16),

        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),

        child: Column(
          children: [
            // ================= HEADER =================

            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.teacherName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: evaluations.length,

                itemBuilder: (context, index) {
                  final item = evaluations[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.green.shade100,
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["courseName"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          item["courseCode"],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          "Paper Submission",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        buildDropdown(
                          value: item["paperStatus"],
                          onChanged: (val) {
                            setState(() {
                              evaluations[index]["paperStatus"] = val!;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          "Folder Submission",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        buildDropdown(
                          value: item["folderStatus"],
                          onChanged: (val) {
                            setState(() {
                              evaluations[index]["folderStatus"] = val!;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          "Remarks",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          initialValue: item["remarks"],
                          maxLines: 3,

                          onChanged: (val) {
                            evaluations[index]["remarks"] = val;
                          },

                          decoration: InputDecoration(
                            hintText: "Enter remarks here...",

                            filled: true,
                            fillColor: Colors.green.shade50,

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.green.shade100,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: isSaving ? null : saveEvaluation,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "Submit Evaluation",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:epams/Url.dart';

class Chrreportdetail extends StatefulWidget {
  final int reportId;

  const Chrreportdetail({super.key, required this.reportId});

  @override
  State<Chrreportdetail> createState() => _ChrreportdetailState();
}

class _ChrreportdetailState extends State<Chrreportdetail> {
  late Future<List<dynamic>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchDetail();
  }

  // ================= FETCH =================
  Future<List<dynamic>> fetchDetail() async {
    final res = await http.get(
      Uri.parse('$Url/CHR/GetReportById/${widget.reportId}'),
    );

    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception("Failed to load detail");
    }
  }

  // ================= DELETE =================
  Future<void> deleteRow(int id) async {
    await http.delete(Uri.parse('$Url/CHR/DeleteRow/$id'));

    setState(() {
      futureData = fetchDetail();
    });
  }

  // ================= EDIT =================
  Future<void> editRow(dynamic item) async {
    TextEditingController lateCtrl =
        TextEditingController(text: item["LateIn"].toString());
    TextEditingController earlyCtrl =
        TextEditingController(text: item["LeftEarly"].toString());
    TextEditingController remarksCtrl =
        TextEditingController(text: item["Remarks"] ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Row"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: lateCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Late In"),
            ),
            TextField(
              controller: earlyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Left Early"),
            ),
            TextField(
              controller: remarksCtrl,
              decoration: const InputDecoration(labelText: "Remarks"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await http.put(
                Uri.parse('$Url/CHR/EditRow/${item["id"]}'),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "LateIn": int.parse(lateCtrl.text),
                  "LeftEarly": int.parse(earlyCtrl.text),
                  "Remarks": remarksCtrl.text,
                }),
              );

              Navigator.pop(context);

              setState(() {
                futureData = fetchDetail();
              });
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text(
          "Detailed Attendance Report",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureData,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return const Center(child: Text("Error loading data"));
          }

          final data = snap.data!;

          if (data.isEmpty) {
            return const Center(child: Text("No Data Found"));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: data.map((item) => _row(item)).toList(),
          );
        },
      ),
    );
  }

  // ================= ROW =================
  Widget _row(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item["Status"] == "Cancelled"
            ? Colors.red.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // TOP ROW
          Row(
            children: [
              Expanded(
                child: Text(
                  item["TeacherName"] ?? "",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              _statusChip(item["Status"]),
            ],
          ),

          const SizedBox(height: 4),

          // COURSE + VENUE
          Row(
            children: [
              Text(
                item["CourseCode"] ?? "",
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              Text(
                item["Venue"] ?? "",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // STATS
          Row(
            children: [
              _miniBox(item["LateIn"], "Late"),
              _miniBox(item["LeftEarly"], "Early"),
              const SizedBox(width: 6),
              _scoreBox(item["Score"]),
            ],
          ),

          const SizedBox(height: 10),

          // REMARKS
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item["Remarks"] ?? "",
              style: const TextStyle(fontSize: 13),
            ),
          ),

          const SizedBox(height: 10),

          // ACTIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => editRow(item),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text("Edit"),
              ),
              TextButton.icon(
                onPressed: () => deleteRow(item["id"]),
                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                label:
                    const Text("Del", style: TextStyle(color: Colors.red)),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ================= MINI BOX =================
  Widget _miniBox(dynamic value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 11))
          ],
        ),
      ),
    );
  }

  // ================= SCORE =================
  Widget _scoreBox(dynamic score) {
    Color bg;
    Color text;

    if (score == 0) {
      bg = Colors.red.shade100;
      text = Colors.red;
    } else if (score <= 3) {
      bg = Colors.orange.shade100;
      text = Colors.orange;
    } else {
      bg = Colors.blue.shade100;
      text = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "⭐ $score/5",
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= STATUS =================
  Widget _statusChip(String status) {
    bool isCancelled = status == "Cancelled";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isCancelled
            ? Colors.red.shade100
            : Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isCancelled ? "Cancelled" : "Held",
        style: TextStyle(
          color: isCancelled ? Colors.red : Colors.green,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
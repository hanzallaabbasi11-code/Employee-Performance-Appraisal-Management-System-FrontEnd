import 'dart:convert';
import 'package:epams/HOD/CHRReportDetail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:epams/Url.dart';

class Chrreport extends StatefulWidget {
  const Chrreport({super.key});

  @override
  State<Chrreport> createState() => _ChrreportState();
}

class _ChrreportState extends State<Chrreport> {
  late Future<List<dynamic>> reportsFuture;

  @override
  void initState() {
    super.initState();
    reportsFuture = fetchReports();
  }

  // ================= FETCH REPORTS =================
  Future<List<dynamic>> fetchReports() async {
    final response = await http.get(Uri.parse('$Url/CHR/GetHODDashboard'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load reports");
    }
  }

  // ================= DELETE BATCH =================
  Future<void> deleteBatch(int reportId) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Report"),
        content: const Text("Are you sure you want to delete this report?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response =
          await http.delete(Uri.parse('$Url/CHR/DeleteBatch/$reportId'));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report deleted successfully")),
        );

        // 🔄 Refresh list
        setState(() {
          reportsFuture = fetchReports();
        });
      } else {
        throw Exception("Delete failed");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting: $e")),
      );
    }
  }

  // ================= DATE FORMAT =================
  String formatDate(String date) {
    DateTime dt = DateTime.parse(date);
    return "${dt.day.toString().padLeft(2, '0')} ${_monthName(dt.month)} ${dt.year}";
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "CHR Management",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading reports"));
          }

          final data = snapshot.data!;

          if (data.isEmpty) {
            return const Center(child: Text("No CHR Reports Found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return _buildCard(item);
            },
          );
        },
      ),
    );
  }

  // ================= CARD =================
  Widget _buildCard(dynamic item) {
    double avgScore = double.tryParse(item["AvgScore"].toString()) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          // Top Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header Row (UPDATED WITH DELETE BUTTON)
                Row(
                  children: [
                    const Icon(Icons.assignment, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      "CHR REPORT",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),

                    // 🗑 DELETE BUTTON
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => deleteBatch(item["ReportId"]),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Date Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "DATE",
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatDate(item["ReportDate"]),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Stats
                Row(
                  children: [
                    _statBox(item["TotalClasses"], "Total"),
                    _statBox(item["CancelledClasses"], "Cancelled"),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _statBox(item["LateTeachers"], "Late"),
                    _statBox(avgScore.toStringAsFixed(1), "Avg Score"),
                  ],
                ),
              ],
            ),
          ),

          // Button
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        Chrreportdetail(reportId: item["ReportId"]),
                  ),
                );
              },
              icon: const Icon(Icons.visibility, color: Colors.white),
              label: const Text(
                "View Details",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= STAT BOX =================
  Widget _statBox(dynamic value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
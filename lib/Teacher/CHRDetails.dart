import 'package:flutter/material.dart';

class Chrdetails extends StatefulWidget {
  const Chrdetails({super.key});

  @override
  State<Chrdetails> createState() => _ChrdetailsState();
}

class _ChrdetailsState extends State<Chrdetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "CHR Details",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "24 Nov 2025",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                   Image.asset(
                    'assets/images/logo.jpeg',
                    height: 40,
                  ),
                ],
              ),
            ),

            // ================= PURPLE INFO STRIP =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              color: Colors.purple,
              child: const Text(
                "Detailed class records for the selected date.",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),

            // ================= BODY =================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  // ===== CHR SUMMARY CARD =====
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.calendar_month,
                            color: Colors.purple),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "CHR Details",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text("24 Nov 2025",
                                style: TextStyle(fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== SUBJECT CARD (NOT HELD) =====
                  _buildSubjectCard(
                    subject: "Web Technologies (WT)",
                    teacher: "Mr. Muhammad Ahsan",
                    discipline: "BCS-4A",
                    status: "Not Held",
                    statusColor: Colors.red,
                    remarks:
                        "Class not conducted due to faculty meeting.",
                  ),

                  const SizedBox(height: 16),

                  // ===== SUBJECT CARD (HELD) =====
                  _buildSubjectCard(
                    subject: "Database Systems (DBS)",
                    teacher: "Mr. Muhammad Ahsan",
                    discipline: "BCS-5B",
                    status: "Held",
                    statusColor: Colors.green,
                    remarks:
                        "Left early for administrative work.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SUBJECT CARD WIDGET =================
  Widget _buildSubjectCard({
    required String subject,
    required String teacher,
    required String discipline,
    required String status,
    required Color statusColor,
    required String remarks,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: status == "Held"
            ? Colors.green.shade50
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Details Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _detailColumn("Date", "24 Nov 2025"),
              _detailColumn("Teacher", teacher),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _detailColumn("Discipline", discipline),
              _detailColumn("Status", status),
            ],
          ),

          const SizedBox(height: 8),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Late In\n—",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text("Left Early\n—",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            "Remarks",
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            remarks,
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

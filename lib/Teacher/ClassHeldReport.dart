import 'package:epams/Teacher/CHRDetails.dart';
import 'package:flutter/material.dart';

class Classheldreport extends StatefulWidget {
  const Classheldreport({super.key});

  @override
  State<Classheldreport> createState() => _ClassheldreportState();
}

class _ClassheldreportState extends State<Classheldreport> {
  final List<Map<String, String>> chrReports = [
    {
      "title": "CHR report of 25 Nov 2025",
      "date": "25 Nov 2025",
      "records": "2 records",
    },
    {
      "title": "CHR report of 24 Nov 2025",
      "date": "24 Nov 2025",
      "records": "2 records",
    },
    {
      "title": "CHR report of 23 Nov 2025",
      "date": "23 Nov 2025",
      "records": "1 record",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF9),
      body: SafeArea(
        child: Column(
          children: [

            // ================= HEADER (UPDATED) =================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                
                children: [
                   IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text(
                        'Class Held Report (CHR)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'View your daily performance record.',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Image.asset(
                    'assets/images/logo.jpeg',
                    height: 40,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12,),
            Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(),
                color: Colors.purple,
              ),
              child: Center(child: Text('Your Class Attendence and schedule report.',style: 
              TextStyle(color: Colors.white),)),
            ),
                    const SizedBox(height: 12,),
            // ================= LIST =================
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: chrReports.length,
                itemBuilder: (context, index) {
                  final report = chrReports[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Calendar Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Colors.purple,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Text Section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report["title"]!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  report["date"]!,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  report["records"]!,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // View Details Button
                          SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> Chrdetails()),);
                              },
                              child: const Text(
                                "View Details",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

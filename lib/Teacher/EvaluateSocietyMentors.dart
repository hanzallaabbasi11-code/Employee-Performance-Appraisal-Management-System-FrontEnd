import 'package:epams/Teacher/EvaluateMentors.dart';
import 'package:flutter/material.dart';

class Evaluatesocietymentors extends StatefulWidget {
  const Evaluatesocietymentors({super.key});

  @override
  State<Evaluatesocietymentors> createState() =>
      _EvaluatesocietymentorsState();
}

class _EvaluatesocietymentorsState extends State<Evaluatesocietymentors> {

  final List<Map<String, String>> mentors = [
    {"name": "Ali Raza", "dept": "Computer Science"},
    {"name": "Fatima Khan", "dept": "Software Engineering"},
    {"name": "Ahmed Hassan", "dept": "Data Science"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: Column(
          children: [

            // ✅ HEADER (Copied Style From Course Screen)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Evaluate Society Mentors",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Evaluate the mentors of your society based on their Performance.",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  Image.asset('assets/images/logo.jpeg', height: 40),
                ],
              ),
            ),

            const Divider(height: 1),

            const SizedBox(height: 15),

            // ✅ Section Title (Same As Picture)
            // const Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 16),
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: Text(
            //       "Computing Society - Select a mentor to evaluate their contribution.",
            //       style: TextStyle(
            //           fontWeight: FontWeight.w600,
            //           color: Colors.teal),
            //     ),
            //   ),
            // ),


             Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(),
                color: Colors.teal,
              ),
              child: Center(child: Text('Computing Society-Select a mentor to evaluate their contribution.',style: 
              TextStyle(color: Colors.white,fontSize: 11),)),
            ),
            const SizedBox(height: 10),

            // ✅ Mentor List (UNCHANGED UI)
            Expanded(
              child: ListView.builder(
                itemCount: mentors.length,
                itemBuilder: (context, index) {
                  return _mentorCard(
                    mentors[index]["name"]!,
                    mentors[index]["dept"]!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mentor Card (Same As Screenshot)
  Widget _mentorCard(String name, String dept) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [

            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_outline,
                  color: Colors.teal),
            ),

            const SizedBox(width: 12),

            // Name + Dept
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    dept,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Evaluate Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Evaluatementors()));
              },
              child: const Text("Evaluate"),
            ),
          ],
        ),
      ),
    );
  }
}

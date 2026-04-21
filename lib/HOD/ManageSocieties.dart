import 'package:epams/Session.dart';
import 'package:flutter/material.dart';

class Managesocieties extends StatefulWidget {

  final Session session;

  const Managesocieties({super.key, required this.session});

  @override
  State<Managesocieties> createState() => _ManagesocietiesState();
}

class _ManagesocietiesState extends State<Managesocieties> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xfff4f6f5),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Societies", style: TextStyle(color: Colors.black)),
            Text("Society Management",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// SESSION BAR
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: Colors.green,
              child: Row(
                children: [
                  const Text("Current Session:",
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(widget.session.name,
                        style: const TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ADD NEW SOCIETY CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Row(
                    children: [
                      Icon(Icons.add, color: Colors.green),
                      SizedBox(width: 6),
                      Text("Add New Society",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),

                  const SizedBox(height: 15),

                  const Text("Society Name *"),

                  const SizedBox(height: 6),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        hintText: "e.g., Programming Society",
                        filled: true,
                        border: OutlineInputBorder()),
                  ),

                  const SizedBox(height: 10),

                  const Text("Description (optional)"),

                  const SizedBox(height: 6),

                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        hintText: "Brief description of the society...",
                        filled: true,
                        border: OutlineInputBorder()),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(14),
                      ),
                      icon: const Icon(Icons.save),
                      label: const Text("Save Society"),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// EXISTING SOCIETIES
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Existing Societies (3)",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 10),

            _societyCard(
                "Programming Society",
                "Focuses on coding competitions and development",
                "2 Chairpersons",
                "5 Mentors"),

            _societyCard(
                "Robotics Society",
                "Explores robotics and automation technologies",
                "1 Chairperson",
                "3 Mentors"),

            _societyCard(
                "Media Society",
                "Manages university media and publications",
                "1 Chairperson",
                "2 Mentors"),
          ],
        ),
      ),
    );
  }

  Widget _societyCard(String name, String desc, String chair, String mentor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Expanded(
                child: Text(name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),

              const Icon(Icons.edit, color: Colors.green),

              const SizedBox(width: 10),

              const Icon(Icons.delete, color: Colors.red),
            ],
          ),

          const SizedBox(height: 6),

          Text(desc, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.person_outline, size: 16),
              const SizedBox(width: 4),
              Text(chair),

              const SizedBox(width: 15),

              const Icon(Icons.group, size: 16),
              const SizedBox(width: 4),
              Text(mentor),
            ],
          )
        ],
      ),
    );
  }
}
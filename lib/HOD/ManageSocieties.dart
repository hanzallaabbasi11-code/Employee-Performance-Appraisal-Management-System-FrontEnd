import 'dart:convert';
import 'package:epams/Session.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Managesocieties extends StatefulWidget {
  final Session session;

  const Managesocieties({super.key, required this.session});

  @override
  State<Managesocieties> createState() => _ManagesocietiesState();
}

class _ManagesocietiesState extends State<Managesocieties> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  List societies = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getSocieties();
  }

  /// =============================
  /// GET ALL SOCIETIES
  /// =============================
  Future<void> getSocieties() async {

    setState(() {
      loading = true;
    });

    final response =
        await http.get(Uri.parse("$Url/CourseManagement/GetAll"));

    if (response.statusCode == 200) {
      setState(() {
        societies = json.decode(response.body);
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  /// =============================
  /// ADD SOCIETY
  /// =============================
  Future<void> addSociety() async {

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Society name required")));
      return;
    }

    final response = await http.post(
      Uri.parse("$Url/CourseManagement/AddSociety"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "SocietyName": nameController.text.trim(),
        "Description": descController.text.trim()
      }),
    );

    if (response.statusCode == 200) {

      nameController.clear();
      descController.clear();

      getSocieties();

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Society added successfully")));
    }
  }

  /// =============================
  /// UPDATE SOCIETY
  /// =============================
  Future<void> updateSociety(int id, String name, String desc) async {

    final response = await http.put(
      Uri.parse("$Url/CourseManagement/UpdateSociety/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "SocietyName": name,
        "Description": desc
      }),
    );

    if (response.statusCode == 200) {

      getSocieties();

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Society updated successfully")));
    }
  }

  /// =============================
  /// EDIT SOCIETY DIALOG
  /// =============================
  void openEditDialog(Map society) {

    TextEditingController editName =
        TextEditingController(text: society["SocietyName"]);

    TextEditingController editDesc =
        TextEditingController(text: society["Description"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(

          title: const Text("Edit Society"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: editName,
                decoration: const InputDecoration(
                    labelText: "Society Name",
                    border: OutlineInputBorder()),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: editDesc,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder()),
              )
            ],
          ),

          actions: [

            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),

            ElevatedButton(
              child: const Text("Update"),
              onPressed: () {

                updateSociety(
                    society["SocietyId"],
                    editName.text,
                    editDesc.text);

                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  /// =============================
  /// BUILD UI
  /// =============================
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

            /// ADD NEW SOCIETY
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
                        hintText: "Brief description...",
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
                      onPressed: addSociety,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// TITLE
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  "Existing Societies (${societies.length})",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 10),

            /// LIST
            loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: societies.map((s) {

                      List chairpersons = s["Chairpersons"] ?? [];
                      List mentors = s["Mentors"] ?? [];

                      return _societyCard(
                          s,
                          s["SocietyName"] ?? "",
                          s["Description"] ?? "",
                          chairpersons,
                          mentors);

                    }).toList(),
                  )
          ],
        ),
      ),
    );
  }

  /// =============================
  /// SOCIETY CARD
  /// =============================
  Widget _societyCard(
      Map society,
      String name,
      String desc,
      List chairpersons,
      List mentors
      ) {

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
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),

              IconButton(
                icon: const Icon(Icons.edit, color: Colors.green),
                onPressed: () => openEditDialog(society),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(desc, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 10),

          if (chairpersons.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Chairpersons:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(chairpersons.join(", "))
              ],
            ),

          const SizedBox(height: 6),

          if (mentors.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Mentors:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(mentors.join(", "))
              ],
            ),
        ],
      ),
    );
  }
}
import 'dart:convert';
import 'package:epams/HOD/AssignChairpersons.dart';
import 'package:epams/HOD/AssignMentors.dart';
import 'package:epams/HOD/HODDashboard.dart';
import 'package:epams/HOD/ManageSocieties.dart';
import 'package:epams/Session.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Societydashboard extends StatefulWidget {
  const Societydashboard({super.key});

  @override
  State<Societydashboard> createState() => _SocietydashboardState();
}

class _SocietydashboardState extends State<Societydashboard> {

  late Future<List<Session>> _sessionsFuture;
  Session? selectedSession;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = fetchSessions();
  }

  Future<List<Session>> fetchSessions() async {
    final response = await http.get(
      Uri.parse('$Url/PeerEvaluator/Sessions'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Session.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load sessions');
    }
  }

  void _showSelectSessionMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select a session first")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f5),

      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [

                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.groups, color: Colors.green),
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Society Management Office",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "SMO Administrator",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context)=>HodDashboard()));
                    },
                  )
                ],
              ),
            ),

            /// SESSION BAR
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.green,
              child: Row(
                children: [

                  const Text(
                    "Current Session:",
                    style: TextStyle(color: Colors.white),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: FutureBuilder<List<Session>>(
                      future: _sessionsFuture,
                      builder: (context, snapshot) {

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator(color: Colors.white);
                        }

                        final sessions = snapshot.data!;

                        return DropdownButton<Session>(
                          dropdownColor: Colors.green.shade100,
                          value: selectedSession,
                          hint: const Text(
                            "Select Session",
                            style: TextStyle(color: Colors.white),
                          ),
                          iconEnabledColor: Colors.white,
                          underline: const SizedBox(),
                          items: sessions.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(s.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedSession = val;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    _menuCard(
                      icon: Icons.apartment,
                      title: "Manage Societies",
                      subtitle: "Add, edit, and manage university societies",
                      enabled: selectedSession != null,
                      onTap: () {
                        if (selectedSession == null) {
                          _showSelectSessionMessage();
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Managesocieties(session: selectedSession!),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _menuCard(
                      icon: Icons.share,
                      title: "Assign Chairpersons",
                      subtitle: "Assign chairpersons to societies (max 2)",
                      enabled: selectedSession != null,
                      onTap: () {},
                    ),

                    const SizedBox(height: 12),

                    _menuCard(
                      icon: Icons.people,
                      title: "Assign Mentors",
                      subtitle: "Assign mentors to societies",
                      enabled: selectedSession != null,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : _showSelectSessionMessage,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16)
          ],
        ),
      ),
    );
  }
}
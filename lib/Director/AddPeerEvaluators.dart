import 'dart:convert';

import 'package:epams/Session.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Addpeerevaluators extends StatefulWidget {
  const Addpeerevaluators({super.key});

  @override
  State<Addpeerevaluators> createState() => _AddpeerevaluatorsState();
}

class _AddpeerevaluatorsState extends State<Addpeerevaluators> {
  late Future<List<Session>> _sessionsFuture;

  Session? selectedSession;

  // List of all teachers loaded on init
  List<Map<String, dynamic>> teachers = [];

  // List of selected teachers to add as peer evaluators
  List<Map<String, dynamic>> selectedTeachers = [];

  @override
  void initState() {
    super.initState();
    _sessionsFuture = fetchSessions();
    fetchAllTeachers(); // Load all teachers on start
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

  Future<void> fetchAllTeachers() async {
    final response = await http.get(
      Uri.parse('$Url/PeerEvaluator/Teachers'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      setState(() {
        teachers = data.map<Map<String, dynamic>>((t) {
          return {
            'id': t['userID'],
            'name': t['name'],
            'subject': t['department'], // Using department as subject here
            'dept': t['department'],
            'isSelected': false,
          };
        }).toList();

        selectedTeachers.clear();
      });
    } else {
      setState(() {
        teachers = [];
        selectedTeachers = [];
      });
      throw Exception('Failed to load teachers');
    }
  }

  Future<void> addPeerEvaluators() async {
    if (selectedSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a session')),
      );
      return;
    }

    if (selectedTeachers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one teacher')),
      );
      return;
    }

    final teacherIds = selectedTeachers.map((t) => t['id']).toList();

    final body = json.encode({
      "SessionId": selectedSession!.id,
      "TeacherIds": teacherIds,
    });

    final response = await http.post(
      Uri.parse('$Url/PeerEvaluator/Add'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Peer evaluators added successfully')),
      );

      // Optionally, clear selection after success
      setState(() {
        for (var teacher in teachers) {
          teacher['isSelected'] = false;
        }
        selectedTeachers.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add peer evaluators')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              const Text(
                'Add Peer Evaluator',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              /// SESSION DROPDOWN
              FutureBuilder<List<Session>>(
                future: _sessionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return const Text('Failed to load sessions');
                  }

                  final sessions = snapshot.data!;

                  return DropdownButtonFormField<Session>(
                    value: selectedSession,
                    hint: const Text('Select Session'),
                    items: sessions.map((s) {
                      return DropdownMenuItem<Session>(
                        value: s,
                        child: Text(s.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedSession = val;
                      });
                    },
                    decoration: _inputDecoration(),
                  );
                },
              ),

              const SizedBox(height: 16),

              /// SECTION TITLE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.blue,
                child: const Text(
                  'Select teachers to assign as peer evaluators',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 8),

              /// TEACHERS LIST (All loaded on init)
              ...teachers.map((teacher) {
                return Card(
                  color: teacher['isSelected'] ? Colors.green.shade50 : null,
                  child: CheckboxListTile(
                    value: teacher['isSelected'],
                    onChanged: (val) {
                      setState(() {
                        teacher['isSelected'] = val;

                        if (val == true) {
                          selectedTeachers.add(teacher);
                        } else {
                          selectedTeachers.removeWhere(
                              (t) => t['id'] == teacher['id']);
                        }
                      });
                    },
                    title: Text(teacher['name']),
                    subtitle: Text(teacher['subject']),
                    secondary: Text(teacher['dept']),
                  ),
                );
              }),

              const SizedBox(height: 12),

              /// ADD BUTTON
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.add),
                label: Text(
                    'Add ${selectedTeachers.length} Selected Teachers as Peer Evaluators'),
                onPressed: selectedTeachers.isEmpty || selectedSession == null
                    ? null
                    : () async {
                        await addPeerEvaluators();
                      },
              ),

              const SizedBox(height: 20),

              /// CURRENT PEER EVALUATORS (show selected ones)
              Text(
                'Selected Teachers',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              ...selectedTeachers.map((teacher) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(teacher['name']),
                      subtitle: Text(teacher['subject']),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_remove, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            teacher['isSelected'] = false;
                            selectedTeachers.removeWhere(
                                (t) => t['id'] == teacher['id']);
                          });
                        },
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF3F8F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}

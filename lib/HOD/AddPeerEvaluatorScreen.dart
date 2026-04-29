import 'dart:convert';

import 'package:epams/Session.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddPeerEvaluatorScreen extends StatefulWidget {
  const AddPeerEvaluatorScreen({super.key});

  @override
  State<AddPeerEvaluatorScreen> createState() => _AddPeerEvaluatorScreenState();
}

class _AddPeerEvaluatorScreenState extends State<AddPeerEvaluatorScreen> {
  late Future<List<Session>> _sessionsFuture;

  Session? selectedSession;

  List<Map<String, dynamic>> teachers = [];
  List<Map<String, dynamic>> selectedTeachers = [];

  @override
  void initState() {
    super.initState();
    _sessionsFuture = fetchSessions();
    fetchAllTeachers();
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
          bool isPermanent = (t['isPermanentEvaluator'] ?? 0) == 1;

          return {
            'id': t['userID'],
            'name': t['name'],
            'subject': t['department'],
            'dept': t['department'],
            'isSelected': isPermanent,
            'isPermanent': isPermanent,
          };
        }).toList();

        selectedTeachers = teachers
            .where((t) => t['isSelected'] == true)
            .toList();
      });
    }
  }

  Future<void> addPeerEvaluators() async {
    if (selectedSession == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a session')));
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add peer evaluators')),
      );
    }
  }

  /// ----------------------------------------------------------
  /// PERMANENT EVALUATOR MODAL
  /// ----------------------------------------------------------

  void openPermanentModal() {
    List<Map<String, dynamic>> modalTeachers = teachers
        .map((t) => Map<String, dynamic>.from(t))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        TextEditingController searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setModalState) {
            List filteredTeachers = modalTeachers.where((t) {
              return t['name'].toLowerCase().contains(
                searchController.text.toLowerCase(),
              );
            }).toList();

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "PERMANENT EVALUATOR",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// SEARCH
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Search faculty by name...",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (v) {
                        setModalState(() {});
                      },
                    ),

                    const SizedBox(height: 10),

                    /// LIST
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredTeachers.length,
                        itemBuilder: (context, index) {
                          final teacher = filteredTeachers[index];

                          return Card(
                            color: teacher['isPermanent']
                                ? Colors.green.shade50
                                : null,
                            child: CheckboxListTile(
                              value: teacher['isPermanent'],
                              title: Text(teacher['name']),
                              subtitle: Text(teacher['dept']),
                              onChanged: (val) {
                                setModalState(() {
                                  teacher['isPermanent'] = val;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    /// SAVE BUTTON
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () async {
                        List<String> selectedIds = modalTeachers
                            .where((t) => t['isPermanent'] == true)
                            .map<String>((t) => t['id'])
                            .toList();

                        await http.post(
                          Uri.parse('$Url/PeerEvaluator/SetBulkPermanent'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(selectedIds),
                        );

                        /// UPDATE MAIN SCREEN STATE
                        setState(() {
                          for (var teacher in teachers) {
                            bool isPermanent = selectedIds.contains(
                              teacher['id'],
                            );

                            teacher['isPermanent'] = isPermanent;
                            teacher['isSelected'] = isPermanent;

                            if (isPermanent) {
                              if (!selectedTeachers.any(
                                (t) => t['id'] == teacher['id'],
                              )) {
                                selectedTeachers.add(teacher);
                              }
                            } else {
                              selectedTeachers.removeWhere(
                                (t) => t['id'] == teacher['id'],
                              );
                            }
                          }
                        });

                        Navigator.pop(context);
                      },
                      child: const Text("SAVE & EXIT"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Peer Evaluator',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              /// NEW BUTTON
              ElevatedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text("Manage Permanent Evaluators"),
                onPressed: openPermanentModal,
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

              /// TEACHERS LIST
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
                            (t) => t['id'] == teacher['id'],
                          );
                        }
                      });
                    },
                    title: Text(teacher['name']),
                    subtitle: Text(teacher['subject']),
                    secondary: teacher['isPermanent']
                        ? const Icon(Icons.verified, color: Colors.green)
                        : null,
                  ),
                );
              }),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.add),
                label: Text(
                  'Add ${selectedTeachers.length} Selected Teachers as Peer Evaluators',
                ),
                onPressed: selectedTeachers.isEmpty || selectedSession == null
                    ? null
                    : () async {
                        await addPeerEvaluators();
                      },
              ),
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

import 'dart:convert';

import 'package:epams/Session.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddPeerEvaluatorScreen extends StatefulWidget {
  const AddPeerEvaluatorScreen({super.key});

  @override
  State<AddPeerEvaluatorScreen> createState() =>
      _AddPeerEvaluatorScreenState();
}

class _AddPeerEvaluatorScreenState extends State<AddPeerEvaluatorScreen> {
  late Future<List<Session>> _sessionsFuture;

  Session? selectedSession;

  List<Map<String, dynamic>> teachers = [];

  /// session-based selected teachers (PeerEvaluator table)
  List<String> sessionSelectedTeacherIds = [];

  @override
  void initState() {
    super.initState();
    _sessionsFuture = fetchSessions();
    fetchAllTeachers();
  }

  /// =========================
  /// SESSIONS
  /// =========================
  Future<List<Session>> fetchSessions() async {
    final res = await http.get(
      Uri.parse('$Url/PeerEvaluator/Sessions'),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      List data = json.decode(res.body);
      return data.map((e) => Session.fromJson(e)).toList();
    }
    throw Exception("Failed sessions");
  }

  /// =========================
  /// TEACHERS
  /// =========================
  Future<void> fetchAllTeachers() async {
    final res = await http.get(
      Uri.parse('$Url/PeerEvaluator/Teachers'),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      List data = json.decode(res.body);

      setState(() {
        teachers = data.map<Map<String, dynamic>>((t) {
          return {
            'id': t['userID'],
            'name': t['name'],
            'subject': t['department'],
            'isPermanent': (t['isPermanentEvaluator'] ?? 0) == 1,
          };
        }).toList();
      });
    }
  }

  /// =========================
  /// SESSION SELECTED LOAD (IMPORTANT FIX)
  /// =========================
  Future<void> fetchSessionEvaluators(int sessionId) async {
    final res = await http.get(
      Uri.parse('$Url/PeerEvaluator/BySession/$sessionId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      List data = json.decode(res.body);

      setState(() {
        sessionSelectedTeacherIds =
            data.map<String>((e) => e['userID'].toString()).toList();
      });
    } else {
      setState(() {
        sessionSelectedTeacherIds = [];
      });
    }
  }

  /// =========================
  /// ADD PEER EVALUATORS
  /// =========================
  Future<void> addPeerEvaluators() async {
    if (selectedSession == null) return;

    final teacherIds = {
      ...teachers
          .where((t) => t['isPermanent'] == true)
          .map((t) => t['id'].toString()),
      ...sessionSelectedTeacherIds
    }.toList();

    final body = json.encode({
      "SessionId": selectedSession!.id,
      "TeacherIds": teacherIds,
    });

    await http.post(
      Uri.parse('$Url/PeerEvaluator/Add'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saved Successfully")),
    );
  }

  /// =========================
  /// UI
  /// =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text("Add Peer Evaluator"),

            /// SESSION DROPDOWN
            FutureBuilder<List<Session>>(
              future: _sessionsFuture,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const CircularProgressIndicator();
                }

                return DropdownButton<Session>(
                  value: selectedSession,
                  hint: const Text("Select Session"),
                  items: snap.data!.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedSession = val;
                    });

                    if (val != null) {
                      fetchSessionEvaluators(val.id); // 🔥 IMPORTANT FIX
                    }
                  },
                );
              },
            ),

            const Divider(),

            /// TEACHERS LIST
            Expanded(
              child: ListView.builder(
                itemCount: teachers.length,
                itemBuilder: (context, index) {
                  final t = teachers[index];

                  final isPermanent = t['isPermanent'] == true;
                  final isSessionSelected =
                      sessionSelectedTeacherIds.contains(t['id'].toString());

                  final isChecked = isPermanent || isSessionSelected;

                  return Card(
                    child: CheckboxListTile(
                      value: isChecked,

                      /// LOCK PERMANENT
                      onChanged: isPermanent
                          ? null
                          : (val) {
                              setState(() {
                                if (val == true) {
                                  sessionSelectedTeacherIds
                                      .add(t['id'].toString());
                                } else {
                                  sessionSelectedTeacherIds
                                      .remove(t['id'].toString());
                                }
                              });
                            },

                      title: Text(t['name']),
                      subtitle: Text(t['subject']),

                      secondary: isPermanent
                          ? const Icon(Icons.lock, color: Colors.green)
                          : isSessionSelected
                              ? const Icon(Icons.check, color: Colors.blue)
                              : null,
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed:
                  selectedSession == null ? null : addPeerEvaluators,
              child: const Text("SAVE"),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
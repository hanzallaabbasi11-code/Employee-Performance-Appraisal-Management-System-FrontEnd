import 'dart:convert';

import 'package:epams/Session.dart';
import 'package:epams/Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Addkpi extends StatefulWidget {
  const Addkpi({super.key});

  @override
  State<Addkpi> createState() => _AddkpiState();
}

class _AddkpiState extends State<Addkpi> {

  /// SESSION VARIABLES
  late Future<List<Session>> _sessionsFuture;
  Session? selectedSession;

  /// Controllers
  final TextEditingController kpiNameController = TextEditingController();
  final TextEditingController kpiWeightController = TextEditingController();
  final TextEditingController subKpiNameController = TextEditingController();
  final TextEditingController subKpiWeightController = TextEditingController();

  String? selectedCategory;
  bool showSubKpiForm = false;

  List<String> categoryList = [
    'Teacher',
    'Admin',
    'DataCell',
    'Staff',
    'Lab Attendent',
  ];

  /// Temp sub KPIs
  List<Map<String, String>> tempSubKpis = [];

  /// Final KPI list (UI only)
  List<Map<String, dynamic>> addedKpis = [];

  @override
  void initState() {
    super.initState();
    _sessionsFuture = fetchSessions();
  }

  /// FETCH SESSIONS
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

  /// SAVE KPI
  Future<bool> saveKpiToDatabase() async {
    final url = Uri.parse('$Url/kpi/create-with-weight');

    int employeeTypeId = categoryList.indexOf(selectedCategory!) + 1;

    final body = {
      "KPIName": kpiNameController.text,
      "EmployeeTypeId": employeeTypeId,
      "SessionId": selectedSession!.id,
      "RequestedKPIWeight": int.parse(kpiWeightController.text),
      "SubKPIs": tempSubKpis.map((sub) {
        return {"Name": sub['name'], "Weight": int.parse(sub['weight']!)};
      }).toList(),
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print(response.body);
      return false;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Add KPI',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Image.asset('assets/images/logo.jpeg', height: 40),
                ],
              ),

              const SizedBox(height: 10),

              const Text(
                  'Define KPIs and sub-KPIs for each category type.'),

              const SizedBox(height: 16),

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

              const SizedBox(height: 20),

              /// CREATE KPI CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'Create New KPI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// CATEGORY DROPDOWN
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      hint: const Text('Select category type'),
                      items: categoryList.map((e) =>
                          DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) =>
                          setState(() => selectedCategory = val),
                      decoration: _inputDecoration(),
                    ),

                    const SizedBox(height: 12),

                    /// KPI NAME
                    TextField(
                      controller: kpiNameController,
                      decoration: _inputDecoration(
                        hint: 'e.g., Academics, Society',
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// KPI WEIGHT
                    TextField(
                      controller: kpiWeightController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        hint: 'e.g., 80 (will auto-adjust)',
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// NEXT BUTTON
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: () {
                        setState(() => showSubKpiForm = true);
                      },
                      child: const Text('Next: Add Sub-KPIs'),
                    ),

                    /// SUB KPI FORM
                    if (showSubKpiForm) ...[

                      const SizedBox(height: 20),

                      TextField(
                        controller: subKpiNameController,
                        decoration: _inputDecoration(hint: 'Sub-KPI Name'),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: subKpiWeightController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(hint: 'Sub-KPI Weight'),
                      ),

                      const SizedBox(height: 12),

                      /// ADD SUB KPI
                      ElevatedButton(
                        onPressed: () {

                          if (subKpiNameController.text.isEmpty ||
                              subKpiWeightController.text.isEmpty) {
                            return;
                          }

                          tempSubKpis.add({
                            'name': subKpiNameController.text,
                            'weight': subKpiWeightController.text,
                          });

                          subKpiNameController.clear();
                          subKpiWeightController.clear();

                          setState(() {});
                        },
                        child: const Text('Add Sub-KPI'),
                      ),

                      const SizedBox(height: 12),

                      /// SHOW SUB KPIs
                      ...tempSubKpis.map((sub) => ListTile(
                        title: Text(sub['name']!),
                        trailing: Text('${sub['weight']}%'),
                      )),

                      const SizedBox(height: 12),

                      /// SAVE KPI
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                        ),
                        onPressed: () async {

                          if (selectedSession == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please select session")),
                            );
                            return;
                          }

                          if (selectedCategory == null ||
                              kpiNameController.text.isEmpty ||
                              kpiWeightController.text.isEmpty ||
                              tempSubKpis.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please complete all fields"),
                              ),
                            );
                            return;
                          }

                          bool success = await saveKpiToDatabase();

                          if (success) {

                            addedKpis.add({
                              'category': selectedCategory,
                              'name': kpiNameController.text,
                              'weight': kpiWeightController.text,
                              'subKpis': List.from(tempSubKpis),
                            });

                            selectedCategory = null;
                            kpiNameController.clear();
                            kpiWeightController.clear();
                            tempSubKpis.clear();
                            showSubKpiForm = false;

                            setState(() {});

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("KPI Saved Successfully"),
                              ),
                            );

                          } else {

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Error saving KPI")),
                            );

                          }
                        },
                        child: const Text('Save KPI'),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// KPI LIST
              const Text(
                'KPI Categories',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ...addedKpis.map(
                    (kpi) => Card(
                  child: ExpansionTile(
                    title: Text(kpi['name']),
                    subtitle: Text(
                        '${kpi['category']} • Weight: ${kpi['weight']}%'),
                    children: (kpi['subKpis'] as List)
                        .map<Widget>((sub) =>
                        ListTile(
                          title: Text(sub['name']),
                          trailing: Text('${sub['weight']}%'),
                        ))
                        .toList(),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF3F8F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}